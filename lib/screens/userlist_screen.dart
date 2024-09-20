import 'package:flutter/material.dart';

class UserlistScreen extends StatefulWidget {
  const UserlistScreen({Key? key}) : super(key: key);

  @override
  _UserlistScreenState createState() => _UserlistScreenState();
}

class _UserlistScreenState extends State<UserlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー一覧'),
      ),
      body: const Center(
        child: Text('ユーザー一覧画面'),
      ),
    );
  }
}