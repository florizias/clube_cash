import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../services/firebase/auth_providers.dart';
import '../../../../services/firebase/firebase_providers.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firestore_store_request_repository.dart';
import '../../data/repositories/firestore_user_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';

enum UserRole { customer, partner }

final mockIsLoggedInProvider = StateProvider<bool>((ref) => false);

final mockUserRoleProvider = StateProvider<UserRole?>((ref) => null);

final isLoggedInProvider = Provider<bool>((ref) {
  final mockLogged = ref.watch(mockIsLoggedInProvider);

  if (mockLogged) return true;

  final userAsync = ref.watch(firebaseUserProvider);

  return userAsync.maybeWhen(data: (user) => user != null, orElse: () => false);
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(firebaseUserProvider).value;

  if (user == null) return const Stream.empty();

  final repo = ref.watch(userRepositoryProvider);
  return repo.watchProfile(user.uid);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(auth: auth);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return FirestoreUserRepository(db);
});

final storeRequestRepositoryProvider = Provider<FirestoreStoreRequestRepository>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  return FirestoreStoreRequestRepository(db);
});

/// Estado de autenticação (FirebaseAuth user)
final firebaseUserProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
});

/// UID atual (ou null)
final currentUidProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);
  return userAsync.maybeWhen(data: (u) => u?.uid, orElse: () => null);
});

/// Perfil do usuário no Firestore (users/{uid})
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();

  final repo = ref.watch(userRepositoryProvider);
  return repo.watchProfile(uid);
});
