import 'package:flutter/material.dart';

import '../language_service.dart';
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

  final _homeKey = GlobalKey<HomeScreenState>();
  final _historyKey = GlobalKey<HistoryScreenState>();

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      // 홈 탭으로 돌아올 때마다 최근 기록 미리보기를 다시 불러온다.
      _homeKey.currentState?.reload();
    } else if (index == 1) {
      // 최근 기록 탭으로 돌아올 때마다 최신 목록을 다시 불러온다.
      _historyKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    // LanguageService 를 구독해서, 언어 설정이 바뀌면 탭 라벨과 각 탭 화면이
    // 앱을 재시작하지 않아도 바로 새 언어로 다시 그려지게 한다.
    // (HomeScreen/MenuScreen 을 여기서 매번 새로 만들어야 실제로 다시 그려진다.
    //  const 로 캐싱해두면 Flutter 가 동일 인스턴스로 보고 재빌드를 건너뛴다.)
    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        final language = LanguageService.instance.current;
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(key: _homeKey, onViewAllHistory: () => _onTap(1)),
              HistoryScreen(key: _historyKey),
              MenuScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTap,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: language.homeLabel,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history),
                label: language.historyLabel,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu),
                label: language.menuLabel,
              ),
            ],
          ),
        );
      },
    );
  }
}
