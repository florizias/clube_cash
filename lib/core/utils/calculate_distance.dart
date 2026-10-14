import 'dart:math';

import 'geo_point.dart';

String formatAddress({
  required String street,
  required String number,
  required String district,
  required String city,
  required String state,
  required String zipCode,
  required String country,
}) {
  return "$street, $number, $district, $city, $state, $zipCode, $country";
}

double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371.0;

  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) + cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  final distance = earthRadius * c;
  final rounded = double.parse(distance.toStringAsFixed(1));

  return rounded;
}

double _degToRad(double deg) => deg * (pi / 180);

Future<double?> distanceByAddresses({required String userAddressFormatted, required String companyAddressFormatted}) async {
  final userPoint = await geocodeByAddressSmart(userAddressFormatted);
  if (userPoint == null) return null;

  final companyPoint = await geocodeByAddressSmart(companyAddressFormatted);
  if (companyPoint == null) return null;

  return calculateDistanceKm(userPoint.lat, userPoint.lng, companyPoint.lat, companyPoint.lng);
}
