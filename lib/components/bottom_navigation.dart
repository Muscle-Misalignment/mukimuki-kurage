import 'package:flutter/material.dart';
import 'package:watnowhackthon20240918/screens/home_screen.dart';
import 'package:watnowhackthon20240918/screens/user_screen.dart';
import 'package:watnowhackthon20240918/screens/userlist_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
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
    // final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: _screens[_selectedIndex],
      // 本題のNavigationBar
      bottomNavigationBar: NavigationBar(
        // タップされたタブのインデックスを設定（タブ毎に画面の切り替えをする）
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // 選択されているタブの色（公式サイトのまま黄色）
        indicatorColor: Colors.amber,
        // 選択されたタブの設定（設定しないと画面は切り替わってもタブの色は変わらないです）
        selectedIndex: _selectedIndex,

        // タブ自体の設定
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'userlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Mypage',
          ),
        ],
      ),
    );
  }
}
