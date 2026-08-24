import 'package:flutter/material.dart';

import '../history_service.dart';
import '../language_service.dart';
import '../widgets/history_card.dart';
import 'camera_screen.dart';
import 'history_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onViewAllHistory});

  /// "전체 보기" 를 눌렀을 때 최근 기록 탭으로 이동시키는 콜백. [MainTabScreen] 이 준다.
  final VoidCallback onViewAllHistory;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const _previewCount = 3;

  List<HistoryEntry>? _recentEntries;

  @override
  void initState() {
    super.initState();
    reload();
  }

  /// 최근 기록 미리보기를 다시 불러온다. 홈 탭으로 돌아올 때마다 [MainTabScreen] 이 호출한다.
  Future<void> reload() async {
    final all = await HistoryService.instance.getAll();
    if (!mounted) return;
    setState(() => _recentEntries = all.take(_previewCount).toList());
  }

  Future<void> _openCamera() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CameraScreen()));
    // 카메라 화면에서 돌아오면(촬영 완료든 뒤로가기든) 새 기록이 있을 수 있으니 새로고침.
    reload();
  }

  void _openHistoryDetail(HistoryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HistoryDetailScreen(entry: entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    return Scaffold(
      appBar: AppBar(title: const Text('WorkSafe')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: _openCamera,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(64),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: const Icon(Icons.camera_alt, size: 28),
                label: Text(language.takePhotoButton),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      language.historyLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onViewAllHistory,
                    child: Text(language.viewAllButton),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildHistoryPreview(language),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryPreview(AppLanguage language) {
    final entries = _recentEntries;
    if (entries == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            language.noHistoryMessage,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 76,
              child: HistoryCard(
                entry: entry,
                compact: true,
                onTap: () => _openHistoryDetail(entry),
              ),
            ),
          ),
      ],
    );
  }
}
