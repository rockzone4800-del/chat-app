import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PresenceBadge extends StatelessWidget {
  const PresenceBadge({super.key, required this.peerId});

  final String peerId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(peerId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final isOnline = data['online'] as bool? ?? false;
        final lastSeen = (data['lastSeen'] as Timestamp?)?.toDate();

        final statusText = isOnline
            ? 'online'
            : lastSeen == null
                ? 'offline'
                : 'last seen ${DateFormat('MMM d, hh:mm a').format(lastSeen)}';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              color: isOnline ? Colors.greenAccent : Colors.white70,
              size: 10,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                statusText,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
