import 'dart:math'; // ランダムな文章を選ぶために追加
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

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final String username =
      FirebaseAuth.instance.currentUser!.displayName ?? "ユーザーA";

  bool hasFood = false;
  int feedCount = 0;
  bool isPosting = false; // 投稿中かどうかのフラグ
  bool showBubble = false; // クラゲの吹き出しを表示するかどうか
  double bubbleOpacity = 0.0; // 吹き出しの透明度
  String bubbleMessage = "ご飯ありがとう！"; // 吹き出しに表示するメッセージ

  // ランダムに選ばれるジムのメッセージのリスト
  final List<String> gymMessages = [
    "ジムでムキｯ",
    "肩がメロン！",
    "ナイスバルク！",
    "ぷるぷるしてる！",
    "パンプがすごい！",
    "プロテインが体にしみる！",
    "筋肉がよろこんでる！"
  ];

  // ランダムに選ばれる吹き出しのメッセージのリスト
  final List<String> bubbleMessages = [
    "明日もジムだッ！",
    "プロテイン飲めよ！",
    "ご飯たべろよ！",
    "よくがんばった！",
  ];

  @override
  void initState() {
    super.initState();
    _getFeedCount();
  }

  Future<void> _getFeedCount() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('communities')
          .doc('9lDWqOZfKMrIXd05Z6Kv')
          .get();
      if (doc.exists) {
        setState(() {
          feedCount = (doc.data() as Map<String, dynamic>)['feed_count'] ?? 0;
        });
      }
    } catch (e) {
      print("feed_countの取得に失敗しました: $e");
    }
  }

  String _getKurageImage() {
    if (feedCount >= 0 && feedCount <= 5) {
      return 'images/yowakurage.gif';
    } else if (feedCount >= 6 && feedCount <= 10) {
      return 'images/nomalkurage.gif';
    } else {
      return 'images/mukikurage.gif';
    }
  }

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

        setState(() {
          feedCount = newFeedCount;
        });

        transaction.update(docRef, {'feed_count': newFeedCount});
      });

      print("feed_countを+1しました");
    } catch (e) {
      print("feed_countの更新に失敗しました: $e");
    }
  }

  void _feedKurage() async {
    if (hasFood) {
      setState(() {
        hasFood = false;
        // ランダムな吹き出しメッセージを選択
        bubbleMessage = _getRandomBubbleMessage();
      });
      // 吹き出しの透明度を変更して表示
      _showKurageBubble();

      await _incrementFeedCount();
    }
  }

  // 吹き出しの透明度を変更して表示・非表示にする処理
  void _showKurageBubble() {
    setState(() {
      bubbleOpacity = 1.0;
    });

    // 3秒後に吹き出しを非表示にする
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          bubbleOpacity = 0.0;
        });
      }
    });
  }

  // ランダムにジムのメッセージを選ぶ
  String _getRandomGymMessage() {
    final random = Random();
    return gymMessages[random.nextInt(gymMessages.length)];
  }

  // ランダムに吹き出しメッセージを選ぶ
  String _getRandomBubbleMessage() {
    final random = Random();
    return bubbleMessages[random.nextInt(bubbleMessages.length)];
  }

  Future<void> _postEvent() async {
    if (isPosting) return; // 投稿中なら処理をスキップ

    setState(() {
      isPosting = true; // 投稿中のフラグを立てる
    });

    // ランダムなジムのメッセージを取得
    String message = _getRandomGymMessage();

    try {
      await _firestoreService.addEvent(userId, username, message);
      print("Firestoreにイベントを追加しました。");

      setState(() {
        hasFood = true;
        isPosting = false; // 投稿が終わったらフラグをリセット
      });
    } catch (error) {
      print("Firestoreへの書き込みエラー: $error");

      setState(() {
        isPosting = false; // エラーが発生した場合もフラグをリセット
      });
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
                _getKurageImage(),
                fit: BoxFit.contain,
              ),
            ),
          ),
          // クラゲの吹き出し（ご飯ありがとう）を表示（透明度を使って非表示にする）
          Positioned(
            right: 200, // 吹き出しをクラゲの中心に配置
            top: 250, // クラゲの上部に吹き出しを配置
            child: AnimatedOpacity(
              opacity: bubbleOpacity,
              duration: Duration(milliseconds: 500),
              child: CustomPaint(
                painter: SlantedBubblePainter(), // 吹き出しの尾を描く
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    bubbleMessage, // ランダムに選ばれた吹き出しメッセージを表示
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TimelineWidget(displayName: username),
            ),
          ),
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
          Positioned(
            bottom: 60,
            left: 10,
            child: ElevatedButton(
              onPressed: isPosting ? null : _postEvent, // 投稿中は無効化
              child: isPosting ? CircularProgressIndicator() : Text('ジムを記録'),
            ),
          ),
        ],
      ),
    );
  }
}

// 吹き出しの尾を斜めに描画するカスタムペインター
class SlantedBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path();

    // 斜めの吹き出しの尾を描画
    path.moveTo(size.width / 2 - 20, size.height); // 左端
    path.lineTo(size.width / 2 - 10, size.height + 20); // 尾の左下部分
    path.lineTo(size.width / 2 + 20, size.height); // 右端
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
