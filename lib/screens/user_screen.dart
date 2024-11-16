import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:watnowhackthon20240918/auth/sign_in_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  String sex = ''; // nullable型で初期化
  int age = 0; // 初期値を設定
  String goal = '';
  String mygym = '';
  String mukimukiage = '';
  String community = '';
  String onecomment = '';
  String trainingHistory = ''; // トレーニング歴
  bool isLoading = true; // データ取得中フラグ

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    username = FirebaseAuth.instance.currentUser!.displayName ?? "Anonymous";
    photoURL =
        FirebaseAuth.instance.currentUser!.photoURL ?? "https://example.com";

    // Firestoreからデータを取得
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          sex = doc.data()?['sex'] ?? 'Not Specified';
          goal = doc.data()?['goal'] ?? "";
          age = doc.data()?['age'] ?? 0;
          mygym = doc.data()?['mygym'] ?? "";
          mukimukiage = doc.data()?['mukimukiage'] ?? "";
          community = doc.data()?['community'] ?? "";
          onecomment = doc.data()?['onecomment'] ?? "";
          trainingHistory = doc.data()?['trainingHistory'] ?? ""; // トレーニング歴
          isLoading = false; // データ取得後にisLoadingをfalseに設定
        });
      }
    });
  }

  Future<void> _signOut() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー情報'),
        backgroundColor: Color(0xFFFFDEA5),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/sea.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: isLoading
                ? CircularProgressIndicator() // ローディング中はプログレスインジケータを表示
                : SingleChildScrollView(
                    // スクロール可能にする
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        // ユーザー情報カード
                        Container(
                          width: double.infinity, // 親の幅に合わせる
                          child: Card(
                            margin: EdgeInsets.all(10),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Align(
                                    alignment: const Alignment(0.0, 0.0),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(photoURL),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Text(
                                        username,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // 名前が長すぎる場合に省略
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // ユーザーの詳細情報を表示
                        Container(
                          width: double.infinity, // 親の幅に合わせる
                          child: Card(
                            margin: EdgeInsets.all(10),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: const Text('性別:'),
                                    subtitle: Text(sex),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    title: const Text('年齢:'),
                                    subtitle: Text(age.toString()), // 年齢を表示
                                  ),
                                  const Divider(),
                                  ListTile(
                                    title: const Text('ジム:'),
                                    subtitle: Text(mygym),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    title: const Text('目標:'),
                                    subtitle: Text(goal),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    title: const Text('コメント:'),
                                    subtitle: Text(onecomment),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    title: const Text('トレーニング歴:'),
                                    subtitle: Text(trainingHistory),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    title: const Text('所属コミュニティ:'),
                                    subtitle: Text(community),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
