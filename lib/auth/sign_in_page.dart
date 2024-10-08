import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:watnowhackthon20240918/auth/firestore_kurage.dart';
import '../src/Router.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Googleサインイン
  Future<UserCredential> signInWithGoogle() async {
    // Google認証フローを開始
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception("Googleサインインに失敗しました");
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Firebaseでのサインイン
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サインイン'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              //googleサインイン
              final authResult = await signInWithGoogle();

              final user = authResult.user;

              final uid = user!.uid;
              final username = user.displayName!;
              final photoURL = user.photoURL!;

              registerUser(uid, username, photoURL);

              // サインインに成功したらホーム画面へ遷移
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PageRouter()),
              );
            } catch (e) {
              print(e);
            }
          },
          child: Text('Googleでサインイン'),
        ),
      ),
    );
  }
}
