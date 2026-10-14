import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();

  User? get currentUser;

  bool get isLoggedIn;

  Future<UserCredential> signIn({required String email, required String password});

  Future<UserCredential> signUp({required String name, required String email, required String phone, required String password, required String role});

  Future<UserCredential> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
