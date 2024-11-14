import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserlistScreen extends StatefulWidget {
  const UserlistScreen({Key? key}) : super(key: key);

  @override
  _UserlistScreenState createState() => _UserlistScreenState();
}

class _UserlistScreenState extends State<UserlistScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      final users =
          querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>);
      return users.toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          } else {
            final users = snapshot.data!;
            return Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'images/sea.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        color: const Color(0xB6DFFFFF),
                        margin: const EdgeInsets.only(
                            top: 20, left: 10, right: 10, bottom: 10),
                        elevation: 8, // 影の離れ具合
                        shadowColor: Colors.black, // 影の色
                        shape: RoundedRectangleBorder(
                          // 枠線を変更できる
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(user['username']),
                              subtitle: Text(user['goal']),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(user['photoURL']),
                                onBackgroundImageError: (_, __) {
                                  // エラーが発生した場合の処理
                                  const Icon(Icons.account_circle);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
