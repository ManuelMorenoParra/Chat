import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import 'chat_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("Login with Google"),
          onPressed: () async {
            print("LOGIN PRESSED");

            final user = await _authService.signInWithGoogle();

            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}
