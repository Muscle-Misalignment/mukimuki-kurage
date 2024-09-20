import 'package:flutter/material.dart';
import 'package:watnowhackthon20240918/screens/home_screen.dart';
import 'package:watnowhackthon20240918/screens/user_screen.dart';
import 'package:watnowhackthon20240918/screens/userlist_screen.dart';

class PageRouter extends StatefulWidget {
  const PageRouter({super.key});

  @override
  State<PageRouter> createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter> {
  // 各画面のリスト
  static final _screens = [
    HomeScreen(),
    const UserlistScreen(),
    UserScreen()
  ];
  // 選択されている画面のインデックス
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFDEA5),

        // タップされたタブのインデックスを設定（タブ毎に画面の切り替えをする）
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // 選択されているタブの色
        selectedItemColor: const Color.fromARGB(255, 252, 182, 97),
        // 選択されたタブの設定
        currentIndex: _selectedIndex,
        // タブ自体の設定
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'userlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'my page',
          ),
          // 他のタブも同様に追加
        ],
      ),
    );
  }
}