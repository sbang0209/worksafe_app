import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../language_service.dart';
import '../notice_data.dart';
import '../result_localization.dart';
import '../screens/notice_detail_screen.dart';
import 'common.dart';

/// 안전 공지 한 장. 누르면 공지 상세로 간다. 홈과 공지 목록에서 쓴다.
class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key, required this.notice});

  final SafetyNotice notice;

  /// 공지 날짜 표시. 일주일 안쪽이면 "오늘 / 3일 전", 그보다 오래되면 날짜.
  static String dateLabel(DateTime date, AppLanguage language) {
    return relativeDayLabel(date, language, maxRelativeDays: 7) ??
        '${date.year}.${date.month.toString().padLeft(2, '0')}.'
            '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final level = notice.level;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: AppColors.border),
    );
    return Material(
      color: AppColors.surface,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NoticeDetailScreen(notice: notice)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 12, 16),
          child: Row(
            children: [
              IconChip(
                icon: notice.icon,
                color: level.color,
                background: level.background,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resolveLocalizedText(notice.title, language),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                        children: [
                          TextSpan(
                            text: level.label(language),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: level.color,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' · ${notice.source} · '
                                '${dateLabel(notice.date, language)}',
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}
