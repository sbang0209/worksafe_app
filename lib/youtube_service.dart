import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'language_service.dart';
import 'result_localization.dart';

/// YouTube 검색 결과 한 건 (카드에 보여줄 값만).
class YoutubeVideo {
  const YoutubeVideo({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
  });

  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;

  /// 외부 브라우저/유튜브 앱으로 열 시청 주소.
  Uri get watchUrl => Uri.https('www.youtube.com', '/watch', {'v': videoId});
}

/// 분석 결과의 장비 이름으로 관련 안전 영상을 찾는 서비스.
///
/// 어떤 실패(키 없음, 네트워크, 쿼터, 파싱 등)에도 예외를 밖으로 던지지 않고
/// 빈 리스트를 돌려준다 — 호출한 화면은 빈 리스트면 영상 영역을 그리지 않으면 된다.
class YoutubeService {
  YoutubeService._();

  static final YoutubeService instance = YoutubeService._();

  static const _maxResults = 3;
  static const _requestTimeout = Duration(seconds: 10);

  /// 언어별 "안전" 키워드. 검색어 끝에 붙는다.
  static const Map<String, String> _safetyKeywordByLanguageCode = {
    'ko': '안전수칙',
    'en': 'safety',
    'vi': 'an toàn',
    'km': 'សុវត្ថិភាព',
    'ne': 'सुरक्षा',
    'th': 'ความปลอดภัย',
  };

  /// 성공한 조회 결과 캐시 (검색어 → 영상). 기록 상세를 여러 번 열어도 같은
  /// 검색어는 API 를 한 번만 부른다. 실패는 캐시하지 않아 다음에 다시 시도한다.
  final Map<String, List<YoutubeVideo>> _cache = {};

  /// 아직 응답을 기다리는 조회. 같은 검색어를 동시에 두 번 부르지 않게 한다.
  final Map<String, Future<List<YoutubeVideo>>> _inFlight = {};

  /// 분석 [result] 의 장비 이름으로 관련 영상을 찾는다.
  ///
  /// 현재 언어로 먼저 찾고, 결과가 0개면 영어로, 그래도 0개면 한국어로
  /// 다시 찾는다(이미 시도한 언어는 건너뛴다) — 현지어 이름은 영상이 잘 안
  /// 잡히는 경우가 많아서, 국제적으로 더 널리 쓰이는 언어로 넓혀가며 찾는다.
  /// 셋 다 0개거나 검색어를 만들 수 없으면 빈 리스트.
  Future<List<YoutubeVideo>> searchRelated(Map<String, dynamic> result) async {
    try {
      final currentCode = LanguageService.instance.current.code;
      final codesToTry = <String>[currentCode];
      for (final fallback in ['en', 'ko']) {
        if (!codesToTry.contains(fallback)) codesToTry.add(fallback);
      }

      for (final code in codesToTry) {
        final language = AppLanguage.fromCode(code);
        final query = _buildQuery(result, language);
        if (query == null) continue;

        final videos = await _searchByQuery(query, language);
        if (videos.isNotEmpty) {
          debugPrint(
            'YoutubeService: "${language.code}" 언어로 영상을 찾음 '
            '(검색어: "$query", ${videos.length}건)',
          );
          return videos;
        }
      }
      return const [];
    } catch (e, stack) {
      debugPrint('YoutubeService.searchRelated 실패: $e');
      debugPrint('$stack');
      return const [];
    }
  }

  /// [query] 하나에 대한 캐시/진행 중 조회 중복 방지. 실제 API 호출은
  /// [_fetch] 가 한다.
  Future<List<YoutubeVideo>> _searchByQuery(
    String query,
    AppLanguage language,
  ) {
    final cached = _cache[query];
    if (cached != null) return Future.value(cached);

    final pending = _inFlight[query];
    if (pending != null) return pending;

    final future = _fetch(
      query,
      language,
    ).whenComplete(() => _inFlight.remove(query));
    _inFlight[query] = future;
    return future;
  }

