import 'package:flutter/material.dart';

import '../history_service.dart';
import '../language_service.dart';
import '../widgets/history_card.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry>? _entries;

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

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    return Scaffold(
      appBar: AppBar(title: Text(language.historyLabel)),
      body: _buildBody(language),
    );
  }

  Widget _buildBody(AppLanguage language) {
    final entries = _entries;
    if (entries == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              language.noHistoryMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 높이의 1/6 근처를 카드 한 칸의 기준 높이로 삼되,
        // 너무 빡빡해지지 않도록 최소 높이를 둔다.
        final itemExtent = (constraints.maxHeight / 6).clamp(96.0, 160.0);
        return RefreshIndicator(
          onRefresh: reload,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemExtent: itemExtent,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: HistoryCard(
                  entry: entry,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HistoryDetailScreen(entry: entry),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
