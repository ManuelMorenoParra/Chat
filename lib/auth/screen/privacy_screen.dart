import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'blocked_users_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String bioVisibility = 'public';
  String photoVisibility = 'public';
  bool showOnline = true;
  bool readReceipts = true;
  bool friendsOnly = false;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      bioVisibility = data['bioVisibility'] ?? 'public';
      photoVisibility = data['photoVisibility'] ?? 'public';
      showOnline = data['showOnline'] ?? true;
      readReceipts = data['readReceipts'] ?? true;
      friendsOnly = data['friendsOnly'] ?? false;
    }

    setState(() => loading = false);
  }

  Future<void> save() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'bioVisibility': bioVisibility,
      'photoVisibility': photoVisibility,
      'showOnline': showOnline,
      'readReceipts': readReceipts,
      'friendsOnly': friendsOnly,
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Privacidad guardada")));
  }

  Widget selector(String title, String value, Function(String) onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: const Color(0xFF2A1E4F),
        style: const TextStyle(color: Colors.white),
        items: const [
          DropdownMenuItem(value: 'public', child: Text("Público")),
          DropdownMenuItem(value: 'friends', child: Text("Amigos")),
          DropdownMenuItem(value: 'private', child: Text("Nadie")),
        ],
        onChanged: (v) => setState(() => onChanged(v!)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B061A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A1E4F),
        title: const Text("Privacidad"),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Visibilidad",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ),

          selector("Quién ve tu bio", bioVisibility, (v) => bioVisibility = v),
          selector(
              "Quién ve tu foto", photoVisibility, (v) => photoVisibility = v),

          const Divider(color: Colors.white24),

          SwitchListTile(
            value: showOnline,
            onChanged: (v) => setState(() => showOnline = v),
            title: const Text("Mostrar estado online",
                style: TextStyle(color: Colors.white)),
          ),

          SwitchListTile(
            value: readReceipts,
            onChanged: (v) => setState(() => readReceipts = v),
            title: const Text("Confirmaciones de lectura",
                style: TextStyle(color: Colors.white)),
          ),

          SwitchListTile(
            value: friendsOnly,
            onChanged: (v) => setState(() => friendsOnly = v),
            title: const Text("Solo mensajes de amigos",
                style: TextStyle(color: Colors.white)),
          ),

          const Divider(color: Colors.white24),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Bloqueos",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ),

          ListTile(
            leading: const Icon(Icons.block, color: Color(0xFF6A4CFF)),
            title: const Text("Usuarios bloqueados",
                style: TextStyle(color: Colors.white)),
            subtitle: const Text("Gestiona a quién has bloqueado",
                style: TextStyle(color: Colors.white54)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BlockedUsersScreen()),
              );
            },
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4CFF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: save,
              child: const Text("Guardar ajustes"),
            ),
          ),
        ],
      ),
    );
  }
}
