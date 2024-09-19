import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserScreen extends StatelessWidget {
  UserScreen({super.key});

  // 現在の認証済みユーザー
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final String username =
      FirebaseAuth.instance.currentUser!.displayName ?? "ユーザーA";
  final String photoURL =
      FirebaseAuth.instance.currentUser!.photoURL ?? "https://example.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          const Spacer(flex: 2),
          Align(
            alignment: const Alignment(0.0, 0.0),
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(photoURL),
            ),
          ),
          const Spacer(flex: 1),
          Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 追加
                  children: [
                Text(
                  username,
                  style: const TextStyle(fontSize: 30),
                ),
                const Icon(Icons.edit),
              ])),
          const Spacer(flex: 6),
        ],
      ),
    ));
  }
}
