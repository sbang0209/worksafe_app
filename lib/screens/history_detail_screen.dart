import 'package:flutter/material.dart';

import '../history_service.dart';
import '../widgets/analysis_result_page.dart';

/// 기록 목록에서 항목을 눌렀을 때 보여주는 상세 화면.
/// 촬영 직후 결과 화면과 같은 [AnalysisResultPage] 를 재사용한다.
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

  @override
  Widget build(BuildContext context) {
    return AnalysisResultPage(
      imagePath: entry.imagePath,
      result: entry.result,
      onBack: onBack ?? () => Navigator.of(context).pop(),
    );
  }
}
