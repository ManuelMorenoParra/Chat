import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'privacy_screen.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Set<String> blockedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadBlocked();
  }

  Future<void> _loadBlocked() async {
    final uid = _auth.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('blocked')
        .get();

    blockedUsers = snap.docs.map((e) => e.id).toSet();
    setState(() {});
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final user = _auth.currentUser;

    await _firestore.collection('messages').add({
      'text': _controller.text.trim(),
      'uid': user!.uid,
      'name': user.displayName,
      'photo': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  void _actions(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text("Bloquear"),
            onTap: () async {
              final myUid = _auth.currentUser!.uid;
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(myUid)
                  .collection('blocked')
                  .doc(data['uid'])
                  .set({'name': data['name']});
              blockedUsers.add(data['uid']);
              Navigator.pop(context);
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text("Reportar"),
            onTap: () async {
              await FirebaseFirestore.instance.collection('reports').add({
                'reportedUid': data['uid'],
                'name': data['name'],
                'text': data['text'],
                'by': _auth.currentUser!.uid,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      drawer: Drawer(
        child: ListView(children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? ''),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture:
                CircleAvatar(backgroundImage: NetworkImage(user?.photoURL ?? '')),
          ),
          ListTile(
            title: const Text("Perfil"),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          ListTile(
            title: const Text("Privacidad"),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          ),
        ]),
      ),
      appBar: AppBar(title: const Text("Chat")),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('messages')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (c, s) {
              if (!s.hasData) return const Center(child: CircularProgressIndicator());
              final docs = s.data!.docs;

              return ListView(
                reverse: true,
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;

                  if (blockedUsers.contains(data['uid'])) return const SizedBox();

                  final isMe = data['uid'] == user!.uid;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: GestureDetector(
                      onLongPress: () => _actions(data),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[800],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['name'],
                                style: const TextStyle(fontSize: 11)),
                            Text(data['text']),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Row(children: [
          Expanded(child: TextField(controller: _controller)),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
        ])
      ]),
    );
  }
}