  /// [language] 로 검색어를 만든다. 검색하면 안 되는 이름이면 null.
  ///
  /// 장비 이름 전체("PLC 트레이너 및 자동화 실습장비")로 검색하면 결과가 안 나와서,
  /// 이름에서 괄호를 지우고 앞 2단어만 남긴 뒤 그 언어의 안전 키워드를 붙인다.
  /// (예: 'PLC 트레이너 안전수칙', 'PLC trainer safety')
  String? _buildQuery(Map<String, dynamic> result, AppLanguage language) {
    final name = resolveLocalizedText(result['name'], language).trim();
    if (name.isEmpty) return null;
    // 어떤 언어의 '모름' 문구든(분석 실패/알 수 없음) 검색하지 않는다.
    for (final l in AppLanguage.all) {
      if (name == l.unknownLabel) return null;
    }

    final withoutParens = name.replaceAll(RegExp(r'[(（][^)）]*[)）]'), ' ');
    final words = withoutParens
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .toList();
    if (words.isEmpty) return null;

    final keyword =
        _safetyKeywordByLanguageCode[language.code] ??
        _safetyKeywordByLanguageCode['en']!;
    return '${words.join(' ')} $keyword';
  }

  Future<List<YoutubeVideo>> _fetch(String query, AppLanguage language) async {
    final apiKey = dotenv.env['YOUTUBE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('YoutubeService: .env 에 YOUTUBE_API_KEY 가 없습니다');
      return const [];
    }

    try {
      final params = {
        'part': 'snippet',
        'type': 'video',
        'maxResults': '$_maxResults',
        'q': query,
        'relevanceLanguage': language.code,
        'safeSearch': 'strict',
        'key': apiKey,
      };
      // 한국어로 검색할 때만 한국 지역 가중치를 준다 — 다른 언어권에서는
      // 오히려 관련성이 떨어질 수 있다.
      if (language.code == 'ko') {
        params['regionCode'] = 'KR';
      }
      final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', params);
      final response = await http.get(uri).timeout(_requestTimeout);
      if (response.statusCode != 200) {
        debugPrint('YoutubeService 응답 오류 statusCode: ${response.statusCode}');
        debugPrint('YoutubeService 응답 body: ${response.body}');
        return const [];
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final items = decoded is Map ? decoded['items'] : null;
      if (items is! List) return const [];

      final videos = items
          .map(_parseItem)
          .whereType<YoutubeVideo>()
          .toList(growable: false);
      // 결과 0개도 "정상 응답"이라 캐시한다(같은 검색어를 다시 부르지 않는다).
      _cache[query] = videos;
      return videos;
    } catch (e, stack) {
      debugPrint('YoutubeService 조회 실패: $e');
      debugPrint('$stack');
      return const [];
    }
  }

  YoutubeVideo? _parseItem(dynamic item) {
    if (item is! Map) return null;
    final id = item['id'];
    final videoId = id is Map ? id['videoId'] : null;
    final snippet = item['snippet'];
    if (videoId is! String || videoId.isEmpty || snippet is! Map) return null;

    final title = snippet['title'];
    final thumbnails = snippet['thumbnails'];
    final medium = thumbnails is Map ? thumbnails['medium'] : null;
    final thumbnailUrl = medium is Map ? medium['url'] : null;
    if (title is! String || title.isEmpty) return null;
    if (thumbnailUrl is! String || thumbnailUrl.isEmpty) return null;

    final channel = snippet['channelTitle'];
    return YoutubeVideo(
      videoId: videoId,
      title: _unescapeHtml(title),
      channelTitle: channel is String ? _unescapeHtml(channel) : '',
      thumbnailUrl: thumbnailUrl,
    );
  }

  /// YouTube API 는 제목의 특수문자를 HTML 엔티티로 돌려준다.
  String _unescapeHtml(String text) => text
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');
}
