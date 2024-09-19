import 'package:flutter/material.dart';

void main() => runApp(MyApp()); // 引数のWidgetが全画面表示される

// 最初に表示するWidgetのクラス
class MyApp extends StatelessWidget {
  // StatelessWidgetを継承
  @override
  Widget build(BuildContext context) {
    //buildメソッドでUIを作成
    return MaterialApp(
      // マテリアルデザインのアプリ
      title: "My Simple App", // アプリのタイトル
      home: Scaffold(
        // マテリアルデザインの土台
        appBar: AppBar(
          // ヘッダーに表示するアプリケーションバー
          title: Text("好きなタイトル"), // タイトルを表示
        ),
        body: Center(
          // 中央に配置
          child: Text("文字入力してください"), // 文字列を配置
        ), //　Center
      ), //　Scaffold
    ); //　MaterialApp
  } //　Widget build(BuildContext context)
}  //　class MyApp
