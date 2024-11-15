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
  late final String sex;
  late final num age;
  late final String goal;
  late final String mygym;
  late final String mukimukiage;
  late final String community;
  late final String onecomment;

  // late final TextEditingController sexController;
  // late final TextEditingController ageController;
  // late final TextEditingController mygymController;
  // late final TextEditingController mukimukiageController;
  // late final TextEditingController goalController;
  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    username = FirebaseAuth.instance.currentUser!.displayName ?? "Anonymous";

    photoURL =
        FirebaseAuth.instance.currentUser!.photoURL ?? "https://example.com";

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          sex = doc.data()?['sex'] ?? "";
          goal = doc.data()?['goal'] ?? "";
          age = doc.data()?['age'] ?? "";
          mygym = doc.data()?['mygym'] ?? "";
          mukimukiage = doc.data()?['mukimukiage'] ?? "";
          community = doc.data()?['community'] ?? "";
          onecomment = doc.data()?['onecomment'] ?? "";
        });
      }
    });
  }

  Future<void> _signOut() async {
    // GoogleSignInインスタンスを作成
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    // Firebaseサインアウト
    await FirebaseAuth.instance.signOut();

    // Googleサインアウト
    await _googleSignIn.signOut();

    // サインイン画面に遷移
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
          centerTitle: true,
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
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: ElevatedButton(
                  //     onPressed: _signOut,
                  //     child: Text('サインアウト'),
                  //   ),
                  // ),
                  const Spacer(flex: 1),
                  Card(
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                username,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow:
                                    TextOverflow.ellipsis, // 名前が長すぎる場合に省略する
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  //ユーザーの詳細情報を表示
                  const SizedBox(height: 5), // スペースを追加
                  Card(
                    margin: EdgeInsets.all(10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            username,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // 名前が長すぎる場合に省略する
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('性別:'),
                          subtitle: Text(sex),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('年齢'),
                        ),
                      ]),
                    ),
                  ),

                  const Spacer(flex: 5),
                ],
              ),
            ),
          ],
        ));
  }
}
