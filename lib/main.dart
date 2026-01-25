import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/screen/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B061A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A1E4F),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6A4CFF),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
