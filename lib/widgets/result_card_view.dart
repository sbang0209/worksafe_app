import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../language_service.dart';
import '../result_localization.dart';

/// 언어에 상관없이 "모름" 값을 판별하기 위한 전체 언어의 '모름' 문구 집합.
final Set<String> _unknownLabels = {
  for (final language in AppLanguage.all) language.unknownLabel,
};

bool _isUnknown(String value) => _unknownLabels.contains(value);

/// [GeminiService.analyzeObject] 가 돌려주는 분석 결과 Map 을
/// 카드 UI 로 그려주는 위젯.
///
/// 촬영 직후 결과 화면과 기록 상세 화면에서 동일하게 재사용한다. 결과의 각 값은
/// 언어별 맵({'ko': ..., 'en': ..., 'vi': ...})이라, 현재 선택된 언어에 맞는
/// 값만 뽑아 보여준다 — 나중에 언어를 바꾸면 같은 기록도 그 언어로 다시 그려진다.
/// (언어별 저장을 도입하기 전에 저장된 예전 기록은 단일 문자열이라 그대로 표시된다.)
class ResultCardView extends StatelessWidget {
  const ResultCardView({super.key, required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final name = resolveLocalizedText(result['name'], language);
    final category = resolveLocalizedText(result['category'], language);
    final usage = resolveLocalizedText(result['usage'], language);
    final hazards = resolveLocalizedList(result['hazards'], language);
    final requiredPpe = resolveLocalizedList(result['required_ppe'], language);
    final prohibited = resolveLocalizedList(result['prohibited'], language);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(name: name, category: category, usage: usage),
        if (hazards.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SafetySection(
            title: language.hazardsTitle,
            icon: Icons.warning_amber_rounded,
            items: hazards,
            background: Colors.orange.shade50,
            accent: Colors.orange.shade800,
          ),
        ],
        if (requiredPpe.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SafetySection(
            title: language.ppeTitle,
            icon: Icons.health_and_safety,
            items: requiredPpe,
            background: Colors.blue.shade50,
            accent: Colors.blue.shade800,
          ),
        ],
        if (prohibited.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SafetySection(
            title: language.prohibitedTitle,
            icon: Icons.block,
            items: prohibited,
            background: Colors.red.shade50,
            accent: Colors.red.shade800,
          ),
        ],
        const SizedBox(height: 16),
        _ManagerNoticeBox(text: language.managerNotice),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.name,
    required this.category,
    required this.usage,
  });

  final String name;
  final String category;
  final String usage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (!_isUnknown(category)) ...[
            const SizedBox(height: 6),
            Text(
              category,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
          if (!_isUnknown(usage)) ...[
            const SizedBox(height: 12),
            Text(usage, style: const TextStyle(fontSize: 16, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

class _SafetySection extends StatelessWidget {
  const _SafetySection({
    required this.title,
    required this.icon,
    required this.items,
    required this.background,
    required this.accent,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final Color background;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 26),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•  ',
                    style: TextStyle(
                      fontSize: 17,
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 17, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerNoticeBox extends StatelessWidget {
  const _ManagerNoticeBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.campaign, color: AppColors.accentDark, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.accentDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
