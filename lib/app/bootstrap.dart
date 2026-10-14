import 'package:flutter/widgets.dart';

import '../services/firebase/firebase_init.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInit.initialize();
}
