import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message.dart';

class ChatService {
  ChatService._();

  static final instance = ChatService._();

  final _db = FirebaseFirestore.instance;

  String _chatId(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return '${ids.first}_${ids.last}';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> chatListStream(String currentUserId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  Stream<List<ChatMessage>> messagesStream(String peerId) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = _chatId(currentUserId, peerId);

    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromDoc).toList());
  }

  Future<void> sendMessage({required String peerId, required String text}) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final chatId = _chatId(currentUser.uid, peerId);
    final chatRef = _db.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();
    final now = FieldValue.serverTimestamp();

    final senderPhone = currentUser.phoneNumber ?? 'Unknown';

    await _db.runTransaction((txn) async {
      txn.set(messageRef, {
        'senderId': currentUser.uid,
        'text': text,
        'createdAt': now,
      });

      txn.set(chatRef, {
        'participants': [currentUser.uid, peerId],
        'participantPhones': {
          currentUser.uid: senderPhone,
        },
        'lastMessage': text,
        'lastMessageAt': now,
      }, SetOptions(merge: true));
    });

    await _db.collection('users').doc(currentUser.uid).set(
      {'phone': senderPhone},
      SetOptions(merge: true),
    );
  }
}
