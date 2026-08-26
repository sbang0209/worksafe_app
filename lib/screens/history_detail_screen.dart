import 'dart:io';

import 'package:flutter/material.dart';

import '../history_service.dart';
import '../language_service.dart';
import '../widgets/result_card_view.dart';

/// 기록 목록에서 항목을 눌렀을 때 보여주는 상세 화면.
/// 촬영 직후 결과 화면과 같은 [ResultCardView] 를 재사용한다.
///
/// 두 가지 방식으로 쓰인다:
/// - [onBack] 없이 [Navigator.push] 로 열리면(카메라 중복 촬영 다이얼로그의
///   "기록 보기" 등), 뒤로가기는 그 경로를 그냥 pop 한다.
/// - [onBack] 을 주면(최근 기록 탭 안에서 목록 대신 바꿔 끼우는 경우), 실제로
///   pop 할 경로가 없으므로 그 콜백으로 목록으로 돌아간다 — 이렇게 하면 상세를
///   보는 동안에도 하단 탭바가 계속 보인다.
class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.entry, this.onBack});

  final HistoryEntry entry;
  final VoidCallback? onBack;

  void _handleBack(BuildContext context) {
    final back = onBack;
    if (back != null) {
      back();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    return Scaffold(
      appBar: AppBar(
        title: Text(language.historyDetailTitle),
        // onBack 으로 열렸을 때는 pop 할 경로가 없어 자동 뒤로가기 화살표가
        // 뜨지 않는다 — 직접 달아준다.
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleBack(context),
              )
            : null,
      ),
      body: SafeArea(
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
              ResultCardView(result: entry.result, showDetailsToggle: false),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _handleBack(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(language.backToListButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
