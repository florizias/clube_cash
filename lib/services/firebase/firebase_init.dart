import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseInit {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ Aqui é onde você pluga coisas opcionais no futuro:
    // - Crashlytics
    // - Analytics
    // - AppCheck
    // - Remote Config
  }
}
