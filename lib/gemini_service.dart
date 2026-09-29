import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'language_service.dart';
import 'result_localization.dart';
import 'signage_data.dart';

/// 사용할 Gemini 모델명. 404(모델 없음) 오류가 나면 여기만 바꾸면 됩니다.
/// 6개 언어를 한 번에 채워야 해서 경량 모델('gemini-2.5-flash-lite')로는 일부
/// 언어가 누락되는 일이 잦아 상위 모델('gemini-2.5-flash')로 올렸습니다.
/// 무료 등급의 하루 호출 한도가 flash-lite 보다 낮으니 테스트할 때 주의하세요.
/// quickIdentify 도 같은 상수를 씁니다.
const String kGeminiModel = 'gemini-3.5-flash-lite';

/// 서버 과부하(503) 등 일시적 오류 재시도 설정.
/// 최대 4회 재시도하며 대기 시간은 2 → 4 → 8 → 16초로 늘어납니다.
const int _maxRetries = 4;
const int _firstRetryDelaySeconds = 2;

/// 분석 프롬프트. 나중에 언어를 바꿔도 기존 기록이 그 언어로 보이게 하려고,
/// 한 번의 호출로 6항목 모두 [AppLanguage.all] 의 모든 언어를 동시에 받는다.
/// 지시문 자체는 한국어로 두고, 최상위 키와 언어 키(ko/en/...)는 항상 영어
/// 그대로 유지한다. 언어를 추가하면 이 프롬프트도 자동으로 따라간다.
String _buildAnalyzePrompt() {
  final languages = AppLanguage.all;
  final codes = languages.map((l) => l.code).join('/');
  final languageList = languages
      .map((l) => '${l.code}(${l.promptName})')
      .join(', ');
  final unknowns = languages
      .map((l) => "${l.code}: '${l.unknownLabel}'")
      .join(', ');
  String textExample(String example) =>
      '{${languages.map((l) => '"${l.code}": "$example"').join(', ')}}';
  String listExample(String example) =>
      '{${languages.map((l) => '"${l.code}": ["$example"]').join(', ')}}';
  // 앱에 등록된 표지판의 한국어 이름 후보. 하드코딩하지 않고 카탈로그에서 모은다
  // (같은 이름이 여러 카테고리에 있어도 한 번만).
  final signageNames = signageCatalog
      .map((s) => '"${s.nameKo}"')
      .toSet()
      .join(', ');

  return '''
너는 한국 산업 현장의 안전 도우미다. 사진 속 물건을 보고 아래 JSON 형식으로만 답해라.
설명 문장이나 마크다운 없이 순수 JSON 만 출력해라.
기계 조작법이나 작동 순서는 절대 생성하지 마라. 위험요소와 금지행동 위주로만 답해라.

읽는 사람은 현장에서 그 장비를 실제로 다루는 숙련 작업자다. 초보자용 설명이 아니라
현장에서 통하는 수준으로 써라.
- category: 일반 명칭에 그치지 말고 기계 분류와 구동 방식까지 (예: "목공용 직선 절단 기계 / 원형 톱날 직구동")
- usage: 무엇에 쓰는지에 더해 어떤 가공 공정 단계에서 쓰는지
- hazards: "위험하다"로 끝내지 말고 위험이 생기는 메커니즘까지
  (예: "킥백 — 절단 중 소재가 톱날 뒷날에 물려 작업자 쪽으로 튐")
- required_ppe: 보호구 이름만 쓰지 말고 등급·규격이 통용되는 것은 함께
  (예: "차광번호 10 이상 용접면")
- prohibited: 왜 금지인지 이유를 한 구절 덧붙여라
각 항목은 한두 문장으로 간결하게 유지해라.

★ 중요: 기계 조작 방법, 작동 순서, 설정값은 여전히 절대 생성하지 마라.
장비마다 달라서 틀리면 그대로 사고로 이어진다. 이 원칙은 심화와 무관하게 유지한다.

표지판 처리 (signage_name):
signage_name 은 다른 항목과 달리 언어별 맵이 아니라 문자열 하나다. 값은 항상 한국어이며
앱 내부 조회용이라 번역하지 않는다. 아래 언어 규칙과 빈 문자열 금지 규칙은 이 키에 적용되지 않는다.
- 사진이 산업 안전 표지판이고 아래 목록에 있으면, 목록의 이름을 글자 그대로 복사한다.
  목록: $signageNames
- 목록에 없는 이름을 새로 지어내지 마라.
- 표지판이 아닌 일반 물건이면 "" 로 둔다.
- 사진이 표지판이지만 목록에 없으면 signage_name 은 "" 로 두고,
  나머지 항목을 그 표지판을 설명하는 내용으로 채워라:
  · name    : 표지판 이름
  · category: 표지판 유형 — 경고 / 지시 / 금지 중 하나.
              노란 삼각형=경고, 파란 원=지시, 빨간 사선 원=금지 로 판단해라.
              색과 모양을 반드시 확인해라. 이걸 틀리면 뜻이 정반대가 된다.
  · usage   : 이 표지가 붙은 곳에서 무엇을 뜻하는지 한 문장
  · hazards / required_ppe / prohibited : 그 표지가 경고·요구·금지하는 내용

각 항목의 값은 $languageList 언어로 모두 채워라.
모르면 각 언어에 맞는 "모름" 표현을 써라 ($unknowns).
최상위 키(name, category, usage, hazards, required_ppe, prohibited)와
언어 키($codes)는 항상 영어 그대로 두고, 그 안의 문자열/리스트 값만 해당 언어로 작성해라.
hazards, required_ppe, prohibited 는 모든 언어에서 항목 수와 순서를 같게 맞춰라.

언어 규칙 (반드시 지켜라):
- 모든 언어 키를 하나도 빠짐없이 채워라. 키 누락, 빈 문자열, 빈 배열은 오답이다.
- 각 언어 키 안의 값은 반드시 그 언어로 써라. 예를 들어 vi 키에 영어 문장을 넣으면 오답이다.
- 한 언어로 쓴 다음 나머지 키에 그대로 복사하지 마라. 각 언어로 실제로 번역해라.
- 제품명, 규격 번호, PLC·CNC 같은 약어는 원문 그대로 둬도 된다. 억지로 음차하지 마라.
- 정말 모르는 항목만 그 언어의 "모름" 표현을 쓴다. 귀찮다고 "모름"으로 채우지 마라.

{
  "name": ${textExample('물건 이름 (한 줄)')},
  "category": ${textExample('기계 분류와 구동 방식 (예: 목공용 직선 절단 기계 / 원형 톱날 직구동)')},
  "usage": ${textExample('어떤 가공 공정 단계에서 쓰는지 한 문장')},
  "hazards": ${listExample('위험요소와 그것이 발생하는 메커니즘')},
  "required_ppe": ${listExample('필요한 보호구 (등급·규격이 있으면 함께)')},
  "prohibited": ${listExample('하지 말아야 할 행동과 그 이유')},
  "signage_name": ""
}
''';
}

