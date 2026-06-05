import 'package:flutter/material.dart';
import 'package:snack_bazaar/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:snack_bazaar/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SnackBazaarApp());
}
