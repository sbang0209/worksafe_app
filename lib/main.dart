import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_colors.dart';
import 'language_service.dart';
import 'screens/splash_screen.dart';

/// 사용 가능한 카메라 목록. [bootstrap] 이 채우며, 그 전에는 빈 목록이다.
/// (카메라 화면은 스플래시 이후에만 열 수 있어 항상 채워진 뒤에 읽힌다.)
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 스플래시의 슬로건부터 저장된 언어로 떠야 하므로, 언어만은 첫 프레임 전에 읽는다.
  // (저장소 한 번 읽는 정도라 시작이 눈에 띄게 느려지지 않는다.)
  await LanguageService.instance.init();
  runApp(const WorkSafeApp());
}

/// 앱이 실제로 동작하기 전에 끝나야 하는 준비 작업.
///
/// 화면을 그리기 전이 아니라 스플래시 화면이 떠 있는 동안 호출된다
/// (SplashScreen 참고) — 준비되는 사이 흰 화면이 보이지 않게 하기 위함이다.
/// 언어 설정만은 스플래시 문구 자체에 필요해서 [main] 에서 미리 읽는다.
Future<void> bootstrap() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('.env 를 불러오지 못했습니다: $e');
  }
  try {
    cameras = await availableCameras();
  } catch (e) {
    cameras = [];
    debugPrint('카메라를 불러오지 못했습니다: $e');
  }
}

class WorkSafeApp extends StatelessWidget {
  const WorkSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkSafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
