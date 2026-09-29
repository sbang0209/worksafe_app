import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../gemini_service.dart';
import '../history_service.dart';
import '../language_service.dart';
import '../main.dart' show cameras;
import '../result_localization.dart';
import '../signage_data.dart';
import '../tts_service.dart';
import '../widgets/analysis_result_page.dart';
import '../widgets/common.dart';
import '../widgets/language_sheet.dart';
import '../widgets/signage_sheet.dart';
import 'history_detail_screen.dart';

/// 촬영 직후 결과 화면의 "홈으로"/"분석 데이터" 버튼을 눌렀을 때, 카메라
/// 화면이 어느 탭으로 이동해 달라는 건지 [Navigator.pop] 으로 돌려주는 값.
/// [MainTabScreen] 이 이 값을 보고 탭을 바꾼다.
enum PostCaptureDestination { home, history }

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.signageMode = false});

  /// true 면 표지판 탭의 "표지판 촬영"으로 연 것이다. 등록된 표지판을 찾으면
  /// 시트를 여기서 띄우지 않고 [Navigator.pop] 으로 그 표지판을 돌려준다(호출한
  /// 표지판 탭이 시트를 띄운다). 못 찾으면 signageMode 여도 일반 결과 화면으로
  /// 넘어가고 기록에 저장한다 — 미등록 표지판 설명 기능은 그대로 유지한다.
  final bool signageMode;

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

  /// "분석하기" 진행 중 여부. 결과 화면으로 넘어가는 [_isAnalyzing] 과는 별개다.
  bool _isQuickChecking = false;

  /// "분석하기" 결과(name/description). 미리보기 위 카드로 보여주고 기록에는
  /// 저장하지 않는다. null 이면 카드를 숨긴다.
  Map<String, String>? _quickResult;

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
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture || _isAnalyzing || _isQuickChecking) {
      return;
    }
    try {
      final file = await controller.takePicture();
      await _analyze(file.path);
    } catch (e) {
      _showFailure(e);
    }
  }

  /// "분석하기": 사진을 찍어 이름 + 한 줄 설명만 빠르게 받아 미리보기 위 카드로
  /// 보여주고 음성으로 읽어준다. 결과 화면으로 넘어가지 않고 기록에도 저장하지
  /// 않는다(HistoryService 를 부르지 않는다). 임시 사진은 다 쓰면 지운다.
  Future<void> _quickCheck() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture || _isAnalyzing || _isQuickChecking) {
      return;
    }
    setState(() => _isQuickChecking = true);

    XFile? file;
    try {
      file = await controller.takePicture();
      final result = await GeminiService.instance.quickIdentify(
        File(file.path),
      );
      if (!mounted) return;

      final language = LanguageService.instance.current;
      // 실패한 결과는 카드도 음성도 없이, 담겨 온 오류 문구만 스낵바로 보여준다.
      // 이전에 성공했던 카드가 남아 있으면 지우고, 읽던 음성도 멈춘다.
      if (result['error'] == 'true') {
        TtsService.instance.stop();
        setState(() => _quickResult = null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['name'] ?? '')));
        return;
      }
      setState(() => _quickResult = result);

      final started = await TtsService.instance.speak(
        '${result['name']}. ${result['description']}',
        language,
      );
      if (!started && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(language.ttsUnavailableMessage)));
      }
    } catch (e) {
      _showFailure(e);
    } finally {
      if (file != null) {
        try {
          await File(file.path).delete();
        } catch (_) {
          // 삭제 실패는 무시한다 — 기록에 남기지 않는 임시 파일이라 치명적이지 않다.
        }
      }
      if (mounted) setState(() => _isQuickChecking = false);
    }
  }

  void _closeQuickResult() {
    TtsService.instance.stop();
    setState(() => _quickResult = null);
  }

  /// 사진을 Gemini 로 분석하고, 오늘 같은 물건 기록이 없으면 기록에 저장한다.
  Future<void> _analyze(String path) async {
    if (!mounted) return;
    // 결과 화면으로 넘어가므로 분석하기 카드와 음성은 정리한다.
    TtsService.instance.stop();
    setState(() {
      _capturedPath = path;
      _result = null;
      _isAnalyzing = true;
      _quickResult = null;
    });

    final imageFile = File(path);
    final result = await GeminiService.instance.analyzeObject(imageFile);
    if (!mounted) return;

    // 앱에 등록된 표지판이면 결과 화면도 기록 저장도 없이, 표지판 탭과 같은 상세
    // 시트를 보여준다(고정 정보라 언제든 표지판 탭에서 볼 수 있다). 사진이 아직
    // 필요 없으니 임시 파일을 지우고 카메라 프리뷰로 돌아간 뒤 시트를 띄우며,
    // 시트를 닫으면 프리뷰가 그대로 남는다.
    final signageName = result['signage_name'];
    final signage = signageName is String
        ? signageByKoreanName(signageName)
        : null;
    if (signage != null) {
      try {
        await imageFile.delete();
      } catch (_) {
        // 삭제 실패는 무시한다 — 기록에 남기지 않는 임시 파일이라 치명적이지 않다.
      }
      if (!mounted) return;
      if (widget.signageMode) {
        // 표지판 탭에서 연 촬영이면 시트는 여기서 띄우지 않고, 찾은 표지판을
        // 들고 표지판 탭으로 돌아간다 — 시트는 그 탭이 띄운다.
        Navigator.of(context).pop(signage);
        return;
      }
      _retake();
      await showSignageSheet(context, signage);
      return;
    }

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
            // 표지판 모드는 signageByKoreanName 매칭 실패 시에만 여기로 오는데,
            // 그 경로는 SignageScreen 이 Navigator.push<Signage?> 로 열어서
            // PostCaptureDestination 을 pop 하면 타입이 맞지 않는다. 일반
            // 촬영(MainTabScreen 이 연 signageMode:false)일 때만 켠다.
            showNavigationButtons: !widget.signageMode,
            onGoHome: widget.signageMode
                ? null
                : () => Navigator.of(context).pop(PostCaptureDestination.home),
            onGoToHistory: widget.signageMode
                ? null
                : () =>
                      Navigator.of(context).pop(PostCaptureDestination.history),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.cameraBg,
          body: Column(
            children: [
              Expanded(child: _buildViewfinder(language)),
              _ControlBar(
                quickLabel: language.quickCheckButton,
                explainLabel: widget.signageMode
                    ? language.signageShutterLabel
                    : language.explainButton,
                // 표지판 모드에서는 "분석하기"가 표지판 분기를 타지 않아
                // 헷갈리므로 숨기고, 가운데 [표지판 촬영] 버튼 하나만 남긴다.
                showQuickButton: !widget.signageMode,
                quickLoading: _isQuickChecking,
                onQuickCheck: _isQuickChecking ? null : _quickCheck,
                onExplain: _isQuickChecking ? null : _takePicture,
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
        // 조준용 모서리 프레임. 프리뷰 영역 정중앙(가로·세로 모두)에 둔다.
        const Align(alignment: Alignment.center, child: _ViewfinderFrame()),
        // 안내 알약은 프레임과 분리해 화면 아래쪽, 하단 버튼 줄 바로 위에
        // 항상 같은 자리로 고정한다 — 프레임 크기가 바뀌어도 움직이지 않는다.
        // "분석하기" 결과 카드가 떠 있을 때는 카드와 겹치므로 숨긴다.
        if (_quickResult == null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: _HintPill(
                text: widget.signageMode
                    ? language.signageCameraHint
                    : language.cameraOverlayHint,
              ),
            ),
          ),
        // 상단 버튼 줄(약 60px) 바로 아래에 "분석하기" 결과 카드를 띄운다.
        // 프레임보다 뒤에 그려야 카드가 프레임 위에 뜬다.
        if (_quickResult != null)
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 68),
                child: _QuickResultCard(
                  name: _quickResult!['name'] ?? '',
                  description: _quickResult!['description'] ?? '',
                  onClose: _closeQuickResult,
                ),
              ),
            ),
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

