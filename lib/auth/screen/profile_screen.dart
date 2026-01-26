import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final nameCtrl = TextEditingController();
  final bioCtrl = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    nameCtrl.text = user?.displayName ?? '';

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      bioCtrl.text = doc.data()?['bio'] ?? '';
    }

    setState(() {});
  }

  Future<void> saveProfile() async {
    if (user == null) return;

    setState(() => loading = true);

    // Actualiza nombre en Auth
    await user!.updateDisplayName(nameCtrl.text);

    // Guarda en Firestore
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': nameCtrl.text,
      'bio': bioCtrl.text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() => loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil guardado")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B061A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A1E4F),
        title: const Text("Editar perfil"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            // NOMBRE
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nombre",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF2A1E4F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BIO
            TextField(
              controller: bioCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Bio",
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: "Escribe algo sobre ti...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A1E4F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // GUARDAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4CFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: loading ? null : saveProfile,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