final String _analyzePrompt = _buildAnalyzePrompt();

/// analyzeObject 응답을 강제하는 JSON 스키마 (generationConfig.response_schema).
///
/// [_buildAnalyzePrompt] 처럼 [AppLanguage.all] 을 순회해 만들기 때문에 언어를
/// 추가하면 스키마도 자동으로 따라간다. 모든 항목의 모든 언어 키를 required 로
/// 두어, 프롬프트만으로는 막지 못하는 언어 키 누락을 API 단에서 막는다.
Map<String, dynamic> _buildResponseSchema() {
  final codes = AppLanguage.all.map((l) => l.code).toList();

  /// 언어 코드마다 [valueSchema] 를 값으로 갖는 OBJECT.
  Map<String, dynamic> perLanguage(Map<String, dynamic> valueSchema) => {
    'type': 'OBJECT',
    'properties': {for (final code in codes) code: valueSchema},
    'required': codes,
  };

  final textField = perLanguage({'type': 'STRING'});
  final listField = perLanguage({
    'type': 'ARRAY',
    'items': {'type': 'STRING'},
  });
  final Map<String, dynamic> properties = {
    'name': textField,
    'category': textField,
    'usage': textField,
    'hazards': listField,
    'required_ppe': listField,
    'prohibited': listField,
    // 언어별 맵이 아니라 한국어 문자열 하나. 표지판이 아니면 빈 문자열이라
    // required 여도 된다.
    'signage_name': {'type': 'STRING'},
  };

  if (kDebugMode) {
    debugPrint('GeminiService: response_schema 필수 언어 = ${codes.join(', ')}');
  }
  return {
    'type': 'OBJECT',
    'properties': properties,
    'required': properties.keys.toList(),
  };
}

final Map<String, dynamic> _responseSchema = _buildResponseSchema();