/// 프리뷰 가운데의 조준용 사각 프레임. 네 모서리에 ㄱ자 꺾쇠만 그리고 안쪽은
/// 완전히 비워 둬 프리뷰가 그대로 비친다. 터치를 가로채지 않도록
/// [IgnorePointer] 로 감싼다. 표지판 모드에서도 똑같이 쓴다.
class _ViewfinderFrame extends StatelessWidget {
  const _ViewfinderFrame();

  @override
  Widget build(BuildContext context) {
    final side = MediaQuery.sizeOf(context).width * 0.72;
    return IgnorePointer(
      child: SizedBox(
        width: side,
        height: side,
        child: CustomPaint(
          painter: _ViewfinderPainter(cornerLength: side * 0.18),
        ),
      ),
    );
  }
}

/// 정사각형 네 모서리에만 ㄱ자 꺾쇠를 그리는 페인터. 밝은 배경에서도 잘
/// 보이도록, 같은 경로를 검정 반투명으로 굵게 먼저 깔고 그 위에 브랜드
/// 틸색을 얇게 덧그린다.
class _ViewfinderPainter extends CustomPainter {
  _ViewfinderPainter({required this.cornerLength});

  /// 꺾쇠 한 변의 길이.
  final double cornerLength;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _cornersPath(size);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePaint = Paint()
      ..color = AppColors.brand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, linePaint);
  }

  /// 네 귀퉁이에 ㄱ자 꺾쇠 하나씩, 변 전체를 잇는 테두리는 그리지 않는다.
  Path _cornersPath(Size size) {
    final l = cornerLength;
    return Path()
      // 왼쪽 위
      ..moveTo(0, l)
      ..lineTo(0, 0)
      ..lineTo(l, 0)
      // 오른쪽 위
      ..moveTo(size.width - l, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, l)
      // 오른쪽 아래
      ..moveTo(size.width, size.height - l)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - l, size.height)
      // 왼쪽 아래
      ..moveTo(l, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - l);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) =>
      oldDelegate.cornerLength != cornerLength;
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

