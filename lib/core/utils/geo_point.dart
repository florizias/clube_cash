import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppGeoPoint {
  final double lat;
  final double lng;

  AppGeoPoint(this.lat, this.lng);

  @override
  String toString() => 'AppGeoPoint(lat: $lat, lng: $lng)';
}

class _BrAddress {
  final String street;
  final String? number;
  final String? neighborhood;
  final String city;
  final String state;
  final String? postalCode;

  _BrAddress({
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.postalCode,
  });
}

_BrAddress? _parseBrazilAddress(String s) {
  final clean = s.trim();

  if (clean.isEmpty) return null;

  final withoutCountry = clean.replaceAll(RegExp(r',?\s*Brasil$', caseSensitive: false), '');

  final parts = withoutCountry.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  if (parts.length < 3) return null;

  final street = parts[0];

  String? number;
  String? neighborhood;

  final numberAndNeighborhood = parts[1].split('-').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  if (numberAndNeighborhood.isNotEmpty) {
    number = numberAndNeighborhood[0];
  }

  if (numberAndNeighborhood.length > 1) {
    neighborhood = numberAndNeighborhood.sublist(1).join(' - ');
  }

  final cityAndState = parts[2].split('-').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  if (cityAndState.length < 2) return null;

  final city = cityAndState[0];
  final state = cityAndState[1].toUpperCase();

  final postalCode = _extractPostalCode(clean);

  if (street.isEmpty || city.isEmpty || state.isEmpty) return null;

  return _BrAddress(street: street, number: number, neighborhood: neighborhood, city: city, state: state, postalCode: postalCode);
}

String? _extractPostalCode(String value) {
  final match = RegExp(r'\b\d{2}\.?\d{3}-?\d{3}\b').firstMatch(value);

  if (match == null) return null;

  final digits = match.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');

  if (digits.length != 8) return null;

  return '${digits.substring(0, 5)}-${digits.substring(5)}';
}

final Map<String, AppGeoPoint?> _geoCache = {};

Future<AppGeoPoint?> geocodeByAddressSmart(String address) async {
  final key = address.trim().toLowerCase();

  if (_geoCache.containsKey(key)) {
    return _geoCache[key];
  }

  final structured = _parseBrazilAddress(address);

  if (structured != null) {
    AppGeoPoint? p;

    p = await _geocodeStructured(structured);
    if (p != null) return _geoCache[key] = p;

    if (structured.neighborhood != null && structured.neighborhood!.trim().isNotEmpty) {
      p = await _geocodeFreeForm('${structured.street}, ${structured.neighborhood}, ${structured.city} - ${structured.state}, Brasil');
      if (p != null) return _geoCache[key] = p;
    }

    p = await _geocodeFreeForm('${structured.street}, ${structured.city} - ${structured.state}, Brasil');
    if (p != null) return _geoCache[key] = p;

    if (structured.postalCode != null) {
      p = await _geocodeFreeForm('${structured.postalCode}, ${structured.city} - ${structured.state}, Brasil');
      if (p != null) return _geoCache[key] = p;
    }
  }

  final normalizedAddress = address.replaceAllMapped(
    RegExp(r'\b(\d{2})\.(\d{3})-(\d{3})\b'),
    (match) => '${match.group(1)}${match.group(2)}-${match.group(3)}',
  );

  final freePoint = await _geocodeFreeForm(normalizedAddress);
  if (freePoint != null) return _geoCache[key] = freePoint;

  final cep = _extractPostalCode(address);

  if (cep != null) {
    final cepPoint = await _geocodeFreeForm('$cep, Brasil');
    if (cepPoint != null) return _geoCache[key] = cepPoint;
  }

  return _geoCache[key] = null;
}

Future<AppGeoPoint?> _geocodeFreeForm(String q) async {
  final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
    'q': q,
    'format': 'jsonv2',
    'limit': '1',
    'addressdetails': '0',
    'countrycodes': 'br',
    'accept-language': 'pt-BR',
    // dica: se você for fazer MUITO uso, inclua email conforme policy
    // 'email': 'contato@seuapp.com',
  });

  return _doRequest(uri);
}

Future<AppGeoPoint?> _geocodeStructured(_BrAddress a) async {
  final streetQuery = a.number == null || a.number!.trim().isEmpty ? a.street : '${a.number} ${a.street}';

  final uri = Uri.https(
    'nominatim.openstreetmap.org',
    '/search',
    {
      'street': streetQuery,
      'city': a.city,
      'state': a.state,
      'postalcode': a.postalCode ?? '',
      'country': 'Brasil',
      'format': 'jsonv2',
      'limit': '1',
      'addressdetails': '0',
      'countrycodes': 'br',
      'accept-language': 'pt-BR',
    }..removeWhere((k, v) => v.trim().isEmpty),
  );

  return _doRequest(uri);
}

Future<AppGeoPoint?> _doRequest(Uri uri) async {
  try {
    debugPrint('NOMINATIM URL: $uri');

    final res = await http.get(uri, headers: {'User-Agent': 'ClubCash/1.0 (contato@clubcash.com.br)'});

    debugPrint('NOMINATIM STATUS: ${res.statusCode}');
    debugPrint('NOMINATIM BODY: ${res.body}');

    if (res.statusCode != 200) return null;

    final List data = json.decode(res.body);

    if (data.isEmpty) return null;

    final lat = double.tryParse(data[0]['lat'].toString());
    final lon = double.tryParse(data[0]['lon'].toString());

    if (lat == null || lon == null) return null;

    return AppGeoPoint(lat, lon);
  } catch (error) {
    debugPrint('NOMINATIM ERROR: $error');
    return null;
  }
}
