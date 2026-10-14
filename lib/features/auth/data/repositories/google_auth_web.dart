import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthWeb {
  final FirebaseAuth _auth;

  GoogleAuthWeb(this._auth);

  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider();

    // opcional: scopes e parâmetros
    // provider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    // provider.setCustomParameters({'login_hint': 'user@example.com'});

    return _auth.signInWithPopup(provider);
  }

  Future<void> signOut() async => _auth.signOut();
}