/// 화면 맨 아래 어두운 버튼 줄: 텍스트 버튼 두 개(분석하기/설명보기)가 가로를
/// 반씩 나눠 가진다. 표지판 촬영 모드에서는 왼쪽 버튼을 숨기고 가운데
/// [표지판 촬영] 버튼 하나만 가로 전체를 차지한다.
class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.quickLabel,
    required this.explainLabel,
    required this.quickLoading,
    required this.onQuickCheck,
    required this.onExplain,
    this.showQuickButton = true,
  });

  final String quickLabel;
  final String explainLabel;

  /// false 면(표지판 촬영 모드) 왼쪽 버튼을 아예 그리지 않고, 오른쪽 버튼
  /// 하나가 가로 전체를 차지한다.
  final bool showQuickButton;

  /// true 면 "분석하기" 자리에 라벨 대신 작은 로딩 인디케이터를 보여준다.
  final bool quickLoading;

  /// null 이면(분석하기 진행 중) 두 텍스트 버튼을 흐리게 비활성화한다.
  final VoidCallback? onQuickCheck;
  final VoidCallback? onExplain;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF151515),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Row(
            children: [
              if (showQuickButton) ...[
                Expanded(
                  child: _CameraTextButton(
                    label: quickLabel,
                    loading: quickLoading,
                    filled: false,
                    onTap: onQuickCheck,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: _CameraTextButton(
                  label: explainLabel,
                  filled: true,
                  onTap: onExplain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 하단 줄 가운데의 텍스트 버튼. [filled] 면 브랜드 틸색 채움(설명보기),
/// 아니면 어두운 배경 + 흰 테두리(분석하기). 높이 52, radius 16.
/// 라벨이 긴 언어(베트남어·크메르어 등)는 한 줄로 두고 넘치면 줄여서 맞춘다.
class _CameraTextButton extends StatelessWidget {
  const _CameraTextButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final bool filled;
  final bool loading;

  /// null 이면 흐리게 비활성화한다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: filled
          ? BorderSide.none
          : const BorderSide(color: Colors.white, width: 1.5),
    );
    return Opacity(
      opacity: onTap == null && !loading ? 0.5 : 1,
      child: Material(
        color: filled ? AppColors.brand : AppColors.cameraControlBg,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: SizedBox(
            height: 52,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "분석하기" 결과 카드. 반투명 검정 바탕에 이름(굵게) + 설명(1~2줄),
/// 오른쪽 위에 닫기 버튼.
class _QuickResultCard extends StatelessWidget {
  const _QuickResultCard({
    required this.name,
    required this.description,
    required this.onClose,
  });

  final String name;
  final String description;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 22, color: Colors.white),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
