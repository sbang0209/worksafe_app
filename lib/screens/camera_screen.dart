import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../gemini_service.dart';
import '../history_service.dart';
import '../language_service.dart';
import '../main.dart' show cameras;
import '../result_localization.dart';
import '../widgets/result_card_view.dart';
import 'history_detail_screen.dart';

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

      // 기록 저장/중복 확인 실패는 촬영/분석 자체의 실패가 아니므로 별도로 처리하고,
      // 위 catch 의 "촬영 실패" 스낵바로 뭉뚱그려지지 않게 한다.
      // 중복 판단은 화면 언어가 아니라 한국어 이름 기준으로 한다(언어를 바꿔가며
      // 찍어도 같은 물건으로 인식되도록).
      final koName = resolveLocalizedText(result['name'], AppLanguage.ko);
      HistoryEntry? duplicate;
      try {
        duplicate = await HistoryService.instance.findDuplicateToday(koName);
      } catch (e, stack) {
        debugPrint('HistoryService 중복 확인 실패: $e');
        debugPrint('$stack');
      }
      if (!mounted) return;

      if (duplicate != null) {
        await _showDuplicateDialog(existing: duplicate, name: result['name']);
      } else {
        try {
          await HistoryService.instance.add(
            result: result,
            imageFile: imageFile,
          );
        } catch (e, stack) {
          debugPrint('HistoryService 저장 실패: $e');
          debugPrint('$stack');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      final language = LanguageService.instance.current;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${language.captureFailedPrefix}$e')),
      );
    }
  }

  /// 오늘 같은 물건을 이미 찍은 기록이 있을 때 보여주는 안내 다이얼로그.
  /// [name] 은 분석 결과의 원본 'name' 값(언어별 맵 또는 예전 형식의 문자열)을
  /// 그대로 받아, 현재 화면 언어에 맞춰 여기서 뽑아 보여준다.
  Future<void> _showDuplicateDialog({
    required HistoryEntry existing,
    required dynamic name,
  }) {
    final language = LanguageService.instance.current;
    final displayName = resolveLocalizedText(name, language);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(language.duplicateDialogTitle),
        content: Text(
          language.duplicateDialogBodyTemplate.replaceFirst(
            '{name}',
            displayName,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HistoryDetailScreen(entry: existing),
                      ),
                    );
                  },
                  child: Text(language.viewRecordButton),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(language.confirmButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _retake() => setState(() {
    _capturedPath = null;
    _result = null;
    _isAnalyzing = false;
  });

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    return Scaffold(backgroundColor: Colors.black, body: _buildBody(language));
  }

  Widget _buildBody(AppLanguage language) {
    if (cameras.isEmpty || _controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            language.noCameraMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    if (_capturedPath != null) {
      return _buildResultView(_capturedPath!, language);
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
                language.cameraInitErrorTemplate.replaceFirst(
                  '{error}',
                  '${snapshot.error}',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        return _buildPreviewView(language);
      },
    );
  }

  Widget _buildPreviewView(AppLanguage language) {
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
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  // 카메라를 닫고 원래 보던 탭 화면으로 돌아간다.
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    iconSize: 28,
                    tooltip: language.homeLabel,
                  ),
                  // 뒤로가기 버튼과 같은 폭을 오른쪽에도 비워둬야 안내 문구가
                  // 버튼에 밀리지 않고 화면 한가운데에 놓인다.
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        language.cameraOverlayHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
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

  Widget _buildResultView(String path, AppLanguage language) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
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
              _buildAnalysisBody(language),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isAnalyzing ? null : _retake,
                      icon: const Icon(Icons.refresh),
                      label: Text(language.retakeButton),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _isAnalyzing ? null : _goHome,
                      icon: const Icon(Icons.home),
                      label: Text(language.homeLabel),
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
  Widget _buildAnalysisBody(AppLanguage language) {
    if (_isAnalyzing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(language.analyzingText, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    final result = _result;
    if (result != null) {
      return ResultCardView(result: result);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(language.captureCompleteText, textAlign: TextAlign.center),
    );
  }
}
