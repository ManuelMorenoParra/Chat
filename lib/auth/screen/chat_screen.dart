import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'privacy_screen.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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
      'name': user.displayName ?? 'Usuario',
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
      backgroundColor: const Color(0xFF0B061A),

      // ---------------- DRAWER ----------------
      drawer: Drawer(
        backgroundColor: const Color(0xFF0B061A),
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2A1E4F)),
              accountName: Text(user?.displayName ?? '',
                  style: const TextStyle(color: Colors.white)),
              accountEmail: Text(user?.email ?? '',
                  style: const TextStyle(color: Colors.white70)),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(user?.photoURL ?? ''),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF6A4CFF)),
              title: const Text("Perfil",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.lock, color: Color(0xFF6A4CFF)),
              title: const Text("Privacidad",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PrivacyScreen()));
              },
            ),

            const Divider(color: Colors.white24),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title:
                  const Text("Logout", style: TextStyle(color: Colors.white)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      // ------------------------------------------------

      appBar: AppBar(
        backgroundColor: const Color(0xFF2A1E4F),
        title: const Text("🌙 Chat Global"),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (c, s) {
                if (!s.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = s.data!.docs;

                return ListView(
                  reverse: true,
                  children: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;

                    if (blockedUsers.contains(data['uid'])) {
                      return const SizedBox();
                    }

                    final isMe = data['uid'] == user!.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () => _actions(data),
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isMe ? const Color(0xFF6A4CFF) : const Color(0xFF2A1E4F),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['name'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text(data['text'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white)),
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

          // ---------------- INPUT ----------------
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.3),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.message, color: Colors.white54),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Escribe un mensaje...",
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF6A4CFF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
