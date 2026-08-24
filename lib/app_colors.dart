import 'package:flutter/material.dart';

/// 앱 전체가 공유하는 색 팔레트. 홈 화면 디자인(노란색 계열)을 기준으로 삼는다.
///
/// 카메라 화면, 최근 기록, 메뉴, 결과 카드, 다이얼로그 등은 모두 이 상수를 통해
/// 색을 참조한다 — 새 화면을 만들 때도 색을 직접 고르지 말고 여기서 가져다 쓴다.
///
/// 예외: 분석 결과의 위험 요소(빨강/주황)·필요 보호구(파랑)·금지 행동(빨강) 강조색과
/// 표지판 카테고리별 색은 안전상 의미가 있는 색이라 이 팔레트를 따르지 않고
/// (result_card_view.dart, signage_data.dart) 그대로 유지한다.
class AppColors {
  AppColors._();

  /// ThemeData.colorScheme 이 파생되는 시드 컬러.
  static const seed = Colors.amber;

  /// 화면 배경(옅은 아이보리/노랑). ThemeData.scaffoldBackgroundColor 로 전역 적용된다.
  static const background = Color(0xFFFFFBEA);

  /// 강조색 — 선택된 상태, 아이콘, 버튼 텍스트 등.
  static final accent = Colors.amber.shade800;
  static final accentDark = Colors.amber.shade900;
  static final accentLight = Colors.amber.shade100;
  static final accentBorder = Colors.amber.shade200;
  static final accentSoft = Colors.amber.shade50;

  /// 안내 배너(홈 화면 안전 멘트) 배경.
  static final banner = Colors.amber.shade300;

  /// 선택되지 않은 상태(하단 탭 등)에 쓰는 중립색.
  static final neutral = Colors.grey.shade500;

  /// 카드에 쓰는 은은한 그림자.
  static final cardShadow = Colors.black.withValues(alpha: 0.08);
}
