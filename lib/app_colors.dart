import 'package:flutter/material.dart';

/// WorkSafe 디자인 시스템 색 팔레트
///
/// 화이트 배경 + 세이프티 틸(브랜드) + 뉴트럴 그레이 + 의미 색(위험/주의/필수).
/// 색상은 홈·표지판·분석 결과 등 리디자인 시안에서 실제 사용한 값과 일치합니다.
/// 새 화면을 만들 때도 색을 직접 고르지 말고 여기서 가져다 쓴다.
///
/// 사용 예:
///   Container(color: AppColors.brand)
///   Text('위험', style: TextStyle(color: AppColors.danger))
abstract final class AppColors {
  // ── 브랜드 (세이프티 틸) ────────────────────────────────
  /// 메인 브랜드 색 · 하단 카메라 FAB, 주요 버튼, 활성 상태
  static const Color brand = Color(0xFF0E8A80);
  static const Color brandDark = Color(0xFF0B6F67); // 눌림/hover
  static const Color brandTintBg = Color(0xFFE4F5F1); // 아이콘 칩 배경
  static const Color brandOnDark = Color(0xFFBFEAE4); // 틸 위 보조 텍스트

  // ── 배경 / 표면 ────────────────────────────────────────
  static const Color background = Color(0xFFF5F6F6); // 화면 기본 배경(흰색)
  static const Color surface = Color(0xFFFFFFFF); // 카드 표면
  static const Color surfaceMuted = Color(0xFFF0F1F1); // 옅은 내부 박스
  static const Color fieldBg = Color(0xFFEBECEC); // 검색바·비활성 칩
  static const Color thumbBg = Color(0xFFE2E3E3); // 썸네일 플레이스홀더

  // ── 보더 ───────────────────────────────────────────────
  static const Color border = Color(0xFFE3E4E4); // 카드 테두리(기본)
  static const Color borderStrong = Color(0xFFDDDEDE);
  static const Color divider = Color(0xFFE5E6E6); // 리스트 구분선

  // ── 텍스트 (뉴트럴) ────────────────────────────────────
  static const Color textPrimary = Color(0xFF1C1B19); // 본문/제목
  static const Color textSecondary = Color(0xFF8B8B8B); // 보조 텍스트
  static const Color textMuted = Color(0xFF9A9A9A); // 타임스탬프 등
  static const Color textFaint = Color(0xFFABABAB); // 섹션 라벨

  // ── 의미 색: 위험도 / 표지판 등급 ──────────────────────
  /// 위험(금지·경고 최상위)
  static const Color danger = Color(0xFFE23B2E);
  static const Color dangerBg = Color(0xFFFBEEEA);

  /// 주의(경고)
  static const Color warning = Color(0xFFB5730A);
  static const Color warningIcon = Color(0xFFE9932B);
  static const Color warningBg = Color(0xFFFBF3E6);

  /// 필수(지시)
  static const Color mandatory = Color(0xFF2F6FD0);
  static const Color mandatoryBg = Color(0xFFEAF1FB);

  /// 공지 강조(폭염·긴급)
  static const Color alert = Color(0xFFE2542E);
  static const Color alertBg = Color(0xFFFDECEA);

  // ── 실제 표지판 도형 색 (KOSHA 규격 근사) ──────────────
  static const Color signWarnFill = Color(0xFFF5C21A); // 노란 경고 삼각형
  static const Color signWarnStroke = Color(0xFF1C1B19);
  static const Color signMandatoryFill = Color(0xFF1E63C8); // 파란 지시 원
  static const Color signProhibitRing = Color(0xFFD42B1E); // 빨간 금지 원/사선

  // ── 다크 표면 (카메라 화면) ────────────────────────────
  static const Color cameraBg = Color(0xFF1A1A1A);
  static const Color cameraControlBg = Color(0xFF2A2A2A);
  static const Color shutter = Color(0xFFFFFFFF);
}

/// 라이트 테마에 팔레트를 연결한다. main.dart 의 MaterialApp.theme 으로 쓴다.
ThemeData buildWorkSafeTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.brand,
    primary: AppColors.brand,
    surface: AppColors.surface,
    error: AppColors.danger,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.divider,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  );
}
