import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../app_colors.dart';
import '../language_service.dart';
import '../notice_data.dart';
import '../result_localization.dart';
import '../tts_service.dart';
import '../widgets/common.dart';

/// 안전 공지 상세. 등급·주제 태그, 제목, 발표 기관, 강조 박스, 주요 안내 목록과
/// 하단의 음성 듣기 / 원문 보기 버튼.
class NoticeDetailScreen extends StatefulWidget {
  const NoticeDetailScreen({super.key, required this.notice});

  final SafetyNotice notice;

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  List<String> _points(AppLanguage language) =>
      resolveLocalizedList(widget.notice.points, language);

  Future<void> _speak(AppLanguage language) async {
    final notice = widget.notice;
    final text = [
      resolveLocalizedText(notice.title, language),
      resolveLocalizedText(notice.highlight, language),
      // 읽을 때는 굵게 표시용 ** 를 뺀다.
      ..._points(language).map((p) => p.replaceAll('**', '')),
    ].join('. ');
    final started = await TtsService.instance.speak(text, language);
    if (!started && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.ttsUnavailableMessage)));
    }
  }

  void _share(AppLanguage language) {
    final notice = widget.notice;
    SharePlus.instance.share(
      ShareParams(
        subject: resolveLocalizedText(notice.title, language),
        text:
            '${resolveLocalizedText(notice.title, language)}\n'
            '${notice.source}\n${notice.url}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final notice = widget.notice;
    final level = notice.level;
    final date = notice.date;
    final dateText =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenTopBar(
              onBack: () => Navigator.of(context).pop(),
              trailing: RoundIconButton(
                icon: Icons.share_outlined,
                tooltip: language.shareLabel,
                onTap: () => _share(language),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        ColorTag(
                          label: level.label(language),
                          color: level.color,
                          background: level.background,
                        ),
                        const SizedBox(width: 8),
                        ColorTag(
                          label: resolveLocalizedText(notice.topic, language),
                          color: AppColors.textSecondary,
                          background: AppColors.fieldBg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      resolveLocalizedText(notice.title, language),
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const IconChip(
                          icon: Icons.verified_user_outlined,
                          color: AppColors.brand,
                          background: AppColors.brandTintBg,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            notice.source,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '  ·  $dateText',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Divider(height: 1, color: AppColors.divider),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: level.background,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          IconChip(
                            icon: notice.icon,
                            color: level.color,
                            background: AppColors.surface,
                            size: 46,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              resolveLocalizedText(notice.highlight, language),
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                fontWeight: FontWeight.w800,
                                color: level.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      language.noticeKeyPointsTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textFaint,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final point in _points(language))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const IconChip(
                              icon: Icons.check,
                              color: AppColors.brand,
                              background: AppColors.brandTintBg,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text.rich(
                                boldMarkedText(
                                  point,
                                  const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            BottomActionBar(
              secondaryIcon: Icons.volume_up_outlined,
              secondaryTooltip: language.listenLabel,
              onSecondary: () => _speak(language),
              primaryIcon: Icons.open_in_new,
              primaryLabel: language.viewOriginalButton,
              onPrimary: () => launchExternal(context, notice.url),
            ),
          ],
        ),
      ),
    );
  }
}
