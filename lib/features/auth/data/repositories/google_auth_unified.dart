import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

import 'google_auth_mobile.dart';
import 'google_auth_web.dart';

class GoogleAuthFacade {
  final FirebaseAuth _auth;

  GoogleAuthFacade(this._auth);

  Future<UserCredential> signInWithGoogle() {
    if (kIsWeb) {
      return GoogleAuthWeb(_auth).signInWithGoogle();
    }
    return GoogleAuthMobile(_auth).signInWithGoogle();
  }

  Future<void> signOut() async {
    if (kIsWeb) {
      await GoogleAuthWeb(_auth).signOut();
    } else {
      await GoogleAuthMobile(_auth).signOut();
    }
  }
}
