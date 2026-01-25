import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B061A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A1E4F),
        title: const Text("Perfil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(user?.photoURL ?? ''),
            ),
            const SizedBox(height: 20),
            Text(
              user?.displayName ?? '',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(user?.email ?? '',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 30),
            ListTile(
              leading:
                  const Icon(Icons.person, color: Color(0xFF6A4CFF)),
              title: const Text("UID",
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(user?.uid ?? '',
                  style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
