import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/image_webp_converter.dart';
import '../../models/ad_banner.dart';

class AdminAdsRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  AdminAdsRepository({required FirebaseFirestore db, required FirebaseStorage storage}) : _db = db, _storage = storage;

  String createBannerId() {
    return _collection.doc().id;
  }

  CollectionReference<Map<String, dynamic>> get _collection {
    return _db.collection('ads_banners');
  }

  Stream<List<AdBanner>> watchAllBanners() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map(AdBanner.fromFirestore).toList();
    });
  }

  Stream<List<AdBanner>> watchActiveBanners() {
    return _collection.where('isActive', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs.map(AdBanner.fromFirestore).toList();
    });
  }

  Future<String> uploadBannerImage({required String bannerId, required XFile image}) async {
    final Uint8List webpBytes = await ImageWebpConverter.xFileToWebp(image: image);

    final ref = _storage.ref('ads_banners/$bannerId/banner.webp');

    final snapshot = await ref.putData(
      webpBytes,
      SettableMetadata(contentType: 'image/webp', customMetadata: {'originalName': image.name, 'originalMimeType': image.mimeType ?? ''}),
    );

    return snapshot.ref.getDownloadURL();
  }

  Future<void> createBanner(AdBanner banner) async {
    await _collection.doc(banner.id).set({
      'title': banner.title.trim(),
      'imageURL': banner.imageURL.trim(),
      'buttonLink': banner.buttonLink.trim(),
      'buttonText': banner.buttonText.trim(),
      'description': banner.description.trim(),
      'isActive': banner.isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBanner(AdBanner banner) async {
    await _collection.doc(banner.id).update({...banner.toJson(), 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> toggleBannerActive({required String id, required bool isActive}) async {
    await _collection.doc(id).update({'isActive': isActive, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _storage.ref('ads_banners/$id/banner.webp').delete();
    } catch (_) {}

    await _collection.doc(id).delete();
  }
}
