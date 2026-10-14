import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/double_from.dart';
import '../../../../core/utils/geo_point.dart' as geocode;
import '../../../../core/utils/image_webp_converter.dart';

class PartnerStoreSettingsRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  PartnerStoreSettingsRepository({required FirebaseFirestore db, required FirebaseStorage storage}) : _db = db, _storage = storage;

  DocumentReference<Map<String, dynamic>> _partnerDoc(String partnerId) {
    return _db.collection('partners').doc(partnerId);
  }

  Stream<PartnerStoreSettingsDto?> watchPartnerStore(String partnerId) {
    return _partnerDoc(partnerId).snapshots().map((doc) {
      if (!doc.exists) return null;

      return PartnerStoreSettingsDto.fromFirestore(doc);
    });
  }

  Future<String> uploadLogo({required String partnerId, required XFile image}) async {
    final Uint8List webpBytes = await ImageWebpConverter.xFileToWebp(image: image);

    final ref = _storage.ref('partners/$partnerId/logo.webp');

    final snapshot = await ref.putData(
      webpBytes,
      SettableMetadata(contentType: 'image/webp', customMetadata: {'originalName': image.name, 'originalMimeType': image.mimeType ?? ''}),
    );

    return snapshot.ref.getDownloadURL();
  }

  Future<String> uploadCover({required String partnerId, required XFile image}) async {
    final Uint8List webpBytes = await ImageWebpConverter.xFileToWebp(image: image);

    final ref = _storage.ref('partners/$partnerId/cover.webp');

    final snapshot = await ref.putData(
      webpBytes,
      SettableMetadata(contentType: 'image/webp', customMetadata: {'originalName': image.name, 'originalMimeType': image.mimeType ?? ''}),
    );

    return snapshot.ref.getDownloadURL();
  }

  Future<void> updateStoreSettings({
    required String partnerId,
    required String name,
    required String category,
    required String address,
    required String whatsapp,
    required String website,
    required String instagram,
    required String facebook,
    required String tiktok,
    required String description,

    String cep = '',
    String street = '',
    String number = '',
    String neighborhood = '',
    String city = '',
    String state = '',
    String country = 'Brasil',

    String? logoUrl,
    String? coverImageUrl,
  }) async {
    final cleanAddress = address.trim();

    final geo = cleanAddress.isEmpty ? null : await geocode.geocodeByAddressSmart(cleanAddress);

    final data = <String, dynamic>{
      'name': name.trim(),
      'category': category.trim(),

      'cep': cep.trim(),
      'street': street.trim(),
      'number': number.trim(),
      'neighborhood': neighborhood.trim(),
      'city': city.trim(),
      'state': state.trim(),
      'country': country.trim().isEmpty ? 'Brasil' : country.trim(),

      'address': cleanAddress,

      'geocodeStatus': geo == null ? 'failed' : 'success',
      'geocodedAt': FieldValue.serverTimestamp(),

      'whatsapp': whatsapp.trim(),
      'website': website.trim(),
      'instagram': instagram.trim(),
      'facebook': facebook.trim(),
      'tiktok': tiktok.trim(),
      'description': description.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (geo != null) {
      data['latitude'] = geo.lat;
      data['longitude'] = geo.lng;
    }

    if (logoUrl != null && logoUrl.trim().isNotEmpty) {
      data['logoUrl'] = logoUrl.trim();
    }

    if (coverImageUrl != null && coverImageUrl.trim().isNotEmpty) {
      data['coverImageUrl'] = coverImageUrl.trim();
    }

    await _partnerDoc(partnerId).set(data, SetOptions(merge: true));
  }
}

class PartnerStoreSettingsDto {
  final String id;
  final String name;
  final String category;
  final String address;
  final String cep;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;
  final String whatsapp;
  final String website;
  final String instagram;
  final String facebook;
  final String tiktok;
  final String description;
  final String logoUrl;
  final String coverImageUrl;

  const PartnerStoreSettingsDto({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.cep,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.whatsapp,
    required this.website,
    required this.instagram,
    required this.facebook,
    required this.tiktok,
    required this.description,
    required this.logoUrl,
    required this.coverImageUrl,
  });

  factory PartnerStoreSettingsDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data() ?? {};

    return PartnerStoreSettingsDto(
      id: doc.id,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      cep: json['cep']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      neighborhood: json['neighborhood']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? 'Brasil',
      latitude: doubleFromNull(json['latitude']),
      longitude: doubleFromNull(json['longitude']),
      whatsapp: json['whatsapp']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      instagram: json['instagram']?.toString() ?? '',
      facebook: json['facebook']?.toString() ?? '',
      tiktok: json['tiktok']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      coverImageUrl: json['coverImageUrl']?.toString() ?? '',
    );
  }
}
