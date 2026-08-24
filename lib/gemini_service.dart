import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'language_service.dart';

/// 사용할 Gemini 모델명. 404(모델 없음) 오류가 나면 여기만 바꾸면 됩니다.
/// 'gemini-2.5-flash-lite' 는 무료 등급에서 쓸 수 있는 경량 모델로,
/// 503 혼잡 상황에서 회복이 빠릅니다.
const String kGeminiModel = 'gemini-2.5-flash-lite';

/// 서버 과부하(503) 등 일시적 오류 재시도 설정.
/// 최대 4회 재시도하며 대기 시간은 2 → 4 → 8 → 16초로 늘어납니다.
const int _maxRetries = 4;
const int _firstRetryDelaySeconds = 2;

/// [language] 로 값을 채우도록 지시하는 분석 프롬프트를 만든다.
/// 지시문 자체는 한국어로 두고, "값은 이 언어로 써라" 만 지정한다.
/// JSON 의 키 이름(name, category 등)은 항상 영어 그대로 유지한다.
String _analyzePrompt(AppLanguage language) =>
    '''
너는 한국 산업 현장의 안전 도우미다. 사진 속 물건을 보고 아래 JSON 형식으로만 답해라.
설명 문장이나 마크다운 없이 순수 JSON 만 출력해라. 모르면 값을 '${language.unknownLabel}' 으로 채워라.
기계 조작법이나 작동 순서는 절대 생성하지 마라. 위험요소와 금지행동 위주로만 답해라.
JSON 의 키 이름은 그대로 영어로 두고, 문자열/리스트 값은 모두 ${language.promptName} 로 작성해라.

{
  "name": "물건 이름 (한 줄)",
  "category": "분류 (예: 목공 절단 기계, 사무기기 등)",
  "usage": "이 물건을 현장에서 어떤 작업에 쓰는지 한 문장",
  "hazards": ["위험요소1", "위험요소2"],
  "required_ppe": ["필요한 보호구1", "보호구2"],
  "prohibited": ["하지 말아야 할 행동1", "행동2"]
}
''';

/// 사진 한 장을 Gemini REST API 에 보내고 구조화된 안전 정보를 받아오는 서비스.
class GeminiService {
  GeminiService._();

  static final GeminiService instance = GeminiService._();

