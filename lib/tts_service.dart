import 'package:flutter_tts/flutter_tts.dart';

import 'language_service.dart';

/// 표지판 설명 등을 음성으로 읽어주는 서비스.
///
/// 화면 여러 곳에서 재사용할 수 있게 싱글턴으로 두고, 새로 읽기 시작하면
/// 이전에 재생 중이던 음성은 항상 먼저 멈춘다.
class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();

  static const Map<String, String> _localeByLanguageCode = {
    'ko': 'ko-KR',
    'en': 'en-US',
    'vi': 'vi-VN',
  };

  /// [language] 에 해당하는 로케일(ko-KR/en-US/vi-VN)로 [text] 를 읽는다.
  ///
  /// 폰이 그 언어의 음성을 지원하지 않으면 아무 것도 읽지 않고 false 를
  /// 돌려준다 — 호출한 쪽에서 안내 문구를 보여주면 된다. 정상적으로 재생을
  /// 시작하면 true.
  Future<bool> speak(String text, AppLanguage language) async {
    final locale = _localeByLanguageCode[language.code] ?? 'ko-KR';

    await _tts.stop();

    final availability = await _tts.isLanguageAvailable(locale);
    // 플랫폼에 따라 bool(true/false) 또는 int(1/0) 로 온다.
    final available = availability == true || availability == 1;
    if (!available) return false;

    await _tts.setLanguage(locale);
    await _tts.speak(text);
    return true;
  }

  /// 재생 중인 음성을 멈춘다. 이미 멈춰 있어도 안전하게 호출할 수 있다.
  Future<void> stop() => _tts.stop();
}
