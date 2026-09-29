import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../language_service.dart';
import '../tts_service.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'signage_screen.dart';

/// 떠 있는 알약 모양 하단 바([_BottomNav])의 실제 높이/바닥 여백.
/// [_BottomNav] 가 이 값들을 쓴다.
const double kBottomNavHeight = 74;
const double kBottomNavMargin = 12;

/// 본문은 하단 바 뒤로 이어지지 않는다(extendBody 를 쓰지 않는다).
/// 마지막 항목이 바에 딱 붙지 않을 만큼만 띄운다.
double bottomNavInset(BuildContext context) => 16;

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  /// IndexedStack 상의 실제 탭(홈=0/표지판=1/기록=2/메뉴=3) 인덱스.
  /// 하단 바 가운데 카메라 버튼은 화면 전환이 아니라 카메라를 여는 동작이라
  /// 이 인덱스에 포함되지 않는다.
  int _currentIndex = 0;

  static const _homeTab = 0;
  static const _historyTab = 2;

  final _homeKey = GlobalKey<HomeScreenState>();
  final _historyKey = GlobalKey<HistoryScreenState>();

  void _switchTab(int index) {
    // IndexedStack 은 탭을 바꿔도 이전 탭을 dispose 하지 않아 음성이 계속 나온다.
    // 같은 탭을 다시 눌러도 멈추는 게 맞아서 인덱스 비교 없이 항상 멈춘다.
    TtsService.instance.stop();
    setState(() => _currentIndex = index);
    // 홈(최근 분석)·기록 탭으로 돌아올 때마다 최신 기록을 다시 불러온다.
    if (index == _homeTab) _homeKey.currentState?.reload();
    if (index == _historyTab) _historyKey.currentState?.reload();
  }

  Future<void> _openCamera() async {
    TtsService.instance.stop();
    // 결과 화면의 "홈으로"/"분석 데이터" 버튼을 누르면 카메라 화면이 이 값을
    // 들고 pop 된다 — 새 화면을 쌓지 않고, 카메라를 닫은 뒤 그 탭으로 바꾼다.
    final destination = await Navigator.of(context)
        .push<PostCaptureDestination?>(
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
    // 카메라에서 새로 찍은 기록이 바로 보이게 한다.
    _homeKey.currentState?.reload();
    _historyKey.currentState?.reload();
    switch (destination) {
      case PostCaptureDestination.home:
        _switchTab(_homeTab);
      case PostCaptureDestination.history:
        _switchTab(_historyTab);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // LanguageService 를 구독해서, 언어 설정이 바뀌면 탭 라벨과 각 탭 화면이
    // 앱을 재시작하지 않아도 바로 새 언어로 다시 그려지게 한다.
    // (각 탭 화면을 여기서 매번 새로 만들어야 실제로 다시 그려진다.
    //  const 로 캐싱해두면 Flutter 가 동일 인스턴스로 보고 재빌드를 건너뛴다.)
    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        final language = LanguageService.instance.current;
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(
                key: _homeKey,
                onViewAllHistory: () => _switchTab(_historyTab),
              ),
              SignageScreen(),
              HistoryScreen(key: _historyKey),
              MenuScreen(),
            ],
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: _currentIndex,
            onTabTap: _switchTab,
            onCameraTap: _openCamera,
            cameraLabel: language.analyzeTabLabel,
            items: [
              (Icons.home_outlined, language.homeLabel),
              (Icons.warning_amber_rounded, language.signageLabel),
              (Icons.schedule, language.historyTabLabel),
              (Icons.menu, language.menuLabel),
            ],
          ),
        );
      },
    );
  }
}

/// 둥근 알약 모양의 하단 바. 탭 4개 사이 가운데에 틸색 카메라 버튼이 있다.
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTabTap,
    required this.onCameraTap,
    required this.cameraLabel,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTabTap;
  final VoidCallback onCameraTap;
  final String cameraLabel;

  /// 탭 순서대로 (아이콘, 라벨). 앞 두 개는 카메라 왼쪽, 뒤 두 개는 오른쪽.
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    Widget tab(int index) {
      final (icon, label) = items[index];
      return Expanded(
        child: _NavItem(
          icon: icon,
          label: label,
          selected: index == currentIndex,
          onTap: () => onTabTap(index),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, kBottomNavMargin),
        child: Container(
          height: kBottomNavHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(37),
            border: Border.all(color: AppColors.borderStrong),
            // 뒤로 지나가는 내용과 구분되도록 옅은 그림자를 준다.
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              tab(0),
              tab(1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Tooltip(
                  message: cameraLabel,
                  child: Material(
                    color: AppColors.brand,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onCameraTap,
                      child: const SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(
                          Icons.photo_camera_outlined,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              tab(2),
              tab(3),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.textPrimary : AppColors.textMuted;
    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
