import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:watnowhackthon20240918/auth/sign_in_page.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}


class _UserScreenState extends State<UserScreen> {

// Firestoreにデータを追加する関数
Future<void> addGoalToFirestore(String userId, String goal) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).set({
    'uId': userId,
    'goal': goal,
  }, SetOptions(merge: true));
}

  // インスタンスメンバー
  late final String userId;
  late final String username;
  late final String photoURL;
  late final TextEditingController goalController;
  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    username = FirebaseAuth.instance.currentUser!.displayName ?? "Anonymous";
    photoURL = FirebaseAuth.instance.currentUser!.photoURL ?? "https://example.com";

    goalController = TextEditingController(text: "",);

    FirebaseFirestore.instance.collection('users').doc(userId).get().then((doc) {
      if (doc.exists) {
        setState(() {
          goalController.text = doc.data()?['goal'] ?? "";
        });
      }
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0), // 角を丸める半径を指定
                        child: Container(
                          width: 200,
                          height: 50,
                          color: const Color(0xB6DFFFFF),
                        ),
                      ),
                      Text(
                        username,
                        style: const TextStyle(fontSize: 30),
                      )
                    ]
                  ),
                ],
              ),
              const SizedBox(height: 20), // スペースを追加
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: goalController,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                    labelText: '目標',
                  ),
                  onSubmitted: (value) {
                    addGoalToFirestore(userId, value);
                  },
                ),
              ),
              const Spacer(flex: 6),
              ElevatedButton(
                onPressed: _signOut,
                child: Text('サインアウト'),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
