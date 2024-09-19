import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../widgets/timeline_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 現在の認証済みユーザー情報を取得
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final String username =
      FirebaseAuth.instance.currentUser!.displayName ?? "ユーザーA";

  bool hasFood = false;
  int feedCount = 0; // feed_countの値を保持する変数

  @override
  void initState() {
    super.initState();
    _getFeedCount(); // 初期化時にfeed_countを取得して判定
  }

  // Firestoreからfeed_countを取得する関数
  Future<void> _getFeedCount() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('communities')
          .doc('9lDWqOZfKMrIXd05Z6Kv')
          .get();
      if (doc.exists) {
        setState(() {
          // feed_countを更新し、画面の再描画を行う
          feedCount = (doc.data() as Map<String, dynamic>)['feed_count'] ?? 0;
        });
      }
    } catch (e) {
      print("feed_countの取得に失敗しました: $e");
    }
  }

  // feed_countに基づいてクラゲの画像を選択する関数
  String _getKurageImage() {
    if (feedCount >= 0 && feedCount <= 5) {
      return 'images/yowakurage.gif';
    } else if (feedCount >= 6 && feedCount <= 10) {
      return 'images/nomalkurage.gif';
    } else {
      return 'images/mukikurage.gif';
    }
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
        int currentFeedCount = (data['feed_count'] ?? 0);
        int newFeedCount = currentFeedCount + 1;

        // feed_countが5→6または10→11に変わるタイミングでのみクラゲ画像を再描画
        if ((currentFeedCount == 5 && newFeedCount == 6) ||
            (currentFeedCount == 10 && newFeedCount == 11)) {
          setState(() {
            feedCount = newFeedCount; // feed_countを更新して画像を再描画
          });
        } else {
          // 通常のfeed_countの更新
          feedCount = newFeedCount;
        }

        transaction.update(docRef, {'feed_count': newFeedCount});
      });

      print("feed_countを+1しました");
    } catch (e) {
      print("feed_countの更新に失敗しました: $e");
    }
  }

  // クラゲに餌をあげる処理
  void _feedKurage() async {
    if (hasFood) {
      setState(() {
        hasFood = false;
      });
      print("クラゲに餌をあげました！");
      await _incrementFeedCount(); // feed_countを更新し、画像の再判定を行う
    }
  }

  // Firestoreにイベントを投稿する処理
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像を配置
          Positioned.fill(
            child: Image.asset(
              'images/sea.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // クラゲのアニメーション画像を配置 (feed_countに基づく画像)
          Positioned(
            right: 10,
            top: 100,
            child: Container(
              width: 600,
              height: 600,
              child: Image.asset(
                _getKurageImage(), // 初回取得時に判定されたクラゲ画像を表示
                fit: BoxFit.contain,
              ),
            ),
          ),
          // TimelineWidgetを配置し、displayNameを渡す
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TimelineWidget(displayName: username),
            ),
          ),
          // 餌をあげるボタンを配置
          Positioned(
            bottom: 120,
            left: 10,
            child: ElevatedButton(
              onPressed: hasFood ? _feedKurage : null,
              child: Text('餌をあげる'),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasFood ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          // ジムを記録するボタンを配置
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
    );
  }
}
