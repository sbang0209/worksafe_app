import 'package:flutter/material.dart';

import 'history_screen.dart';
import 'home_screen.dart';
import 'menu_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final _historyKey = GlobalKey<HistoryScreenState>();

  late final _screens = [
    const HomeScreen(),
    HistoryScreen(key: _historyKey),
    const MenuScreen(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      // 최근 기록 탭으로 돌아올 때마다 최신 목록을 다시 불러온다.
      _historyKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '최근 기록'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: '메뉴'),
        ],
      ),
    );
  }
}
