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

  final TextEditingController goalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'images/sea.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Center(
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 50,
                      color: Colors.blue,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        Text(
                          username,
                          style: const TextStyle(fontSize: 30),
                        ),
                        const Icon(Icons.edit),
                      ]
                    )
                  ]
                )
              ),
              const SizedBox(height: 20), // スペースを追加
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: goalController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '目標を入力してください',
                  ),
                ),
              ),
              const Spacer(flex: 6),
            ],
          ),
        ),
      ],
    ));
  }
}
