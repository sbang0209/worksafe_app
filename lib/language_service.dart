import 'package:shared_preferences/shared_preferences.dart';

/// 분석 결과(6항목 + manager_notice)를 받을 언어.
class AppLanguage {
  const AppLanguage._({
    required this.code,
    required this.label,
    required this.promptName,
    required this.unknownLabel,
    required this.managerNotice,
  });

  /// shared_preferences 에 저장되는 값 (ko/en/vi)
  final String code;

  /// 언어 설정 화면에 보여줄 이름
  final String label;

  /// Gemini 프롬프트에 "이 언어로 답해라" 라고 넣을 때 쓰는 이름
  final String promptName;

  /// 해당 필드를 모를 때 쓰는 고정 문구 ('알 수 없음' 에 해당)
  final String unknownLabel;

  /// 관리자 확인 안내. AI 생성이 아니라 언어별로 코드에서 고정 삽입한다.
  final String managerNotice;

  static const ko = AppLanguage._(
    code: 'ko',
    label: '한국어',
    promptName: '한국어',
    unknownLabel: '알 수 없음',
    managerNotice: '정확한 작동 방법은 반드시 현장 관리자에게 확인하세요',
  );

  static const en = AppLanguage._(
    code: 'en',
    label: 'English',
    promptName: 'English',
    unknownLabel: 'Unknown',
    managerNotice:
        'Always confirm the correct operation with your on-site manager.',
  );

  static const vi = AppLanguage._(
    code: 'vi',
    label: 'Tiếng Việt',
    promptName: 'Tiếng Việt (Vietnamese)',
    unknownLabel: 'Không rõ',
    managerNotice:
        'Hãy luôn xác nhận cách vận hành chính xác với quản lý hiện trường.',
  );

  static const all = [ko, en, vi];

  static AppLanguage fromCode(String? code) {
    return all.firstWhere((l) => l.code == code, orElse: () => ko);
  }
}

/// "분석 결과를 받을 언어" 설정을 shared_preferences 에 저장/조회하는 서비스.
class LanguageService {
  LanguageService._();

  static final LanguageService instance = LanguageService._();

  static const _prefsKey = 'result_language';

  /// 저장된 언어를 돌려준다. 저장된 값이 없으면 기본값(한국어).
  Future<AppLanguage> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return AppLanguage.fromCode(prefs.getString(_prefsKey));
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  }
}
