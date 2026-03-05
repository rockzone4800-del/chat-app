import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/presence_service.dart';
import 'chat_list_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _presenceService = PresenceService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          _presenceService.updatePresence(isOnline: true);
          return const ChatListScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
