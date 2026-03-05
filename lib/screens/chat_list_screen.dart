import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _newChatController = TextEditingController();

  @override
  void dispose() {
    _newChatController.dispose();
    super.dispose();
  }

  Future<void> _startChatByPhone() async {
    final input = _newChatController.text.trim();
    if (input.isEmpty) return;

    final userDoc = await UserService.instance.findUserByPhone(input);
    if (!mounted) return;

    if (userDoc == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User not found for that phone.')));
      return;
    }

    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    if (userDoc.id == currentUid) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cannot chat with yourself.')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(peerId: userDoc.id, peerPhone: input),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: AuthService.instance.signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newChatController,
                    decoration: const InputDecoration(
                      hintText: 'Start chat by phone (+15551234567)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _startChatByPhone, child: const Text('Open')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ChatService.instance.chatListStream(currentUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No conversations yet.'));
                }

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final chat = docs[index].data();
                    final participants = (chat['participants'] as List).cast<String>();
                    final peerId = participants.firstWhere((id) => id != currentUid);
                    final phones = (chat['participantPhones'] as Map<String, dynamic>? ?? {});
                    final peerPhone = phones[peerId] as String? ?? 'Unknown';
                    final lastMessage = chat['lastMessage'] as String? ?? '';
                    final lastMessageAt = (chat['lastMessageAt'] as Timestamp?)?.toDate();
                    final timeLabel = lastMessageAt == null
                        ? ''
                        : DateFormat('hh:mm a').format(lastMessageAt);

                    return ListTile(
                      tileColor: Colors.white,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF25D366),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(peerPhone),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(timeLabel, style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(peerId: peerId, peerPhone: peerPhone),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
