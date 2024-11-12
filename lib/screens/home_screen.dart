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
  int kurageLevel = 1;
  bool isGrowth = false;

//クラゲの成長度（１が一番小さい）
  int previouskurageLevel = 1;

  // ランダムに選ばれるジムのメッセージのリスト
  final List<String> gymMessages = ["ジムに行ったゾ！"];

  // ランダムに選ばれる吹き出しのメッセージのリスト
  final List<String> bubbleMessages = [
    "明日もジムだッ！",
    "プロテイン飲めよ！",
    "ご飯たべろよ！",
    "よくがんばった！",
    "ちゃんとねろよ！"
  ];

  @override
  void initState() {
    super.initState();
    _getFeedCount();
    _getKurageLevel();
  }

  Future<void> _getKurageLevel() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('communities')
          .doc('9lDWqOZfKMrIXd05Z6Kv')
          .get();
      if (doc.exists) {
        setState(() {
          kurageLevel =
              (doc.data() as Map<String, dynamic>)['kurage_level'] ?? 1;
        });
      }
    } catch (e) {
      print("kurage_levelの取得に失敗しました: $e");
    }
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
    String kurageImagePath;

    if (feedCount >= 0 && feedCount <= 5) {
      kurageLevel = 1;
      kurageImagePath = 'images/yowakurage.gif';
    } else if (feedCount >= 6 && feedCount <= 10) {
      kurageLevel = 2;
      kurageImagePath = 'images/nomalkurage.gif';
    } else {
      kurageLevel = 3;
      kurageImagePath = 'images/mukikurage.gif';
    }
    print("kurage_level:$kurageLevel");
    print("previoskurage_level:$previouskurageLevel");

    if (previouskurageLevel != kurageLevel) {
      previouskurageLevel = kurageLevel;
      isGrowth = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isGrowth == true) {
          String image_path;
          if (kurageLevel == 1) {
            image_path = "images/yowakurage.gif";
          } else if (kurageLevel == 2) {
            image_path = "images/nomalkurage.gif";
          } else {
            image_path = "images/mukikurage.gif";
          }
          print("kurage_level:$kurageLevel");
          print("previoskurage_level:$previouskurageLevel");
          kurageGrowthShowAlertDialog(context,
              image_path: image_path, content: "");
          print("isGrowth:$isGrowth");
        }
      });
    }
    return kurageImagePath;
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

  void _showGymMemoDialog() async {
    String gymMemo = '';

    // ダイアログを表示
    await showDialog(
      context: context,
      barrierDismissible: false, // 外側タップで閉じないようにする
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: 311.0, // ダイアログの横幅を指定
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 3),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 子要素に合わせた縦幅
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'ひとこと追加', // ダイアログタイトル
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    onChanged: (value) {
                      gymMemo = value; // ユーザーが入力したメモを保持
                    },
                    decoration: InputDecoration(hintText: "例) 脚トレ最高！"),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          width: 1.0,
                          color: Colors.blueAccent,
                        ),
                        shadowColor: Colors.grey,
                        elevation: 5,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // キャンセルでダイアログを閉じる
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                        child: Text('キャンセル'),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        shadowColor: Colors.grey,
                        elevation: 5,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () async {
                        if (gymMemo.isNotEmpty) {
                          // メモが入力されていれば、Firestoreに保存
                          await _postEventWithMemo(gymMemo);
                          Navigator.of(context).pop(); // ダイアログを閉じる
                        }
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                        child: Text('完了'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        );
      },
    );
  }

  // タイムラインに投稿するイベントをfirestoreに格納
  // メモを追加してイベントをFirestoreに保存
  Future<void> _postEventWithMemo(String gymMemo) async {
    if (isPosting) return; // 投稿中なら処理をスキップ

    setState(() {
      isPosting = true; // 投稿中のフラグを立てる
    });

    // ランダムなジムメッセージを取得
    String message = _getRandomGymMessage();

    try {
      // Firestoreにメモを含めてイベントを追加
      await _firestoreService.addEventWithMemo(
          userId, username, message, gymMemo);
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

  //くらげが成長したときに表示するダイアログ
  Future kurageGrowthShowAlertDialog(
    context, {
    required String image_path,
    required String content,
  }) async {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              width: 311.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Image.asset(
                        image_path,
                        height: 200, //写真の高さ指定
                        fit: BoxFit.cover, //写真が周りに目一杯広がるようにする
                      )),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "くらげがレベル$kurageLevelに成長した！\nマッスルマッスル!",
                    ),
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.grey,
                          elevation: 5,
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 36),
                          child: Text('OK'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                ],
              ),
            ),
          );
        });
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
              child: Text(
                '餌をあげる',
                style: TextStyle(
                  color: Color(0xFF696969), // テキストの色をグレーに変更
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    hasFood ? Color(0xFFFFDEA5) : Colors.grey, // ボタンの色を変更
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 10,
            child: ElevatedButton(
              onPressed: isPosting ? null : _showGymMemoDialog, // 投稿中は無効化
              child: isPosting
                  ? CircularProgressIndicator()
                  : Text(
                      'ジムを記録',
                      style: TextStyle(
                        color: Color(0xFF696969), // テキストの色をグレーに変更
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFDEA5), // ボタンの背景色を変更
              ),
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
