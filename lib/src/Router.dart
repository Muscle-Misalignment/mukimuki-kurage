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
  static final _screens = [HomeScreen(), const UserlistScreen(), UserScreen()];
  // 選択されている画面のインデックス
  int _selectedIndex = 0;
  bool _isDelayActive = false;

  @override
  void initState() {
    super.initState();
    _addDelay();
  }

  void _addDelay() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isDelayActive = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (_isDelayActive)
            Container(
              color: Colors.white, // ローディング中の背景を白に変更
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFDEA5),

        // タップされたタブのインデックスを設定（タブ毎に画面の切り替えをする）
        onTap: (int index) async {
          setState(() {
            _isDelayActive = true;
            _selectedIndex = index;
          });
          _addDelay(); // タブ切り替え時に遅延を追加
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
        ],
      ),
    );
  }
}
