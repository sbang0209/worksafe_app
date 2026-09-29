import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app_colors.dart';
import '../language_service.dart';
import '../result_localization.dart';
import '../screens/manager_screen.dart';
import '../tts_service.dart';
import '../youtube_service.dart';
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
    this.showNavigationButtons = false,
    this.onGoHome,
    this.onGoToHistory,
  });

  final String imagePath;
  final Map<String, dynamic>? result;

  /// 왼쪽 위 뒤로가기 버튼. 카메라에서는 "다시 찍기", 기록에서는 목록으로.
  final VoidCallback onBack;
  final String? backTooltip;

  /// true 면(촬영 직후 결과 화면) 하단 버튼 바를 "음성 듣기/관리자에게 확인"
  /// 대신 "홈으로/분석 데이터" 두 버튼으로 바꾼다. 기록 상세는 기본값 false로
  /// 기존 버튼 바를 그대로 쓴다. true 일 때는 [onGoHome]/[onGoToHistory] 를
  /// 함께 넘겨야 한다 — 실제 이동은 이 화면이 아니라 호출한 쪽(카메라 화면)이
  /// 안다.
  final bool showNavigationButtons;
  final VoidCallback? onGoHome;
  final VoidCallback? onGoToHistory;

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  /// 관련 영상 조회. result 가 채워진 뒤 한 번만 만들어서, 빌드마다 API 를
  /// 다시 부르지 않는다. 조회 전(분석 중)에는 null.
  Future<List<YoutubeVideo>>? _videosFuture;

  @override
  void initState() {
    super.initState();
    _loadVideosOnce();
  }

  @override
  void didUpdateWidget(AnalysisResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 카메라에서는 분석이 끝나 result 가 null → 값으로 바뀔 때 여기로 온다.
    _loadVideosOnce();
  }

  void _loadVideosOnce() {
    final result = widget.result;
    if (result == null || _videosFuture != null) return;
    // 분석 실패 결과(안전 정보가 하나도 없고 이름 자리에 오류 문구만 담긴 Map)로는
    // 검색하지 않는다 — 오류 문구가 검색어가 되어 엉뚱한 영상이 뜨는 걸 막는다.
    final language = LanguageService.instance.current;
    final hasSafetyInfo =
        resolveLocalizedList(result['hazards'], language).isNotEmpty ||
        resolveLocalizedList(result['prohibited'], language).isNotEmpty ||
        resolveLocalizedList(result['required_ppe'], language).isNotEmpty;
    if (!hasSafetyInfo) return;
    _videosFuture = YoutubeService.instance.searchRelated(result);
  }

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
                      _ManagerNotice(text: language.managerNotice),
                      _RelatedVideos(
                        future: _videosFuture,
                        title: language.relatedVideosTitle,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // 버튼은 스크롤 영역 밖에 고정해서 내용이 길어도 항상 보이게 한다.
            if (r != null)
              widget.showNavigationButtons
                  ? _NavigationActionBar(
                      homeLabel: language.goHomeButton,
                      onHome: widget.onGoHome!,
                    )
                  : BottomActionBar(
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
      hazards = _filterKnown(resolveLocalizedList(result['hazards'], language)),
      prohibited = _filterKnown(
        resolveLocalizedList(result['prohibited'], language),
      ),
      ppe = _filterKnown(
        resolveLocalizedList(result['required_ppe'], language),
      );

  final String name;
  final String category;
  final String usage;
  final List<String> hazards;
  final List<String> prohibited;
  final List<String> ppe;

  /// "알 수 없음"(각 언어의 unknownLabel)이거나 빈 문자열인 항목은 목록에서
  /// 뺀다 — 위험요소·금지행동·보호구 세 목록 모두 같은 규칙을 적용한다.
  /// 걸러낸 결과가 빈 목록이면 기존 isNotEmpty 조건 덕분에 그 섹션(카드)이
  /// 통째로 안 그려진다.
  static List<String> _filterKnown(List<String> items) {
    return items
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !_isUnknown(e))
        .toList();
  }
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

/// 촬영 직후 결과 화면 전용 하단 버튼 바. "음성 듣기/관리자에게 확인" 대신
/// 가로 전체를 차지하는 "홈으로" 버튼 하나를 보여준다. 높이(56)·radius(18)·
/// 강조(브랜드 틸) 스타일은 앱 전역 [FilledButton] 테마 그대로다.
class _NavigationActionBar extends StatelessWidget {
  const _NavigationActionBar({required this.homeLabel, required this.onHome});

  final String homeLabel;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onHome,
          child: Text(homeLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

/// 관리자 확인 안내. AI 응답이 아니라 코드에서 항상 고정으로 붙이는 안전
/// 안내라, Gemini 결과와 무관하게(위험요소·보호구가 비어 있어도) 항상 보여준다.
/// 카드가 아니라 아이콘 + 한 줄 텍스트의 가벼운 형태로 둔다.
class _ManagerNotice extends StatelessWidget {
  const _ManagerNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 하단 "관련 영상" 섹션. 조회 중이거나 결과가 0개/실패면 아무것도 그리지
/// 않는다(스피너·빈 영역 없이 조용히) — 시연 중 빈 영역이 뜨지 않게 한다.
class _RelatedVideos extends StatelessWidget {
  const _RelatedVideos({required this.future, required this.title});

  final Future<List<YoutubeVideo>>? future;
  final String title;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<YoutubeVideo>>(
      future: future,
      builder: (context, snapshot) {
        final videos = snapshot.data;
        if (videos == null || videos.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            for (final video in videos) _VideoCard(video: video),
          ],
        );
      },
    );
  }
}

/// 영상 한 건: 왼쪽 16:9 썸네일, 오른쪽에 제목(최대 2줄) + 채널명.
/// 누르면 유튜브에서 해당 영상을 연다.
class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});

  final YoutubeVideo video;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: AppColors.border),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: AppColors.surface,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: () => launchExternal(context, video.watchUrl),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 128,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        video.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            const ColoredBox(color: AppColors.thumbBg),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (video.channelTitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
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
