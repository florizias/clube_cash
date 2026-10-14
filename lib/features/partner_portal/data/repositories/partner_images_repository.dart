import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/image_webp_converter.dart';

class PartnerImagesRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  PartnerImagesRepository({required FirebaseFirestore db, required FirebaseStorage storage}) : _db = db, _storage = storage;

  Future<String> uploadPartnerLogo({required String partnerId, required XFile image}) async {
    final Uint8List webpBytes = await ImageWebpConverter.xFileToWebp(image: image);

    final ref = _storage.ref('partners/$partnerId/logo.webp');

    final snapshot = await ref.putData(
      webpBytes,
      SettableMetadata(contentType: 'image/webp', customMetadata: {'originalName': image.name, 'originalMimeType': image.mimeType ?? ''}),
    );

    return snapshot.ref.getDownloadURL();
  }

  Future<String> uploadPartnerCover({required String partnerId, required XFile image}) async {
    final Uint8List webpBytes = await ImageWebpConverter.xFileToWebp(image: image);

    final ref = _storage.ref('partners/$partnerId/cover.webp');

    final snapshot = await ref.putData(
      webpBytes,
      SettableMetadata(contentType: 'image/webp', customMetadata: {'originalName': image.name, 'originalMimeType': image.mimeType ?? ''}),
    );

    return snapshot.ref.getDownloadURL();
  }

  Future<void> updatePartnerImages({required String partnerId, String? logoUrl, String? coverImageUrl}) async {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};

    if (logoUrl != null && logoUrl.trim().isNotEmpty) {
      data['logoUrl'] = logoUrl.trim();
    }

    if (coverImageUrl != null && coverImageUrl.trim().isNotEmpty) {
      data['coverImageUrl'] = coverImageUrl.trim();
    }

    await _db.collection('partners').doc(partnerId).set(data, SetOptions(merge: true));
  }
}
