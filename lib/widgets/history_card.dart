import 'dart:io';

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../history_service.dart';
import '../language_service.dart';
import '../result_localization.dart';
import '../risk_level.dart';

/// 최근 기록 목록의 카드 한 장. 사진(위) + 이름·위험도 배지·화살표(가운데
/// 줄) + 시각(아래 줄)의 세로 구조.
class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.entry, required this.onTap});

  final HistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final name = resolveLocalizedText(entry.result['name'], language);
    final risk = RiskSummary.of(entry.result);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.border),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: AppColors.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Thumbnail(path: entry.imagePath),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (risk != null) ...[
                          const SizedBox(width: 8),
                          _RiskBadge(risk: risk, language: language),
                        ],
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textFaint,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.formattedTime,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
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
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          color: AppColors.thumbBg,
          alignment: Alignment.center,
          child: const Icon(
            Icons.photo_camera_outlined,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.risk, required this.language});

  final RiskSummary risk;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: risk.level.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${risk.level.label(language)} ${risk.count}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: risk.level.color,
        ),
      ),
    );
  }
}
