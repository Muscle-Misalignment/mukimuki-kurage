import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:watnowhackthon20240918/auth/firestore_kurage.dart';

// NextPageクラス
//getcommunityGrowthメソッドを使って、ユーザーの成長値を取得して表示する
class NextPage extends StatelessWidget {
  final String? uid;
  const NextPage({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FibaseAuthを使えるようにする変数
    final _auth = FirebaseAuth.instance;

    return Scaffold(
        appBar: AppBar(
          // AppBarに表示されるデフォルトのボタンを非表示にする!
          automaticallyImplyLeading: false,
          actions: [
            // ここで、ログアウトするメソッド実行する!
            IconButton(
                onPressed: () async {
                  await _auth.signOut();
                  // 前のページへ戻るコード
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back))
          ],
          title: Text('GoogleSignInしました!'),
        ),
        body: Row(
          children: [
            Center(
              child: FutureBuilder<int?>(
                  future: getCommunityGrowth(uid),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("ちょい待ち");
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Text('エラーが発生しました');
                    } else {
                      final data = snapshot.data;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("ようこそ"),
                            Text("あなたの成長値は$dataです")
                          ],
                        ),
                      );
                    }
                  })),
            )
          ],
        ));
  }
}
