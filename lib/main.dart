import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'src/router.dart'; // ルーティングをインポート
import 'auth/sign_in_page.dart'; // サインインページをインポート
import 'firebase_options.dart';
import 'package:watnowhackthon20240918/auth/firestore_kurage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'タイムラインアプリ',
      home: AuthWrapper(), // ログイン状態に基づき表示を切り替える
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // ローディング画面
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // ログイン済みのユーザーがいる場合、HomeScreenに遷移
          final user = snapshot.data!;
          final String uid = user.uid;
          final String username = user.displayName!;
          final String photoURL = user.photoURL!;

          registerUser(uid, username, photoURL);

          return const PageRouter();
        }
        // ログインしていない場合、SignInPageに遷移
        return SignInPage();
      },
    );
  }
}
