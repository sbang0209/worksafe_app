import 'package:flutter/material.dart';

const String _unknown = '알 수 없음';

/// [GeminiService.analyzeObject] 가 돌려주는 분석 결과 Map 을
/// 카드 UI 로 그려주는 위젯.
///
/// 촬영 직후 결과 화면과, 나중에 만들 기록 상세 화면에서 동일하게 재사용한다.
class ResultCardView extends StatelessWidget {
  const ResultCardView({super.key, required this.result});

  final Map<String, dynamic> result;

  String _text(String key) =>
      (result[key] as String?)?.trim().isNotEmpty == true
      ? (result[key] as String).trim()
      : _unknown;

  List<String> _list(String key) {
    final value = result[key];
    if (value is List) {
      return value
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final name = _text('name');
    final category = _text('category');
    final usage = _text('usage');
    final hazards = _list('hazards');
    final requiredPpe = _list('required_ppe');
    final prohibited = _list('prohibited');
    final managerNotice = (result['manager_notice'] as String?)?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(name: name, category: category, usage: usage),
        if (hazards.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SafetySection(
            title: '위험 요소',
            icon: Icons.warning_amber_rounded,
            items: hazards,
            background: Colors.orange.shade50,
            accent: Colors.orange.shade800,
          ),
        ],
        if (requiredPpe.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SafetySection(
            title: '필요 보호구',
            icon: Icons.health_and_safety,
            items: requiredPpe,
            background: Colors.blue.shade50,
            accent: Colors.blue.shade800,
          ),
        ],
        if (prohibited.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SafetySection(
            title: '금지 행동',
            icon: Icons.block,
            items: prohibited,
            background: Colors.red.shade50,
            accent: Colors.red.shade800,
          ),
        ],
        if (managerNotice != null && managerNotice.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ManagerNoticeBox(text: managerNotice),
        ],
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (category != _unknown) ...[
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
          if (usage != _unknown) ...[
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
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade800, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.campaign, color: Colors.amber.shade900, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