  Uri get _endpoint => Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$kGeminiModel:generateContent',
  );

  /// 이미지 파일을 보내 구조화된 분석 결과를 돌려준다.
  /// 예외를 던지지 않고, 실패 시에도 항상 같은 형태의 Map 을 반환한다.
  ///
  /// 반환 키: name, category, usage, hazards, required_ppe, prohibited,
  ///          manager_notice (항상 코드에서 추가)
  Future<Map<String, dynamic>> analyzeObject(File image) async {
    final language = await LanguageService.instance.getLanguage();

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('GeminiService: .env 에 GEMINI_API_KEY 가 없습니다');
      return _fallback(language.errorNoApiKey, language);
    }

    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _analyzePrompt(language)},
              {
                'inline_data': {
                  'mime_type': _mimeTypeOf(image.path),
                  'data': base64Image,
                },
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.2,
          'response_mime_type': 'application/json',
        },
      });

      final response = await _postWithRetry(body, apiKey);

      if (response.statusCode != 200) {
        debugPrint('GeminiService 응답 오류 statusCode: ${response.statusCode}');
        debugPrint('GeminiService 응답 body: ${response.body}');
        // 재시도를 모두 소진하고도 혼잡 상태면 안내 문구를 그대로 보여준다
        final busy =
            response.statusCode == 503 ||
            response.statusCode == 429 ||
            response.statusCode == 500;
        return _fallback(
          busy
              ? language.errorServerBusy
              : language.errorStatusCodeTemplate.replaceFirst(
                  '{code}',
                  '${response.statusCode}',
                ),
          language,
        );
      }

      // 한글이 깨지지 않도록 UTF-8 로 직접 디코딩
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final text = _extractText(decoded);

      if (text == null || text.trim().isEmpty) {
        debugPrint('GeminiService: 텍스트를 찾지 못했습니다. body=${response.body}');
        return _fallback(language.errorGeneric, language);
      }

      return _parseResult(text, language);
    } catch (e, stack) {
      debugPrint('GeminiService.analyzeObject 실패: $e');
      debugPrint('$stack');
      return _fallback(language.errorNetworkOrApi, language);
    }
  }

  /// 2단계 호환용. 물건 이름 한 줄만 필요할 때 사용한다.
  Future<String> identifyObject(File image) async {
    final result = await analyzeObject(image);
    return (result['name'] as String?) ?? '인식할 수 없습니다';
  }

  /// 503(서버 과부하) 등 일시적 오류면 지수 백오프로 재시도한다.
  /// 대기 시간: 2초 → 4초 → 8초 → 16초 (최대 $_maxRetries 회)
  Future<http.Response> _postWithRetry(String body, String apiKey) async {
    http.Response? last;
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      last = await http.post(
        _endpoint,
        headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
        body: body,
      );

      final retryable =
          last.statusCode == 503 ||
          last.statusCode == 429 ||
          last.statusCode == 500;
      if (!retryable || attempt == _maxRetries) return last;

      // 2 * 2^attempt → 2, 4, 8, 16초
      final waitSeconds = _firstRetryDelaySeconds * (1 << attempt);
      debugPrint(
        'GeminiService: ${last.statusCode} 응답, $waitSeconds초 대기 후 '
        '재시도 (${attempt + 1}/$_maxRetries)',
      );
      await Future.delayed(Duration(seconds: waitSeconds));
    }
    return last!;
  }

  /// 응답 텍스트에서 JSON 을 뽑아 Map 으로 만든다.
  Map<String, dynamic> _parseResult(String text, AppLanguage language) {
    final cleaned = _stripCodeFence(text);
    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) {
        debugPrint('GeminiService: JSON 이 객체가 아닙니다. 원본 텍스트:\n$text');
        return _fallback(language.errorGeneric, language);
      }
      final result = _normalize(Map<String, dynamic>.from(decoded), language);
      result['manager_notice'] = language.managerNotice;
      return result;
    } catch (e) {
      debugPrint('GeminiService: JSON 파싱 실패: $e');
      debugPrint('GeminiService: 원본 텍스트:\n$text');
      return _fallback(language.errorGeneric, language);
    }
  }

  /// ```json ... ``` 코드펜스나 앞뒤 잡음을 걷어낸다.
  String _stripCodeFence(String text) {
    var s = text.trim();

    // 코드펜스 제거
    if (s.startsWith('```')) {
      final firstNewline = s.indexOf('\n');
      if (firstNewline != -1) s = s.substring(firstNewline + 1);
      final closing = s.lastIndexOf('```');
      if (closing != -1) s = s.substring(0, closing);
      s = s.trim();
    }

    // 그래도 앞뒤에 설명 문장이 붙어 있으면 첫 '{' ~ 마지막 '}' 만 취한다
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start != -1 && end > start) {
      s = s.substring(start, end + 1);
    }
    return s.trim();
  }

  /// 키 누락이나 타입 불일치(문자열 하나만 온 경우 등)를 화면에서 쓰기 좋게 정리한다.
  Map<String, dynamic> _normalize(
    Map<String, dynamic> raw,
    AppLanguage language,
  ) {
    return {
      'name': _asText(raw['name'], language),
      'category': _asText(raw['category'], language),
      'usage': _asText(raw['usage'], language),
      'hazards': _asList(raw['hazards']),
      'required_ppe': _asList(raw['required_ppe']),
      'prohibited': _asList(raw['prohibited']),
    };
  }

  String _asText(dynamic value, AppLanguage language) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return language.unknownLabel;
  }

  List<String> _asList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) return [value.trim()];
    return [];
  }

  /// 실패했을 때도 화면이 깨지지 않도록 같은 형태의 Map 을 돌려준다.
  Map<String, dynamic> _fallback(String name, AppLanguage language) {
    return {
      'name': name,
      'category': language.unknownLabel,
      'usage': language.unknownLabel,
      'hazards': <String>[],
      'required_ppe': <String>[],
      'prohibited': <String>[],
      'manager_notice': language.managerNotice,
    };
  }

  /// candidates[0].content.parts[0].text 를 안전하게 꺼낸다.
  String? _extractText(dynamic json) {
    try {
      final candidates = json['candidates'];
      if (candidates is! List || candidates.isEmpty) return null;
      final parts = candidates[0]['content']?['parts'];
      if (parts is! List || parts.isEmpty) return null;
      // 첫 part 에 text 가 없을 수도 있으니 text 가 있는 첫 part 를 찾는다
      for (final part in parts) {
        final text = part is Map ? part['text'] : null;
        if (text is String && text.trim().isNotEmpty) return text;
      }
      return null;
    } catch (e) {
      debugPrint('GeminiService: 응답 파싱 실패: $e');
      return null;
    }
  }

  String _mimeTypeOf(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
