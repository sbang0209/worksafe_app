import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app_colors.dart';
import '../language_service.dart';
import '../result_localization.dart';
import '../screens/manager_screen.dart';
import '../tts_service.dart';
import 'common.dart';

/// 언어에 상관없이 "모름" 값을 판별하기 위한 전체 언어의 '모름' 문구 집합.
final Set<String> _unknownLabels = {
  for (final language in AppLanguage.all) language.unknownLabel,
};

bool _isUnknown(String value) => _unknownLabels.contains(value);

/// 분석 결과 화면 전체(상단 바 + 물건 정보 + 안전 카드 + 하단 버튼).
///
/// 촬영 직후 결과(카메라 화면)와 기록 상세에서 똑같이 쓴다. [result] 는
/// [GeminiService.analyzeObject] 가 돌려준 Map 이고, 각 값은 언어별 맵이라 현재
/// 언어에 맞는 값만 뽑아 보여준다. [result] 가 null 이면 아직 분석 중이라
/// 사진과 로딩 표시만 그린다.
class AnalysisResultPage extends StatefulWidget {
  const AnalysisResultPage({
    super.key,
    required this.imagePath,
    required this.result,
    required this.onBack,
    this.backTooltip,
  });

  final String imagePath;
  final Map<String, dynamic>? result;

