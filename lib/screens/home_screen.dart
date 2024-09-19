import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/timeline_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:watnowhackthon20240918/screens/user_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 現在の認証済みユーザー
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final String username =
      FirebaseAuth.instance.currentUser!.displayName ?? "ユーザーA";

  int _selectedIndex = 0;
  bool hasFood = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Firestoreでのfeed_countのフィールドを+1する処理
  Future<void> _incrementFeedCount() async {
    try {
      DocumentReference docRef =
          _firestore.collection('communities').doc('9lDWqOZfKMrIXd05Z6Kv');

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception("ドキュメントが存在しません");
        }
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int newFeedCount = (data['feed_count'] ?? 0) + 1;
        transaction.update(docRef, {'feed_count': newFeedCount});
      });

      print("feed_countを+1しました");
    } catch (e) {
      print("feed_countの更新に失敗しました: $e");
    }
  }

  Future<void> _postEvent() async {
    String message = 'ジムに行きました！';
    try {
      await _firestoreService.addEvent(userId, username, message);
      print("Firestoreにイベントを追加しました。");

      setState(() {
        hasFood = true;
      });
    } catch (error) {
      print("Firestoreへの書き込みエラー: $error");
    }
  }

  void _feedJellyfish() async {
    if (hasFood) {
      setState(() {
        hasFood = false;
      });
      print("クラゲに餌をあげました！");
      await _incrementFeedCount();
    }
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
          Positioned(
            right: 10,
            top: 100,
            child: Container(
              width: 600,
              height: 600,
              child: Image.asset(
                'images/mukikurage.gif',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TimelineWidget(),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 10,
            child: ElevatedButton(
              onPressed: hasFood ? _feedJellyfish : null,
              child: Text('餌をあげる'),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasFood ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 10,
            child: ElevatedButton(
              onPressed: _postEvent,
              child: Text('ジムを記録'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFFDEA5),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_list), label: 'userlist'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'my page',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 252, 182, 97),
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserScreen()),
            );
          }
        },
      ),
    );
  }
}
