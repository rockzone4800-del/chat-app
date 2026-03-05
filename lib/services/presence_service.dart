import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_service.dart';

class PresenceService {
  final _db = FirebaseFirestore.instance;

  Future<void> updatePresence({required bool isOnline}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await UserService.instance.upsertCurrentUser();
    await _db.collection('users').doc(user.uid).set({
      'online': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
