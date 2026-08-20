import 'dart:io';

import 'package:flutter/material.dart';

import '../history_service.dart';
import '../widgets/result_card_view.dart';

/// 기록 목록에서 항목을 눌렀을 때 보여주는 상세 화면.
/// 촬영 직후 결과 화면과 같은 [ResultCardView] 를 재사용한다.
class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기록 상세')),
      body: Container(
        color: kResultBackground,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 260,
                    child: Image.file(
                      File(entry.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ResultCardView(result: entry.result),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('목록으로'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
