import 'language_service.dart';

/// 분석 결과 Map 안의 한 필드 값(문자열)을 현재 언어로 뽑아낸다.
///
/// 새 형식(`{'ko': ..., 'en': ..., ...}` 맵)과, 언어별 동시 저장을 도입하기
/// 전에 저장된 예전 형식(단일 문자열)을 모두 처리한다. 현재 언어 값이 없으면
/// (예: 캄보디아어 추가 전에 저장된 기록) 영어 → 한국어 → 있는 값 아무거나 순으로
/// 대체하고, 끝내 아무 값도 없으면 [AppLanguage.unknownLabel] 을 돌려준다.
/// 외국인 근로자에게는 한국어보다 영어가 더 읽기 쉬워서 영어를 먼저 쓴다.
String resolveLocalizedText(dynamic value, AppLanguage language) {
  if (value is Map) {
    final direct = value[language.code];
    // 모름 문구만 채워진 언어는 건너뛰고 다른 언어 값을 쓴다.
    if (_isFilled(direct, language)) return direct.trim();
    for (final code in const ['en', 'ko']) {
      final other = value[code];
      if (_isFilled(other, AppLanguage.fromCode(code))) return other.trim();
    }
    for (final entry in value.entries) {
      final other = entry.value;
      if (_isFilled(other, AppLanguage.fromCode('${entry.key}'))) {
        return other.trim();
      }
    }
    return language.unknownLabel;
  }
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return language.unknownLabel;
}

/// [resolveLocalizedText] 의 리스트 버전. hazards/required_ppe/prohibited 처럼
/// 언어별로 문자열 리스트를 담은 필드에 쓴다.
List<String> resolveLocalizedList(dynamic value, AppLanguage language) {
  List<String> asStringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  if (value is Map) {
    for (final code in [language.code, 'en', 'ko']) {
      final list = asStringList(value[code]);
      if (list.isNotEmpty) return list;
    }
    for (final other in value.values) {
      final list = asStringList(other);
      if (list.isNotEmpty) return list;
    }
    return const [];
  }
  return asStringList(value);
}

/// [value] 가 비어 있지 않고, 그 언어의 '모름' 문구만 들어 있는 것도 아닌지.
bool _isFilled(dynamic value, AppLanguage language) =>
    value is String &&
    value.trim().isNotEmpty &&
    value.trim() != language.unknownLabel;
