import 'dart:io';

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../history_service.dart';
import '../language_service.dart';

/// 기록 하나를 사진 + 이름 + 날짜로 보여주는 카드.
/// 최근 기록 탭 목록과 홈 화면의 미리보기에서 공통으로 쓴다.
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.compact = false,
  });

  final HistoryEntry entry;
  final VoidCallback onTap;

  /// true 면 홈 화면 미리보기용으로 더 작게 그린다.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final name = (entry.result['name'] as String?) ?? language.unknownLabel;
    final padding = compact ? 8.0 : 12.0;
    final gap = compact ? 10.0 : 14.0;
    final nameFontSize = compact ? 15.0 : 17.0;
    final dateFontSize = compact ? 13.0 : 15.0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(entry.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: compact ? 3 : 6),
                    Text(
                      entry.formattedTimestamp,
                      style: TextStyle(
                        fontSize: dateFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
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
