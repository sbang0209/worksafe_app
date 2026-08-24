import 'package:flutter/material.dart';

import '../language_service.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'menu_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  /// IndexedStack 상의 실제 탭(홈=0/최근기록=1/메뉴=2) 인덱스.
  /// 하단 바의 "카메라" 항목은 화면 전환이 아니라 카메라를 여는 동작이라
  /// 이 인덱스에 포함되지 않는다.
  int _currentIndex = 0;

  final _historyKey = GlobalKey<HistoryScreenState>();

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      // 최근 기록 탭으로 돌아올 때마다 최신 목록을 다시 불러온다.
      _historyKey.currentState?.reload();
    }
  }

  Future<void> _openCamera() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CameraScreen()));
  }

  /// 하단 바에는 홈/카메라/최근기록/메뉴 4개가 보이지만, 카메라는 탭이 아니라
  /// 동작이라서 [_currentIndex] 와 하단 바에 보여줄 선택 인덱스가 다르다.
  /// 홈=0, 카메라=1, 최근기록=2, 메뉴=3 순.
  int get _navBarIndex => _currentIndex == 0 ? 0 : _currentIndex + 1;

  void _onNavTap(int navIndex) {
    switch (navIndex) {
      case 0:
        _switchTab(0);
        break;
      case 1:
        _openCamera();
        break;
      case 2:
        _switchTab(1);
        break;
      case 3:
        _switchTab(2);
        break;
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
              HomeScreen(),
              HistoryScreen(key: _historyKey),
              MenuScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.amber.shade800,
            unselectedItemColor: Colors.grey.shade500,
            currentIndex: _navBarIndex,
            onTap: _onNavTap,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: language.homeLabel,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.camera_alt),
                label: language.cameraLabel,
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
