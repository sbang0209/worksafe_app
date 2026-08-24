import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../language_service.dart';
import '../main.dart' show bootstrap;
import 'login_screen.dart';

/// 앱을 켰을 때 가장 먼저 뜨는 화면.
///
/// 보여지는 동안 [bootstrap] 으로 초기화(.env, 카메라 목록)를
/// 수행하고, 초기화가 그보다 빨리 끝나도 [_minimumDisplay] 만큼은 화면을 유지한
/// 뒤 로그인 화면으로 넘어간다. 전환은 pushReplacement 라 뒤로가기로 돌아올 수 없다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// 초기화가 순식간에 끝나도 스플래시가 깜빡이고 사라지지 않도록 하는 최소 노출 시간.
  static const _minimumDisplay = Duration(milliseconds: 1700);

  static const _fadeDuration = Duration(milliseconds: 700);

  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: _fadeDuration,
  )..forward();

  @override
  void initState() {
    super.initState();
    _startup();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// 초기화와 최소 노출 시간을 동시에 기다린다 — 둘 중 늦게 끝나는 쪽이 기준이 된다.
  Future<void> _startup() async {
    await Future.wait([bootstrap(), Future<void>.delayed(_minimumDisplay)]);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.banner],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 96,
                  color: AppColors.accentDark,
                ),
                const SizedBox(height: 20),
                Text(
                  'WorkSafe',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.accentDark,
                  ),
                ),
                const SizedBox(height: 12),
                // 슬로건은 현재 언어의 것 하나만 보여준다 (한국어면 한국어, 영어면 영어).
                Text(
                  LanguageService.instance.current.appSlogan,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
