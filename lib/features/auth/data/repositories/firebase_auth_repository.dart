import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;

  FirebaseAuthRepository({required FirebaseAuth auth}) : _auth = auth;

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  @override
  User? get currentUser => _auth.currentUser;

  @override
  bool get isLoggedIn => _auth.currentUser != null;

  @override
  Future<UserCredential> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email.trim().toLowerCase(), password: password);
  }

  @override
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email.trim().toLowerCase(), password: password);

    final user = credential.user;

    if (user != null) {
      await user.updateDisplayName(name.trim());
    }

    return credential;
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();

      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      return _auth.signInWithPopup(googleProvider);
    }

    final googleUser = await GoogleSignIn.instance.authenticate();

    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

    return _auth.signInWithCredential(credential);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  @override
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {}

    await _auth.signOut();
  }
}
