import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../gemini_service.dart';
import '../history_service.dart';
import '../main.dart' show cameras;
import '../widgets/result_card_view.dart';

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

      final imageFile = File(file.path);
      final result = await GeminiService.instance.analyzeObject(imageFile);
      if (!mounted) return;
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });

      // 기록 저장 실패는 촬영/분석 자체의 실패가 아니므로 별도로 처리하고,
      // 위 catch 의 "촬영 실패" 스낵바로 뭉뚱그려지지 않게 한다.
      try {
        await HistoryService.instance.add(result: result, imageFile: imageFile);
      } catch (e, stack) {
        debugPrint('HistoryService 저장 실패: $e');
        debugPrint('$stack');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('촬영 실패: $e')));
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
        SafeArea(
          top: false,
          left: false,
          right: false,
          child: Padding(
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
                child: const Icon(
                  Icons.camera_alt,
                  size: 32,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(String path) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 260,
                  child: Image.file(File(path), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              _buildAnalysisBody(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isAnalyzing ? null : _retake,
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 찍기'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _isAnalyzing ? null : _goHome,
                      icon: const Icon(Icons.home),
                      label: const Text('홈'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// 분석 중이면 로딩 인디케이터를, 결과가 오면 카드 UI(ResultCardView)를 보여준다.
  Widget _buildAnalysisBody() {
    if (_isAnalyzing) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('분석 중...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    final result = _result;
    if (result != null) {
      return ResultCardView(result: result);
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Text('촬영 완료', textAlign: TextAlign.center),
    );
  }
}
