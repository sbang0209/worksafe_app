import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../history_service.dart';
import '../language_service.dart';
import '../result_localization.dart';
import '../signage_data.dart';
import '../widgets/common.dart';
import '../widgets/history_card.dart';
import '../widgets/signage_image.dart';
import '../widgets/signage_sheet.dart';
import 'history_detail_screen.dart';

/// 홈 검색창에서 여는 앱 안 검색. 표지판(이름·설명)과 분석 기록(이름·분류)을
/// 현재 언어 기준으로 찾는다.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<HistoryEntry> _history = const [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final entries = await HistoryService.instance.getAll();
    if (!mounted) return;
    setState(() => _history = entries);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _matches(Iterable<String> texts) {
    final q = _query.toLowerCase();
    return texts.any((t) => t.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final hasQuery = _query.isNotEmpty;
    final signs = hasQuery
        ? signageCatalog
              .where(
                (s) => _matches([
                  s.name(language),
                  s.description(language),
                  // 한국어 현장 용어로도 찾을 수 있게 한국어 이름도 함께 본다.
                  s.nameKo,
                ]),
              )
              .toList()
        : const <Signage>[];
    final records = hasQuery
        ? _history
              .where(
                (e) => _matches([
                  resolveLocalizedText(e.result['name'], language),
                  resolveLocalizedText(e.result['category'], language),
                ]),
              )
              .toList()
        : const <HistoryEntry>[];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 20, 8),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.chevron_left,
                    iconSize: 28,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) =>
                          setState(() => _query = value.trim()),
                      decoration: InputDecoration(
                        hintText: language.searchPlaceholder,
                        hintStyle: const TextStyle(color: AppColors.textFaint),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.fieldBg,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !hasQuery
                  ? const SizedBox.shrink()
                  : signs.isEmpty && records.isEmpty
                  ? Center(
                      child: Text(
                        language.noSearchResultMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        if (signs.isNotEmpty) ...[
                          _ResultLabel(language.signageLabel),
                          for (final signage in signs)
                            _SignageRow(
                              signage: signage,
                              language: language,
                              onTap: () => showSignageSheet(context, signage),
                            ),
                        ],
                        if (records.isNotEmpty) ...[
                          _ResultLabel(language.historyLabel),
                          for (final entry in records)
                            HistoryCard(
                              entry: entry,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HistoryDetailScreen(entry: entry),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultLabel extends StatelessWidget {
  const _ResultLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 16, 0, 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textFaint,
        ),
      ),
    );
  }
}

class _SignageRow extends StatelessWidget {
  const _SignageRow({
    required this.signage,
    required this.language,
    required this.onTap,
  });

  final Signage signage;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = signage.type;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: type.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SignageImage(
                icon: signage.icon,
                color: signage.color,
                assetPath: signage.imageAsset,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signage.name(language),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${signTypeName(type, language)} · '
                    '${categoryName(signage.category, language)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: type.color,
                    ),
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
