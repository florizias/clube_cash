import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/firebase/firebase_providers.dart';
import '../../data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);

  return ProfileRepository(db: db, storage: FirebaseStorage.instance);
});

final profileActionsProvider = Provider<ProfileActions>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileActions(repository);
});

class ProfileActions {
  final ProfileRepository _repository;

  ProfileActions(this._repository);

  Future<String?> updateProfile({required String uid, required String name, required String phone, XFile? profileImage, String? oldPhotoUrl}) async {
    String? photoUrl;

    if (profileImage != null) {
      photoUrl = await _repository.uploadProfileImage(uid: uid, image: profileImage);
    }

    await _repository.updateProfile(uid: uid, name: name, phone: phone, photoUrl: photoUrl, oldPhotoUrl: oldPhotoUrl);

    return photoUrl;
  }
}
