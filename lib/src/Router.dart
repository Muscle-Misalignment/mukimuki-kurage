import 'dart:math'; // 回転のために追加
import 'package:flutter/material.dart';
import 'package:watnowhackthon20240918/screens/home_screen.dart';
import 'package:watnowhackthon20240918/screens/user_screen.dart';
import 'package:watnowhackthon20240918/screens/userlist_screen.dart';

class PageRouter extends StatefulWidget {
  const PageRouter({super.key});

  @override
  State<PageRouter> createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter>
    with SingleTickerProviderStateMixin {
  // 各画面のリスト
  static final _screens = [HomeScreen(), const UserlistScreen(), UserScreen()];
  // 選択されている画面のインデックス
  int _selectedIndex = 0;
  bool _isDelayActive = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _addDelay();
  }

  void _addDelay() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _isDelayActive = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (_isDelayActive)
            Stack(
              children: [
                Positioned.fill(
                  // 背景画像を表示
                  child: Image.asset(
                    'images/sea.jpg', // 背景画像のパス
                    fit: BoxFit.cover, // 画面全体にフィット
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 回転する画像
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _controller.value * 2 * pi,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'images/yowakurage_seisiga.PNG', // 回転する画像のパス
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 20), // 回転画像とテキストの間にスペースを追加
                      // 静止しているテキスト
                      const Text(
                        'Loading, please wait...', // 表示するテキスト
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // テキストの色
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
