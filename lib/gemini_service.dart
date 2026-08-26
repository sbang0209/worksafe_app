import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'language_service.dart';
import 'result_localization.dart';

/// 사용할 Gemini 모델명. 404(모델 없음) 오류가 나면 여기만 바꾸면 됩니다.
/// 'gemini-2.5-flash-lite' 는 무료 등급에서 쓸 수 있는 경량 모델로,
/// 503 혼잡 상황에서 회복이 빠릅니다.
const String kGeminiModel = 'gemini-2.5-flash-lite';

/// 서버 과부하(503) 등 일시적 오류 재시도 설정.
/// 최대 4회 재시도하며 대기 시간은 2 → 4 → 8 → 16초로 늘어납니다.
const int _maxRetries = 4;
const int _firstRetryDelaySeconds = 2;

/// 분석 프롬프트. 나중에 언어를 바꿔도 기존 기록이 그 언어로 보이게 하려고,
/// 한 번의 호출로 6항목 모두 ko(한국어)/en(영어)/vi(베트남어) 3개 언어를 동시에
/// 받는다. 지시문 자체는 한국어로 두고, 최상위 키와 언어 키(ko/en/vi)는
/// 항상 영어 그대로 유지한다.
const String _analyzePrompt = '''
너는 한국 산업 현장의 안전 도우미다. 사진 속 물건을 보고 아래 JSON 형식으로만 답해라.
설명 문장이나 마크다운 없이 순수 JSON 만 출력해라.
기계 조작법이나 작동 순서는 절대 생성하지 마라. 위험요소와 금지행동 위주로만 답해라.

각 항목의 값은 ko(한국어) / en(영어) / vi(베트남어) 3개 언어로 모두 채워라.
모르면 각 언어에 맞는 "모름" 표현을 써라 (ko: '알 수 없음', en: 'Unknown', vi: 'Không rõ').
최상위 키(name, category, usage, hazards, required_ppe, prohibited)와
언어 키(ko/en/vi)는 항상 영어 그대로 두고, 그 안의 문자열/리스트 값만 해당 언어로 작성해라.

{
  "name": {"ko": "물건 이름 (한 줄)", "en": "item name", "vi": "tên vật"},
  "category": {"ko": "분류 (예: 목공 절단 기계, 사무기기 등)", "en": "category", "vi": "phân loại"},
  "usage": {"ko": "이 물건을 현장에서 어떤 작업에 쓰는지 한 문장", "en": "usage sentence", "vi": "câu mô tả cách dùng"},
  "hazards": {"ko": ["위험요소1", "위험요소2"], "en": ["hazard1", "hazard2"], "vi": ["nguy cơ 1", "nguy cơ 2"]},
  "required_ppe": {"ko": ["필요한 보호구1"], "en": ["required ppe 1"], "vi": ["thiết bị bảo hộ 1"]},
  "prohibited": {"ko": ["하지 말아야 할 행동1"], "en": ["prohibited action 1"], "vi": ["hành động cấm 1"]}
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
  /// 반환 키: name, category, usage, hazards, required_ppe, prohibited.
  /// 각 값은 `{'ko': ..., 'en': ..., 'vi': ...}` 형태로 3개 언어를 모두 담는다
  /// (name/category/usage 는 String 맵, hazards/required_ppe/prohibited 는
  /// `List<String>` 맵). 나중에 언어를 바꿔도 이 기록을 그 언어로 보여줄 수 있다.
  ///
  /// manager_notice 는 더 이상 이 Map 에 포함하지 않는다 — AI 생성이 아니라
  /// 항상 코드에서 고정으로 붙이는 문구라, 표시 시점에 현재 언어로 바로 그려준다
  /// ([ResultCardView] 참고).
  Future<Map<String, dynamic>> analyzeObject(File image) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('GeminiService: .env 에 GEMINI_API_KEY 가 없습니다');
      return _fallback((l) => l.errorNoApiKey);
    }

    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _analyzePrompt},
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
              ? (l) => l.errorServerBusy
              : (l) => l.errorStatusCodeTemplate.replaceFirst(
                  '{code}',
                  '${response.statusCode}',
                ),
        );
      }

      // 한글이 깨지지 않도록 UTF-8 로 직접 디코딩
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final text = _extractText(decoded);

      if (text == null || text.trim().isEmpty) {
        debugPrint('GeminiService: 텍스트를 찾지 못했습니다. body=${response.body}');
        return _fallback((l) => l.errorGeneric);
      }

      return _parseResult(text);
    } catch (e, stack) {
      debugPrint('GeminiService.analyzeObject 실패: $e');
      debugPrint('$stack');
      return _fallback((l) => l.errorNetworkOrApi);
    }
  }

  /// 2단계 호환용. 물건 이름 한 줄만 필요할 때 사용한다.
  Future<String> identifyObject(File image) async {
    final result = await analyzeObject(image);
    return resolveLocalizedText(result['name'], AppLanguage.ko);
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
  Map<String, dynamic> _parseResult(String text) {
    final cleaned = _stripCodeFence(text);
    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) {
        debugPrint('GeminiService: JSON 이 객체가 아닙니다. 원본 텍스트:\n$text');
        return _fallback((l) => l.errorGeneric);
      }
      return _normalize(Map<String, dynamic>.from(decoded));
    } catch (e) {
      debugPrint('GeminiService: JSON 파싱 실패: $e');
      debugPrint('GeminiService: 원본 텍스트:\n$text');
      return _fallback((l) => l.errorGeneric);
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

  /// 키 누락이나 타입 불일치(문자열 하나만 온 경우 등)를 화면에서 쓰기 좋게 정리하고,
  /// 6항목 모두 언어별({'ko': ..., 'en': ..., 'vi': ...}) 구조로 맞춘다.
  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    return {
      'name': _asLocalizedText(raw['name']),
      'category': _asLocalizedText(raw['category']),
      'usage': _asLocalizedText(raw['usage']),
      'hazards': _asLocalizedList(raw['hazards']),
      'required_ppe': _asLocalizedList(raw['required_ppe']),
      'prohibited': _asLocalizedList(raw['prohibited']),
    };
  }

  /// raw 값이 `{'ko': ..., 'en': ..., 'vi': ...}` 맵이라고 가정하고, 언어별로
  /// 빠졌거나 형식이 이상한 값은 그 언어의 '모름' 문구로 채운다.
  Map<String, String> _asLocalizedText(dynamic value) {
    final map = value is Map ? value : const {};
    return {
      for (final language in AppLanguage.all)
        language.code: _pickText(map[language.code], language),
    };
  }

  String _pickText(dynamic value, AppLanguage language) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return language.unknownLabel;
  }

  Map<String, List<String>> _asLocalizedList(dynamic value) {
    final map = value is Map ? value : const {};
    return {
      for (final language in AppLanguage.all)
        language.code: _pickList(map[language.code]),
    };
  }

  List<String> _pickList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) return [value.trim()];
    return [];
  }

  /// 실패했을 때도 화면이 깨지지 않도록 같은(언어별) 형태의 Map 을 돌려준다.
  /// [pickErrorMessage] 로 각 언어별 에러 문구를 골라 'name' 자리에 채운다.
  Map<String, dynamic> _fallback(
    String Function(AppLanguage language) pickErrorMessage,
  ) {
    final unknown = {
      for (final language in AppLanguage.all)
        language.code: language.unknownLabel,
    };
    final emptyList = {
      for (final language in AppLanguage.all) language.code: <String>[],
    };
    return {
      'name': {
        for (final language in AppLanguage.all)
          language.code: pickErrorMessage(language),
      },
      'category': unknown,
      'usage': unknown,
      'hazards': emptyList,
      'required_ppe': emptyList,
      'prohibited': emptyList,
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
