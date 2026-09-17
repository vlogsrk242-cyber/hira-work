import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const HiraWorkShethApp());
}

class HiraWorkShethApp extends StatelessWidget {
  const HiraWorkShethApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'હીરા કામ હિસ્ટરી',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}
