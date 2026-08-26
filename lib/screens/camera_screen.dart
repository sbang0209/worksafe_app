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

  /// "분석" 버튼의 가벼운 결과. name/description 키를 가진 일반 문자열 Map.
  /// 기록에 저장하지 않는 일회성 결과라 [_result] 와는 별도로 관리한다.
  Map<String, String>? _quickResult;

  /// "분석" 버튼 호출 중 여부.
  bool _isQuickAnalyzing = false;

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

  /// "분석" 버튼: 현재 프레임을 캡처해 이름 + 한 줄 설명만 빠르게 받아 화면
  /// 상단에 보여준다. 화면 전환도, 기록 저장도 하지 않는다.
  Future<void> _quickAnalyze() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;
    if (_isAnalyzing || _isQuickAnalyzing) return;

    XFile? file;
    try {
      file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _isQuickAnalyzing = true;
        _quickResult = null;
      });

      final result = await GeminiService.instance.quickIdentify(
        File(file.path),
      );
      if (!mounted) return;
      setState(() {
        _quickResult = result;
        _isQuickAnalyzing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isQuickAnalyzing = false);
      final language = LanguageService.instance.current;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${language.captureFailedPrefix}$e')),
      );
    } finally {
      // 기록에 남기지 않는 임시 캡처라, 다 쓰고 나면 파일을 지운다.
      if (file != null) {
        try {
          await File(file.path).delete();
        } catch (_) {
          // 삭제 실패는 무시한다 — 임시 파일이라 치명적이지 않다.
        }
      }
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
    _quickResult = null;
    _isQuickAnalyzing = false;
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
              child: Column(
                children: [
                  Row(
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
                  if (_isQuickAnalyzing || _quickResult != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _QuickResultBanner(
                        loading: _isQuickAnalyzing,
                        result: _quickResult,
                        analyzingText: language.analyzingText,
                      ),
                    ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _QuickAnalyzeButton(
                  label: language.quickAnalyzeButton,
                  loading: _isQuickAnalyzing,
                  onTap: _isAnalyzing ? null : _quickAnalyze,
                ),
                const SizedBox(width: 32),
                GestureDetector(
                  onTap: _isQuickAnalyzing ? null : _takePicture,
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(String path, AppLanguage language) {
    // Container 에 크기를 명시해 화면 전체를 채운다 — 안 그러면 내용이 짧을 때
    // (자세히 보기를 접었을 때 등) 배경이 내용 높이만큼만 그려지고, 그 아래
    // Scaffold 의 검은 배경이 그대로 드러나 보인다.
    return SizedBox.expand(
      child: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // 사진/결과 카드는 스크롤 영역에 두고, 버튼은 그 밖에 고정해서
              // 내용이 길어져도 버튼이 항상 화면 하단에 그대로 보이게 한다.
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isAnalyzing ? null : _retake,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: Text(language.retakeButton),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _isAnalyzing ? null : _goHome,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.home),
                        label: Text(language.homeLabel),
                      ),
                    ),
                  ],
                ),
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

/// 카메라 프리뷰 상단에 뜨는 "분석" 결과 배너. 분석 중이면 로딩을,
/// 끝나면 "이름 — 설명" 한 줄을 보여준다.
class _QuickResultBanner extends StatelessWidget {
  const _QuickResultBanner({
    required this.loading,
    required this.result,
    required this.analyzingText,
  });

  final bool loading;
  final Map<String, String>? result;
  final String analyzingText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: loading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  analyzingText,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            )
          : Text(
              '${result?['name']} — ${result?['description']}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

/// "분석"(빠른 확인) 버튼. 촬영 버튼보다 작고 옅게 그려서 보조 동작임을
/// 나타낸다.
class _QuickAnalyzeButton extends StatelessWidget {
  const _QuickAnalyzeButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.25),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
        ],
      ),
    );
  }
}
