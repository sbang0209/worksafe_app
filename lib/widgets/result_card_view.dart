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
///
/// 기본적으로는(즉 [showDetailsToggle] 이 true 일 때) 물건 정보(이름/분류/용도)와
/// "자세히 보기" 바만 보이고, 그 바를 누르면 위험 요소/필요 보호구/금지 행동/
/// 관리자 확인 문구가 펼쳐진다. 펼침 상태는 이 위젯이 스스로 들고 있어서, 화면
/// 하단 버튼(다시 찍기/홈, 목록으로 등)은 건드리지 않고 그대로 둘 수 있다.
///
/// [showDetailsToggle] 을 false 로 주면(기록 상세 화면) 토글 바 없이 모든 정보를
/// 항상 펼쳐서 보여준다 — 이미 저장된 기록이라 다시 접어 둘 이유가 없기 때문이다.
class ResultCardView extends StatefulWidget {
  const ResultCardView({
    super.key,
    required this.result,
    this.showDetailsToggle = true,
  });

  final Map<String, dynamic> result;
  final bool showDetailsToggle;

  @override
  State<ResultCardView> createState() => _ResultCardViewState();
}

class _ResultCardViewState extends State<ResultCardView> {
  bool _expanded = false;

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final result = widget.result;
    final name = resolveLocalizedText(result['name'], language);
    final category = resolveLocalizedText(result['category'], language);
    final usage = resolveLocalizedText(result['usage'], language);
    final hazards = resolveLocalizedList(result['hazards'], language);
    final requiredPpe = resolveLocalizedList(result['required_ppe'], language);
    final prohibited = resolveLocalizedList(result['prohibited'], language);
    final expanded = widget.showDetailsToggle ? _expanded : true;

    final detailsSection = _DetailsSection(
      hazards: hazards,
      requiredPpe: requiredPpe,
      prohibited: prohibited,
      hazardsTitle: language.hazardsTitle,
      ppeTitle: language.ppeTitle,
      prohibitedTitle: language.prohibitedTitle,
      managerNotice: language.managerNotice,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(name: name, category: category, usage: usage),
        const SizedBox(height: 16),
        if (widget.showDetailsToggle) ...[
          _DetailsBar(
            label: expanded ? language.simpleViewLabel : language.detailsLabel,
            expanded: expanded,
            onTap: _toggleExpanded,
          ),
          // 펼침/접힘을 높이 애니메이션으로 부드럽게 처리한다(홈 공지사항과 같은 방식).
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: detailsSection,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ] else
          detailsSection,
      ],
    );
  }
}

/// 폭 전체를 채우는 "자세히 보기 / 간단히 보기" 바. 앱 테마의 노란색 계열
/// 배경으로 눈에 띄게 하고, 글자와 화살표를 크게 둔다.
class _DetailsBar extends StatelessWidget {
  const _DetailsBar({
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.banner,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentDark,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.accentDark,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "자세히 보기" 를 펼쳤을 때 보이는 위험 요소/필요 보호구/금지 행동/관리자 문구.
class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.hazards,
    required this.requiredPpe,
    required this.prohibited,
    required this.hazardsTitle,
    required this.ppeTitle,
    required this.prohibitedTitle,
    required this.managerNotice,
  });

  final List<String> hazards;
  final List<String> requiredPpe;
  final List<String> prohibited;
  final String hazardsTitle;
  final String ppeTitle;
  final String prohibitedTitle;
  final String managerNotice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hazards.isNotEmpty) ...[
          _SafetySection(
            title: hazardsTitle,
            icon: Icons.warning_amber_rounded,
            items: hazards,
            background: Colors.orange.shade50,
            accent: Colors.orange.shade800,
          ),
          const SizedBox(height: 16),
        ],
        if (requiredPpe.isNotEmpty) ...[
          _SafetySection(
            title: ppeTitle,
            icon: Icons.health_and_safety,
            items: requiredPpe,
            background: Colors.blue.shade50,
            accent: Colors.blue.shade800,
          ),
          const SizedBox(height: 16),
        ],
        if (prohibited.isNotEmpty) ...[
          _SafetySection(
            title: prohibitedTitle,
            icon: Icons.block,
            items: prohibited,
            background: Colors.red.shade50,
            accent: Colors.red.shade800,
          ),
          const SizedBox(height: 16),
        ],
        _ManagerNoticeBox(text: managerNotice),
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
