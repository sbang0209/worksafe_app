import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'language_service.dart';
import 'result_localization.dart';

/// 최근 기록의 배지·필터에 쓰는 위험도 등급.
enum RiskLevel { danger, caution, mandatory }

/// 기록 하나의 위험도 요약. 배지에는 "위험 2" 처럼 [level] 과 [count] 가 함께 뜬다.
class RiskSummary {
  const RiskSummary(this.level, this.count);

  final RiskLevel level;
  final int count;

  /// Gemini 결과에는 위험도 값이 따로 없어서, 목록 항목 수로 등급을 정한다.
  /// - 위험 요소(hazards)가 있으면 → 위험 (위험 요소 개수)
  /// - 없고 금지 행동(prohibited)만 있으면 → 주의 (금지 행동 개수)
  /// - 둘 다 없고 필요 보호구(required_ppe)만 있으면 → 필수 (보호구 개수)
  /// - 셋 다 비어 있으면(인식 실패 등) null — 배지를 그리지 않는다.
  ///
  /// 언어마다 항목 수가 달라 배지가 바뀌지 않도록 개수는 한국어 기준으로 센다.
  static RiskSummary? of(Map<String, dynamic> result) {
    int count(String key) =>
        resolveLocalizedList(result[key], AppLanguage.ko).length;
    final hazards = count('hazards');
    if (hazards > 0) return RiskSummary(RiskLevel.danger, hazards);
    final prohibited = count('prohibited');
    if (prohibited > 0) return RiskSummary(RiskLevel.caution, prohibited);
    final ppe = count('required_ppe');
    if (ppe > 0) return RiskSummary(RiskLevel.mandatory, ppe);
    return null;
  }
}

extension RiskLevelStyle on RiskLevel {
  String label(AppLanguage language) {
    switch (this) {
      case RiskLevel.danger:
        return language.levelDangerLabel;
      case RiskLevel.caution:
        return language.levelCautionLabel;
      case RiskLevel.mandatory:
        return language.levelMandatoryLabel;
    }
  }

  /// 배지 글자색.
  Color get color {
    switch (this) {
      case RiskLevel.danger:
        return AppColors.danger;
      case RiskLevel.caution:
        return AppColors.warning;
      case RiskLevel.mandatory:
        return AppColors.mandatory;
    }
  }

  Color get background {
    switch (this) {
      case RiskLevel.danger:
        return AppColors.dangerBg;
      case RiskLevel.caution:
        return AppColors.warningBg;
      case RiskLevel.mandatory:
        return AppColors.mandatoryBg;
    }
  }
}
