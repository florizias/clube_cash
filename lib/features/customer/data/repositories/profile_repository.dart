import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/image_webp_converter.dart';

class ProfileRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  ProfileRepository({required FirebaseFirestore db, required FirebaseStorage storage}) : _db = db, _storage = storage;

  Future<String> uploadProfileImage({required String uid, required XFile image}) async {
    final webpBytes = await ImageWebpConverter.xFileToWebp(image: image);

    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.webp';

    final ref = _storage.ref().child('users/$uid/profile/$fileName');

    final metadata = SettableMetadata(contentType: 'image/webp', customMetadata: {'convertedFrom': image.mimeType ?? 'unknown'});

    await ref.putData(webpBytes, metadata);

    return ref.getDownloadURL();
  }

  Future<void> updateProfile({required String uid, required String name, required String phone, String? photoUrl, String? oldPhotoUrl}) async {
    final cleanNewPhotoUrl = photoUrl?.trim() ?? '';
    final cleanOldPhotoUrl = oldPhotoUrl?.trim() ?? '';

    final data = <String, dynamic>{'name': name.trim(), 'phone': phone.trim(), 'updatedAt': FieldValue.serverTimestamp()};

    if (cleanNewPhotoUrl.isNotEmpty) {
      data['photoUrl'] = cleanNewPhotoUrl;
    }

    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (_) {
      if (cleanNewPhotoUrl.isNotEmpty) {
        await _tryDeleteImage(cleanNewPhotoUrl);
      }

      rethrow;
    }

    if (cleanOldPhotoUrl.isNotEmpty && cleanNewPhotoUrl.isNotEmpty && cleanOldPhotoUrl != cleanNewPhotoUrl) {
      await _tryDeleteImage(cleanOldPhotoUrl);
    }
  }

  Future<void> _tryDeleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (_) {
      // Ignora erro porque a imagem antiga pode já ter sido removida,
      // pode ser URL externa, ou pode não pertencer ao Firebase Storage.
    }
  }
}
