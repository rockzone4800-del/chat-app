import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  UserService._();

  static final instance = UserService._();

  final _db = FirebaseFirestore.instance;

  Future<void> upsertCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'phone': user.phoneNumber,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> findUserByPhone(String phone) async {
    final query = await _db.collection('users').where('phone', isEqualTo: phone).limit(1).get();
    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }
}
