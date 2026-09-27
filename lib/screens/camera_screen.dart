import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_colors.dart';
import '../gemini_service.dart';
import '../history_service.dart';
import '../language_service.dart';
import '../main.dart' show cameras;
import '../result_localization.dart';
import '../widgets/analysis_result_page.dart';
import '../widgets/common.dart';
import '../widgets/language_sheet.dart';
import 'history_detail_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;

  /// [cameras] 안에서 지금 쓰는 카메라의 위치. 카메라 전환 버튼이 바꾼다.
  int _cameraIndex = 0;

  String? _capturedPath;

  /// Gemini 가 돌려준 분석 결과 Map (null 이면 아직 결과 없음)
  Map<String, dynamic>? _result;

  /// Gemini 호출 중 여부
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    // 처음에는 후면 카메라로 연다.
    final back = cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    _initCamera(back == -1 ? 0 : back);
  }

  void _initCamera(int index) {
    if (cameras.isEmpty) return;
    _cameraIndex = index;
    _controller = CameraController(
      cameras[index],
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

  /// 다음 카메라(전면 ↔ 후면)로 바꾼다. 카메라가 하나뿐이면 아무 일도 하지 않는다.
  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;
    final old = _controller;
    setState(() => _initCamera((_cameraIndex + 1) % cameras.length));
    await old?.dispose();
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture || _isAnalyzing) return;
    try {
      final file = await controller.takePicture();
      await _analyze(file.path);
    } catch (e) {
      _showFailure(e);
    }
  }

  /// 갤러리에서 고른 사진을 촬영한 사진과 똑같이 분석한다.
  Future<void> _pickFromGallery() async {
    if (_isAnalyzing) return;
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;
      await _analyze(file.path);
    } catch (e) {
      _showFailure(e);
    }
  }

  /// 사진을 Gemini 로 분석하고, 오늘 같은 물건 기록이 없으면 기록에 저장한다.
  Future<void> _analyze(String path) async {
    if (!mounted) return;
    setState(() {
      _capturedPath = path;
      _result = null;
      _isAnalyzing = true;
    });

    final imageFile = File(path);
    final result = await GeminiService.instance.analyzeObject(imageFile);
    if (!mounted) return;
    setState(() {
      _result = result;
      _isAnalyzing = false;
    });

    // 기록 저장/중복 확인 실패는 촬영/분석 자체의 실패가 아니므로 별도로 처리하고,
    // "촬영 실패" 스낵바로 뭉뚱그려지지 않게 한다.
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
        await HistoryService.instance.add(result: result, imageFile: imageFile);
      } catch (e, stack) {
        debugPrint('HistoryService 저장 실패: $e');
        debugPrint('$stack');
      }
    }
  }

  void _showFailure(Object error) {
    if (!mounted) return;
    // 결과 없이 로딩 화면에 멈춰 있지 않도록 촬영 화면으로 되돌린다.
    _retake();
    final language = LanguageService.instance.current;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${language.captureFailedPrefix}$error')),
    );
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
    // 이 화면은 탭 화면 밖에 push 되므로, 언어 버튼으로 언어를 바꾸면 여기서
    // 직접 다시 그린다.
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final language = LanguageService.instance.current;
        final path = _capturedPath;
        if (path != null) {
          // 분석 중에는 result 가 null 이라 사진과 로딩 표시만 보인다.
          // 왼쪽 위 뒤로가기는 카메라를 닫지 않고 다시 찍기 화면으로 돌아간다.
          return AnalysisResultPage(
            imagePath: path,
            result: _isAnalyzing ? null : _result,
            onBack: _retake,
            backTooltip: language.retakeButton,
          );
        }
        return Scaffold(
          backgroundColor: AppColors.cameraBg,
          body: Column(
            children: [
              Expanded(child: _buildViewfinder(language)),
              _ControlBar(
                galleryLabel: language.galleryLabel,
                switchLabel: language.switchCameraLabel,
                shutterLabel: language.cameraLabel,
                onGallery: _pickFromGallery,
                onShutter: _takePicture,
                onSwitch: cameras.length < 2 ? null : _switchCamera,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 미리보기 + 위쪽 버튼 줄 + 아래쪽 안내 알약.
  Widget _buildViewfinder(AppLanguage language) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildPreview(language),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              // 제목은 양쪽 버튼 폭과 상관없이 화면 정중앙에 오도록 버튼 줄 위에 겹친다.
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    language.cameraLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      // 카메라를 닫고 원래 보던 탭 화면으로 돌아간다.
                      RoundIconButton(
                        icon: Icons.chevron_left,
                        iconSize: 28,
                        tooltip: language.homeLabel,
                        background: Colors.black.withValues(alpha: 0.45),
                        foreground: Colors.white,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      _DarkLanguagePill(
                        code: language.code.toUpperCase(),
                        onTap: () => showLanguageSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: Center(child: _HintPill(text: language.cameraOverlayHint)),
        ),
      ],
    );
  }

  Widget _buildPreview(AppLanguage language) {
    final controller = _controller;
    if (cameras.isEmpty || controller == null) {
      return _CenterMessage(language.noCameraMessage);
    }
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasError) {
          return _CenterMessage(
            language.cameraInitErrorTemplate.replaceFirst(
              '{error}',
              '${snapshot.error}',
            ),
          );
        }
        final size = controller.value.previewSize;
        if (size == null) return CameraPreview(controller);
        // 미리보기를 비율을 유지한 채 화면 영역에 꽉 채운다(가장자리는 잘린다).
        // previewSize 는 가로 기준이라 세로 화면에서는 너비·높이를 바꿔 쓴다.
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.height,
              height: size.width,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }
}

class _CenterMessage extends StatelessWidget {
  const _CenterMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

/// 카메라 화면 오른쪽 위의 어두운 언어 버튼 (🌐 KO).
class _DarkLanguagePill extends StatelessWidget {
  const _DarkLanguagePill({required this.code, required this.onTap});

  final String code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                code,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 미리보기 아래쪽의 "궁금한 물건을 화면에 담고 촬영하세요" 안내 알약.
class _HintPill extends StatelessWidget {
  const _HintPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.radio_button_checked,
            size: 18,
            color: AppColors.brand,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 화면 맨 아래 어두운 버튼 줄: 갤러리 · 셔터 · 카메라 전환.
class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.galleryLabel,
    required this.switchLabel,
    required this.shutterLabel,
    required this.onGallery,
    required this.onShutter,
    required this.onSwitch,
  });

  final String galleryLabel;
  final String switchLabel;
  final String shutterLabel;
  final VoidCallback onGallery;
  final VoidCallback onShutter;

  /// null 이면(카메라가 하나뿐) 전환 버튼을 흐리게 비활성화한다.
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    final onSwitch = this.onSwitch;
    return Container(
      color: const Color(0xFF151515),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RoundIconButton(
                icon: Icons.photo_outlined,
                tooltip: galleryLabel,
                size: 54,
                iconSize: 26,
                circle: false,
                background: AppColors.cameraControlBg,
                foreground: Colors.white,
                onTap: onGallery,
              ),
              Tooltip(
                message: shutterLabel,
                child: GestureDetector(
                  onTap: onShutter,
                  child: Container(
                    width: 86,
                    height: 86,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.shutter, width: 4),
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.shutter,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: onSwitch == null ? 0.4 : 1,
                child: RoundIconButton(
                  icon: Icons.cached,
                  tooltip: switchLabel,
                  size: 54,
                  iconSize: 26,
                  circle: false,
                  background: AppColors.cameraControlBg,
                  foreground: Colors.white,
                  onTap: onSwitch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
