import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'gemini_service.dart';

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
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;
  String? _capturedPath;

  /// Gemini 가 돌려준 분석 결과 Map (null 이면 아직 결과 없음)
  Map<String, dynamic>? _result;

  /// Gemini 호출 중 여부
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() {
    if (cameras.isEmpty) return;
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initFuture = _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedPath = file.path;
        _result = null;
        _isAnalyzing = true;
      });

      final result = await GeminiService.instance.analyzeObject(File(file.path));
      if (!mounted) return;
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('촬영 실패: $e')),
      );
    }
  }

  void _retake() => setState(() {
        _capturedPath = null;
        _result = null;
        _isAnalyzing = false;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('WorkSafe · 카메라'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (cameras.isEmpty || _controller == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '사용 가능한 카메라가 없습니다.\n실기기(USB 연결)에서 실행하세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    if (_capturedPath != null) {
      return _buildResultView(_capturedPath!);
    }
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '카메라 초기화 실패: ${snapshot.error}\n권한을 허용했는지 확인하세요.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        return _buildPreviewView();
      },
    );
  }

  Widget _buildPreviewView() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox.expand(child: CameraPreview(_controller!)),
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const Positioned(
          top: 24,
          child: Text(
            '궁금한 물건을 네모 안에 맞추세요',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: GestureDetector(
            onTap: _takePicture,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const Icon(Icons.camera_alt, size: 32, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(String path) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: Image.file(File(path), fit: BoxFit.contain),
          ),
        ),
        // TODO(4단계): 이 아래에 식별·용도·안전 정보 결과 카드가 들어감
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAnalysisText(),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isAnalyzing ? null : _retake,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 찍기'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 로딩 중이면 "분석 중...", 결과가 오면 Gemini 한 줄 답변을 보여준다.
  Widget _buildAnalysisText() {
    if (_isAnalyzing) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('분석 중...'),
        ],
      );
    }
    final result = _result;
    if (result != null) {
      // TODO(다음 단계): 임시 디버그 표시 — 제대로 된 카드 UI 로 교체할 것
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          result.entries.map((e) => '${e.key}: ${_format(e.value)}').join('\n'),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      );
    }
    return const Text('촬영 완료', textAlign: TextAlign.center);
  }

  /// 리스트는 쉼표로 이어 붙이고, 나머지는 그대로 문자열로.
  String _format(dynamic value) {
    if (value is List) {
      return value.isEmpty ? '(없음)' : value.join(', ');
    }
    return '$value';
  }
}
