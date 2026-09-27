import 'dart:io';

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../history_service.dart';
import '../language_service.dart';
import '../result_localization.dart';
import '../risk_level.dart';

/// 최근 기록 목록의 한 줄. 사진 썸네일 + 이름 + 위험도 배지·시각 + 화살표.
class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.entry, required this.onTap});

  final HistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final name = resolveLocalizedText(entry.result['name'], language);
    final risk = RiskSummary.of(entry.result);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            _Thumbnail(path: entry.imagePath),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (risk != null) ...[
                        _RiskBadge(risk: risk, language: language),
                        const SizedBox(width: 7),
                      ],
                      Text(
                        entry.formattedTime,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textFaint),
          ],
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 64,
        height: 64,
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
