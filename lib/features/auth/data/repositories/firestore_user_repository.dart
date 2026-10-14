import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/providers/auth_providers.dart';
import '../dtos/user_profile_dto.dart';
import '../mappers/user_profile_mapper.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _db;

  FirestoreUserRepository(this._db);

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _db.collection('users').doc(uid);

  final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
    final user = ref.watch(firebaseUserProvider).value;
    if (user == null) return const Stream.empty();

    return ref.watch(userRepositoryProvider).watchProfile(user.uid);
  });

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final dto = UserProfileDto.fromJson(doc.data() ?? {});
      return UserProfileMapper.toEntity(uid, dto);
    });
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _doc(uid).get();
    if (!doc.exists) return null;
    final dto = UserProfileDto.fromJson(doc.data() ?? {});
    return UserProfileMapper.toEntity(uid, dto);
  }

  @override
  Future<void> createOrUpdateProfile(UserProfile profile) async {
    final dto = UserProfileMapper.toDto(profile);
    await _doc(profile.uid).set(dto.toJson(), SetOptions(merge: true));
  }
}
