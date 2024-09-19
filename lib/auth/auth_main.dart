import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:watnowhackthon20240918/auth/next_page.dart';
import 'package:watnowhackthon20240918/auth/firestore_kurage.dart';

// google認証
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseUserのログイン状態が確定するまで待つ
  final firebaseUser = await FirebaseAuth.instance.userChanges().first;
  runApp(MyApp());
}

//ログインしてたらNextPageに遷移、してなかったらSignInPageに遷移
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter app',
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // スプラッシュ画面などに書き換えても良い
              return const SizedBox(
                child: Text("ちょい待ち"),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              // User が null でなない、つまりサインイン済みのホーム画面へ
              final String uid = snapshot.data!.uid;
              final String username =
                  snapshot.data!.displayName ?? "Unknown User";
              final String photoURL =
                  snapshot.data!.photoURL ?? "https://example.com";
              debugPrint("uid : $uid");
              registerUser(uid, username, photoURL);
              return NextPage(uid: uid);
            }
            // User が null である、つまり未サインインのサインイン画面へ
            return const SignInPage(title: 'Flutter app');
          },
        ),
      );
}

// サインイン画面
class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.title});
  final String title;
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // FlutterFireの公式ドキュメントのコードをそのまま使う!
  Future<UserCredential> signInWithGoogle() async {
    // 認証フローを起動する
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception("googleAuth is not authenticated");
    }
    // リクエストから認証の詳細を取得する
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    if (googleAuth == null) {
      throw Exception("googleAuth is not authenticated");
    }
    // 新しいクレデンシャルを作成する
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    //Firebase 認証
    final authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = authResult.user;
    if (user == null) {
      throw Exception("User is not authenticated");
    }
    final String uid = user.uid;
    final String username = user.displayName ?? "anonymous";
    final String photoURL = user.photoURL ?? "https://example.com";
    registerUser(uid, username, photoURL);
    // NextPageへ画面遷移する
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NextPage(uid: uid)));
    // サインインしたら、UserCredential を返す。
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

//googleサインインボタンが表示され、押すとsignInWithGoogle関数が実行される
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ここでGoogleSignInの関数を実行する
            Container(
              width: 200,
              height: 30,
              child: SignInButton(Buttons.google, onPressed: () {
                signInWithGoogle();
              }),
            )
          ],
        ),
      ),
    );
  }
}
