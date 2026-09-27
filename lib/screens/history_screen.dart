import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../history_service.dart';
import '../language_service.dart';
import '../risk_level.dart';
import '../widgets/common.dart';
import '../widgets/history_card.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry>? _entries;

  /// null 이면 목록을, 아니면 이 기록의 상세를 보여준다. [Navigator.push] 대신
  /// 상태로 전환해서, 상세를 보는 동안에도 하단 탭바가 계속 보이고 다른 탭으로
  /// 바로 넘어갈 수 있다.
  HistoryEntry? _selectedEntry;

  /// 위험도 필터. null 이면 전체.
  RiskLevel? _filter;

  @override
  void initState() {
    super.initState();
    reload();
  }

  /// 최신 기록을 다시 불러온다. 탭을 다시 선택했을 때 [MainTabScreen] 이 호출한다.
  Future<void> reload() async {
    final entries = await HistoryService.instance.getAll();
    if (!mounted) return;
    setState(() => _entries = entries);
  }

  void _openDetail(HistoryEntry entry) {
    setState(() => _selectedEntry = entry);
  }

  void _closeDetail() {
    setState(() => _selectedEntry = null);
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final selected = _selectedEntry;
    // 상세를 보는 중에 기기 뒤로가기(제스처/버튼)를 누르면 앱을 벗어나지 않고
    // 목록으로만 돌아가게 한다 — 실제로 pop 할 경로가 없기 때문이다.
    return PopScope(
      canPop: selected == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selected != null) {
          _closeDetail();
        }
      },
      child: selected != null
          ? HistoryDetailScreen(entry: selected, onBack: _closeDetail)
          : Scaffold(
              body: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      title: language.historyLabel,
                      countTemplate: language.historyCountTemplate,
                      count: _entries?.length,
                    ),
                    _FilterChips(
                      language: language,
                      selected: _filter,
                      onSelected: (level) => setState(() => _filter = level),
                    ),
                    Expanded(child: _buildBody(language)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBody(AppLanguage language) {
    final entries = _entries;
    if (entries == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final filter = _filter;
    final visible = filter == null
        ? entries
        : entries.where((e) => RiskSummary.of(e.result)?.level == filter);
    if (visible.isEmpty) {
      return _EmptyMessage(
        entries.isEmpty
            ? language.noHistoryMessage
            : language.noFilteredHistoryMessage,
      );
    }

    // 최신순 목록을 날짜별로 묶고, 날짜가 바뀔 때마다 묶음 제목을 끼워 넣는다.
    final rows = <Widget>[];
    String? currentDate;
    for (final entry in visible) {
      final date = entry.formattedDate;
      if (date != currentDate) {
        currentDate = date;
        rows.add(_DateLabel(_dateLabel(entry, language)));
      }
      rows.add(HistoryCard(entry: entry, onTap: () => _openDetail(entry)));
    }

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        // 하단 바가 떠 있어 내용이 그 뒤로 이어지므로, 끝에 바 높이만큼 여백을 둔다.
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: rows,
      ),
    );
  }

  /// 오늘/어제는 글자로, 그 전은 날짜로 보여준다.
  String _dateLabel(HistoryEntry entry, AppLanguage language) =>
      relativeDayLabel(entry.timestamp, language) ?? entry.formattedDate;
}

/// "최근 기록" 큰 제목 + "지금까지 N건 분석" 요약.
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.countTemplate,
    required this.count,
  });

  final String title;

  /// '{count}' 자리에 강조된 숫자가 들어간다.
  final String countTemplate;

  /// null 이면 아직 불러오는 중이라 요약 줄을 비워 둔다.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final count = this.count;
    final parts = countTemplate.split('{count}');
    const baseStyle = TextStyle(fontSize: 15, color: AppColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LargeTitle(title),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              style: baseStyle,
              children: count == null
                  ? const [TextSpan(text: ' ')]
                  : [
                      TextSpan(text: parts.first),
                      TextSpan(
                        text: '$count',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.brand,
                        ),
                      ),
                      if (parts.length > 1) TextSpan(text: parts[1]),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 전체 / 위험 / 주의 / 필수 필터 칩 줄.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.language,
    required this.selected,
    required this.onSelected,
  });

  final AppLanguage language;
  final RiskLevel? selected;
  final ValueChanged<RiskLevel?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <(RiskLevel?, String)>[
      (null, language.filterAllLabel),
      for (final level in RiskLevel.values) (level, level.label(language)),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          for (final (level, label) in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterPill(
                label: label,
                selected: level == selected,
                onTap: () => onSelected(level),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 0, 6),
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

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 56, color: AppColors.textFaint),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
