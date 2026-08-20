import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/main_tab_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  runApp(const WorkSafeApp());
}

class WorkSafeApp extends StatelessWidget {
  const WorkSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkSafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const MainTabScreen(),
    );
  }
}
