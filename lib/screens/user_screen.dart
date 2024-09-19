import 'package:flutter/material.dart';
import 'package:watnowhackthon20240918/auth/firestore_kurage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserScreen extends StatelessWidget {
  final String uid;
  const UserScreen({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<DocumentSnapshot<Object?>>(
          future: getCurrentUser(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("ちょい待ち"));
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(child: Text('エラーが発生しました'));
            } else if (snapshot.hasData && snapshot.data != null) {
              final photoURL = snapshot.data!['photoURL'];
              final username = snapshot.data!['username'];
              return Center(
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
              );
            } else {
              return const Text('データがありません');
            }
          },
        ));
  }
}