/// 카메라 프리뷰의 "분석" 버튼용 가벼운 프롬프트. [analyzeObject] 와 달리
/// 이름 + 한 줄 설명만, 현재 선택된 언어 하나로만 요청해서 빠르게 받는다.
String _quickPrompt(AppLanguage language) =>
    '''
너는 한국 산업 현장의 안전 도우미다. 사진 속 물건을 보고 아래 JSON 형식으로만 답해라.
설명 문장이나 마크다운 없이 순수 JSON 만 출력해라. 모르면 값을 '${language.unknownLabel}' 으로 채워라.
name 은 물건 이름 한 줄, description 은 그 물건이 무엇인지 한 문장으로 설명한 것이다.
두 값 모두 ${language.promptName} 로 작성해라.

{
  "name": "물건 이름",
  "description": "한 줄 설명"
}
''';

/// 안전 챗봇 대화 한 마디. [fromUser] 가 false 면 AI 가 한 말이다.
class ChatTurn {
  const ChatTurn({required this.fromUser, required this.text});

  final bool fromUser;
  final String text;
}

/// askSafetyQuestion 이 최근 몇 턴까지만 보내는지. 토큰을 아끼기 위함이다.
const int _maxChatHistoryTurns = 6;

/// 안전 챗봇 system_instruction. 지시문은 한국어로 두고, 답변 언어만
/// [language] 로 지정한다 — 언어를 추가해도 이 함수는 그대로 쓸 수 있다.
String _buildChatSystemInstruction(AppLanguage language) =>
    '''
너는 한국 산업 현장의 안전 도우미다. 외국인 근로자의 안전 관련 질문에 답한다.

반드시 지켜라:
- 기계의 조작 방법, 작동 순서, 설정값, 수리·분해 방법은 절대 알려주지 마라.
  장비마다 달라서 틀리면 그대로 사고로 이어진다. 그런 질문에는
  "장비마다 달라서 알려드릴 수 없습니다. 현장 관리자에게 확인하세요" 라고 답해라.
- 위험 요소, 보호구, 금지 행동, 안전 표지판의 뜻, 일반적인 안전 수칙은 답해도 된다.
- 의료 진단, 법률 자문, 안전과 무관한 잡담은 정중히 범위 밖이라고 답해라.
  단, 다쳤다는 말이 나오면 즉시 관리자에게 알리고 응급처치를 받으라고 안내해라.
- 확실하지 않으면 모른다고 말해라. 지어내지 마라.
- 답변은 ${language.promptName}로 쓰고, 3~5문장 이내로 짧게 해라.
- 마크다운 기호(**, ##, -)를 쓰지 마라. 순수 문장으로만 답해라. 화면이 마크다운을 렌더링하지 않는다.
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
  /// signage_name. signage_name 은 언어별 맵이 아니라 한국어 문자열 하나로,
  /// 앱에 등록된 표지판이면 그 nameKo, 아니면 ''.
  /// 나머지 각 값은 `{'ko': ..., 'en': ..., ...}` 형태로 [AppLanguage.all] 의 언어를 모두 담는다
  /// (name/category/usage 는 String 맵, hazards/required_ppe/prohibited 는
  /// `List<String>` 맵). 나중에 언어를 바꿔도 이 기록을 그 언어로 보여줄 수 있다.
  ///
  /// manager_notice 는 더 이상 이 Map 에 포함하지 않는다 — AI 생성이 아니라
  /// 항상 코드에서 고정으로 붙이는 문구라, 표시 시점에 현재 언어로 바로 그려준다
  /// ([AnalysisResultPage] 참고).
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
          'response_schema': _responseSchema,
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

  /// 카메라 프리뷰의 "분석" 버튼용 가벼운 분석. [analyzeObject] 와 달리
  /// 이름 + 한 줄 설명만 요청해서 빠르게 받고, 기록에 저장하지 않는다.
  /// 현재 선택된 언어로만 결과를 받는다 — 화면에 바로 보여주고 버리는
  /// 일회성 결과라 3개 언어를 다 받아 둘 필요가 없다.
  ///
  /// 예외를 던지지 않고, 실패 시에도 항상 같은 형태의 Map(name, description
  /// 키를 가진 일반 문자열)을 반환한다.
  /// 실패 시 'error' 키가 'true' 로 들어온다(이때 name 은 오류 문구).
  Future<Map<String, String>> quickIdentify(File image) async {
    final language = await LanguageService.instance.getLanguage();

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('GeminiService: .env 에 GEMINI_API_KEY 가 없습니다');
      return _quickFallback(language.errorNoApiKey, language);
    }

    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _quickPrompt(language)},
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
        debugPrint(
          'GeminiService(quick) 응답 오류 statusCode: ${response.statusCode}',
        );
        debugPrint('GeminiService(quick) 응답 body: ${response.body}');
        final busy =
            response.statusCode == 503 ||
            response.statusCode == 429 ||
            response.statusCode == 500;
        return _quickFallback(
          busy
              ? language.errorServerBusy
              : language.errorStatusCodeTemplate.replaceFirst(
                  '{code}',
                  '${response.statusCode}',
                ),
          language,
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final text = _extractText(decoded);

      if (text == null || text.trim().isEmpty) {
        debugPrint(
          'GeminiService(quick): 텍스트를 찾지 못했습니다. body=${response.body}',
        );
        return _quickFallback(language.errorGeneric, language);
      }

      return _parseQuickResult(text, language);
    } catch (e, stack) {
      debugPrint('GeminiService.quickIdentify 실패: $e');
      debugPrint('$stack');
      return _quickFallback(language.errorNetworkOrApi, language);
    }
  }

  Map<String, String> _parseQuickResult(String text, AppLanguage language) {
    final cleaned = _stripCodeFence(text);
    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) {
        debugPrint('GeminiService(quick): JSON 이 객체가 아닙니다. 원본 텍스트:\n$text');
        return _quickFallback(language.errorGeneric, language);
      }
      return {
        'name': _pickText(decoded['name'], language),
        'description': _pickText(decoded['description'], language),
      };
    } catch (e) {
      debugPrint('GeminiService(quick): JSON 파싱 실패: $e');
      debugPrint('GeminiService(quick): 원본 텍스트:\n$text');
      return _quickFallback(language.errorGeneric, language);
    }
  }

  Map<String, String> _quickFallback(String name, AppLanguage language) {
    return {
      'name': name,
      'description': language.unknownLabel,
      'error': 'true',
    };
  }

  /// 안전 챗봇 질문에 답한다. [history] 는 오래된 순서대로 담긴 전체 대화이고,
  /// 토큰을 아끼려고 최근 [_maxChatHistoryTurns] 턴만 실제로 보낸다.
  /// 응답은 JSON 이 아니라 일반 문장이라 response_mime_type/response_schema 는
  /// 쓰지 않는다.
  ///
  /// 예외를 던지지 않고, 실패 시에도 사용자에게 보여줄 오류 문구를 문자열로
  /// 돌려준다(기존 오류 문구를 재사용한다).
  Future<String> askSafetyQuestion(List<ChatTurn> history) async {
    final language = await LanguageService.instance.getLanguage();

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('GeminiService: .env 에 GEMINI_API_KEY 가 없습니다');
      return language.errorNoApiKey;
    }

    final recent = history.length > _maxChatHistoryTurns
        ? history.sublist(history.length - _maxChatHistoryTurns)
        : history;

    try {
      final body = jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': _buildChatSystemInstruction(language)},
          ],
        },
        'contents': [
          for (final turn in recent)
            {
              'role': turn.fromUser ? 'user' : 'model',
              'parts': [
                {'text': turn.text},
              ],
            },
        ],
        'generationConfig': {'temperature': 0.4},
      });

      final response = await _postWithRetry(body, apiKey);

      if (response.statusCode != 200) {
        debugPrint(
          'GeminiService(chat) 응답 오류 statusCode: ${response.statusCode}',
        );
        debugPrint('GeminiService(chat) 응답 body: ${response.body}');
        final busy =
            response.statusCode == 503 ||
            response.statusCode == 429 ||
            response.statusCode == 500;
        return busy
            ? language.errorServerBusy
            : language.errorStatusCodeTemplate.replaceFirst(
                '{code}',
                '${response.statusCode}',
              );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final text = _extractText(decoded);
      if (text == null || text.trim().isEmpty) {
        debugPrint('GeminiService(chat): 텍스트를 찾지 못했습니다. body=${response.body}');
        return language.errorGeneric;
      }
      return text.trim();
    } catch (e, stack) {
      debugPrint('GeminiService.askSafetyQuestion 실패: $e');
      debugPrint('$stack');
      return language.errorNetworkOrApi;
    }
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
      // 언어별 맵이 아닌 한국어 문자열 하나(없거나 형식이 다르면 빈 문자열).
      'signage_name': raw['signage_name'] is String
          ? (raw['signage_name'] as String).trim()
          : '',
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
      'signage_name': '',
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
