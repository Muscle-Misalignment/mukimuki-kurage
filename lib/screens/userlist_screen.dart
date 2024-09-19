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
      final users = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>);
      return users.toList();

    } catch (e) {
      print('Error fetching users: $e');
    return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
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
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['username']),
                  subtitle: Text(user['community']),
                  leading:  CircleAvatar(
                          backgroundImage: NetworkImage(user['photoURL']),
                          onBackgroundImageError: (_, __) {
                          // エラーが発生した場合の処理
                          const Icon(Icons.account_circle);
                        },
                        ),
                );
              },
            );
          }
        },
      ),
    );
  }
}