  /// 왼쪽 위 뒤로가기 버튼. 카메라에서는 "다시 찍기", 기록에서는 목록으로.
  final VoidCallback onBack;
  final String? backTooltip;

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  /// 이름과 위험/금지/보호구 목록을 현재 언어 음성으로 차례대로 읽는다.
  Future<void> _speak(_ResolvedResult r, AppLanguage language) async {
    final parts = <String>[
      r.name,
      if (r.hazards.isNotEmpty)
        '${language.hazardsTitle}. ${r.hazards.join('. ')}',
      if (r.prohibited.isNotEmpty)
        '${language.prohibitedTitle}. ${r.prohibited.join('. ')}',
      if (r.ppe.isNotEmpty) '${language.ppeTitle}. ${r.ppe.join(', ')}',
    ];
    final started = await TtsService.instance.speak(parts.join('. '), language);
    if (!started && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.ttsUnavailableMessage)));
    }
  }

  void _openManager() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ManagerScreen()));
  }

  /// 이름과 위험/금지/보호구를 글로 묶어 다른 앱으로 공유한다.
  void _share(_ResolvedResult r, AppLanguage language) {
    String section(String title, List<String> items) => items.isEmpty
        ? ''
        : '\n\n$title\n${items.map((e) => '• $e').join('\n')}';
    SharePlus.instance.share(
      ShareParams(
        subject: r.name,
        text:
            '${r.name}'
            '${section(language.hazardsTitle, r.hazards)}'
            '${section(language.prohibitedTitle, r.prohibited)}'
            '${section(language.ppeTitle, r.ppe)}',
      ),
    );
  }

  void _showPhoto() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.of(dialogContext).pop(),
        child: InteractiveViewer(
          child: Center(child: _Photo(path: widget.imagePath)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final raw = widget.result;
    final r = raw == null ? null : _ResolvedResult(raw, language);

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: SafeArea(
        child: Column(
          children: [
            ScreenTopBar(
              title: language.analysisResultTitle,
              onBack: widget.onBack,
              backTooltip: widget.backTooltip,
              trailing: r == null
                  ? null
                  : RoundIconButton(
                      icon: Icons.share_outlined,
                      tooltip: language.shareLabel,
                      onTap: () => _share(r, language),
                    ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      imagePath: widget.imagePath,
                      onPhotoTap: _showPhoto,
                      category: r?.category,
                      name: r?.name,
                      usage: r?.usage,
                      analyzingText: language.analyzingText,
                    ),
                    if (r != null) ...[
                      if (r.hazards.isNotEmpty || r.prohibited.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _Card(
                          children: [
                            if (r.hazards.isNotEmpty)
                              _BulletSection(
                                icon: Icons.warning_amber_rounded,
                                title: language.hazardsTitle,
                                items: r.hazards,
                              ),
                            if (r.hazards.isNotEmpty && r.prohibited.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(
                                  height: 1,
                                  color: AppColors.divider,
                                ),
                              ),
                            if (r.prohibited.isNotEmpty)
                              _BulletSection(
                                icon: Icons.block,
                                title: language.prohibitedTitle,
                                items: r.prohibited,
                              ),
                          ],
                        ),
                      ],
                      if (r.ppe.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _Card(
                          children: [
                            _SectionHeader(
                              icon: Icons.verified_user_outlined,
                              title: language.ppeTitle,
                              color: AppColors.mandatory,
                              background: AppColors.mandatoryBg,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final item in r.ppe) _PpeChip(item),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            // 버튼은 스크롤 영역 밖에 고정해서 내용이 길어도 항상 보이게 한다.
            if (r != null)
              BottomActionBar(
                secondaryIcon: Icons.volume_up_outlined,
                secondaryTooltip: language.listenLabel,
                onSecondary: () => _speak(r, language),
                secondaryBackground: AppColors.surface,
                primaryIcon: Icons.phone_outlined,
                primaryLabel: language.askManagerButton,
                onPrimary: _openManager,
              ),
          ],
        ),
      ),
    );
  }
}

/// 결과 Map 에서 현재 언어의 값만 뽑아 둔 것.
class _ResolvedResult {
  _ResolvedResult(Map<String, dynamic> result, AppLanguage language)
    : name = resolveLocalizedText(result['name'], language),
      category = resolveLocalizedText(result['category'], language),
      usage = resolveLocalizedText(result['usage'], language),
      hazards = resolveLocalizedList(result['hazards'], language),
      prohibited = resolveLocalizedList(result['prohibited'], language),
      ppe = resolveLocalizedList(result['required_ppe'], language);

  final String name;
  final String category;
  final String usage;
  final List<String> hazards;
  final List<String> prohibited;
  final List<String> ppe;
}

/// 사진 썸네일 + 분류 / 이름 / 용도.
class _Header extends StatelessWidget {
  const _Header({
    required this.imagePath,
    required this.onPhotoTap,
    required this.category,
    required this.name,
    required this.usage,
    required this.analyzingText,
  });

  final String imagePath;
  final VoidCallback onPhotoTap;

  /// 셋 다 null 이면 분석 중이다.
  final String? category;
  final String? name;
  final String? usage;
  final String analyzingText;

  @override
  Widget build(BuildContext context) {
    final category = this.category;
    final name = this.name;
    final usage = this.usage;
    return Row(
      children: [
        GestureDetector(
          onTap: onPhotoTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 72,
              height: 72,
              child: _Photo(path: imagePath, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: name == null
              ? Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      analyzingText,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category != null && !_isUnknown(category))
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brand,
                        ),
                      ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (usage != null && !_isUnknown(usage))
                      Text(
                        usage,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.path, this.fit = BoxFit.contain});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: (context, error, stack) => Container(
        color: AppColors.thumbBg,
        alignment: Alignment.center,
        child: const Icon(
          Icons.photo_camera_outlined,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

/// 흰 바탕 + 옅은 테두리의 둥근 카드.
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// 옅은 색 칩 안의 아이콘 + 굵은 제목.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// 위험 요소 / 금지 행동처럼 빨간 점 목록으로 보여주는 구역.
class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: icon,
          title: title,
          color: AppColors.danger,
          background: AppColors.dangerBg,
        ),
        const SizedBox(height: 10),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 글자 첫 줄 가운데 높이에 점을 맞춘다.
                Container(
                  margin: const EdgeInsets.only(top: 9, right: 12),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PpeChip extends StatelessWidget {
  const _PpeChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.mandatoryBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.mandatory,
        ),
      ),
    );
  }
}
