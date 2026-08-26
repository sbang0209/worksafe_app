import 'language_service.dart';

/// 분석 결과 Map 안의 한 필드 값(문자열)을 현재 언어로 뽑아낸다.
///
/// 새 형식(`{'ko': ..., 'en': ..., 'vi': ...}` 맵)과, 언어별 동시 저장을 도입하기
/// 전에 저장된 예전 형식(단일 문자열)을 모두 처리한다. 현재 언어 값이 없으면
/// 한국어로, 그마저 없으면 있는 값 아무거나로 대체하고, 끝내 아무 값도 없으면
/// [AppLanguage.unknownLabel] 을 돌려준다.
String resolveLocalizedText(dynamic value, AppLanguage language) {
  if (value is Map) {
    final direct = value[language.code];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();
    final ko = value['ko'];
    if (ko is String && ko.trim().isNotEmpty) return ko.trim();
    for (final other in value.values) {
      if (other is String && other.trim().isNotEmpty) return other.trim();
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
    final direct = asStringList(value[language.code]);
    if (direct.isNotEmpty) return direct;
    final ko = asStringList(value['ko']);
    if (ko.isNotEmpty) return ko;
    for (final other in value.values) {
      final list = asStringList(other);
      if (list.isNotEmpty) return list;
    }
    return const [];
  }
  return asStringList(value);
}
