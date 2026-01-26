import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Usuarios bloqueados")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('blocked')
            .snapshots(),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            children: s.data!.docs.map((d) {
              return ListTile(
                title: Text(d['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.lock_open),
                  onPressed: () => d.reference.delete(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
