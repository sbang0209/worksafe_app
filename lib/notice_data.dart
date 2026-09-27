import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'language_service.dart';

/// 공지 등급. 홈 카드와 상세 화면의 태그 색을 정한다.
enum NoticeLevel { urgent, campaign }

extension NoticeLevelStyle on NoticeLevel {
  String label(AppLanguage language) => switch (this) {
    NoticeLevel.urgent => language.noticeUrgentLabel,
    NoticeLevel.campaign => language.noticeCampaignLabel,
  };

  Color get color => switch (this) {
    NoticeLevel.urgent => AppColors.alert,
    NoticeLevel.campaign => AppColors.mandatory,
  };

  Color get background => switch (this) {
    NoticeLevel.urgent => AppColors.alertBg,
    NoticeLevel.campaign => AppColors.mandatoryBg,
  };
}

/// 안전 공지 하나.
///
/// 문구는 언어별 맵(ko/en/vi)이라 [resolveLocalizedText] 로 꺼내고, 다른 언어는
/// 영어로 대체된다. [points] 안의 '**...**' 는 굵게 표시된다.
class SafetyNotice {
  const SafetyNotice({
    required this.id,
    required this.level,
    required this.icon,
    required this.topic,
    required this.title,
    required this.source,
    required this.date,
    required this.highlight,
    required this.points,
    required this.url,
  });

  final String id;
  final NoticeLevel level;
  final IconData icon;

  /// 등급 태그 옆의 회색 주제 태그 (예: '폭염').
  final Map<String, String> topic;
  final Map<String, String> title;

  /// 발표 기관. 기관명은 번역하지 않는다.
  final String source;
  final DateTime date;

  /// 상세 화면 상단의 강조 박스 문구.
  final Map<String, String> highlight;

  /// 언어 코드 → 주요 안내 문장 목록.
  final Map<String, List<String>> points;

  /// "원문 보기" 로 여는 주소.
  final Uri url;
}

/// 시연용 공지 목록(최신순). 실제 공지 API 가 없어서 목업 고정값을 쓴다.
/// 날짜는 "오늘 / 3일 전" 으로 보이도록 실행 시각 기준으로 만든다.
List<SafetyNotice> safetyNotices() {
  final now = DateTime.now();
  return [
    SafetyNotice(
      id: 'heatwave',
      level: NoticeLevel.urgent,
      icon: Icons.wb_sunny_outlined,
      topic: const {'ko': '폭염', 'en': 'Heatwave', 'vi': 'Nắng nóng'},
      title: const {
        'ko': '폭염 특보 — 야외 작업 시 시간당 10분 휴식',
        'en': 'Heat advisory — take a 10-minute break every hour outdoors',
        'vi': 'Cảnh báo nắng nóng — nghỉ 10 phút mỗi giờ khi làm ngoài trời',
      },
      source: '안전보건공단(KOSHA)',
      date: now,
      highlight: const {
        'ko': '오늘 낮 최고 35℃ · 폭염경보 발효 중',
        'en': 'High of 35℃ today · Heat warning in effect',
        'vi': 'Cao nhất 35℃ hôm nay · Đang có cảnh báo nắng nóng',
      },
      points: const {
        'ko': [
          '매시간 **10분 이상** 그늘에서 휴식하고, 물을 자주 마셔 주세요.',
          '가장 더운 **14~17시**에는 옥외 중작업을 피하세요.',
          '어지러움·메스꺼움 등 온열질환 증상이 있으면 즉시 관리자에게 알리세요.',
        ],
        'en': [
          'Rest in the shade for **at least 10 minutes** every hour and drink water often.',
          'Avoid heavy outdoor work during the hottest hours, **2–5 PM**.',
          'If you feel dizzy or sick from the heat, tell your manager right away.',
        ],
        'vi': [
          'Mỗi giờ hãy nghỉ trong bóng râm **ít nhất 10 phút** và uống nước thường xuyên.',
          'Tránh làm việc nặng ngoài trời vào giờ nóng nhất **14–17 giờ**.',
          'Nếu chóng mặt, buồn nôn do nóng, hãy báo ngay cho quản lý.',
        ],
      },
      url: Uri.https('www.kosha.or.kr', '/'),
    ),
    SafetyNotice(
      id: 'fall-prevention',
      level: NoticeLevel.campaign,
      icon: Icons.campaign_outlined,
      topic: const {'ko': '추락', 'en': 'Falls', 'vi': 'Té ngã'},
      title: const {
        'ko': '9월 추락재해 예방 집중 점검 기간',
        'en': 'September fall-prevention inspection period',
        'vi': 'Đợt kiểm tra phòng chống tai nạn té ngã tháng 9',
      },
      source: '고용노동부',
      date: now.subtract(const Duration(days: 3)),
      highlight: const {
        'ko': '9월 한 달간 전국 사업장 집중 점검',
        'en': 'Nationwide workplace inspections all of September',
        'vi':
            'Kiểm tra tập trung các nơi làm việc trên toàn quốc trong tháng 9',
      },
      points: const {
        'ko': [
          '높이 **2m 이상**에서 작업할 때는 반드시 안전대를 걸어 주세요.',
          '사다리는 **2인 1조**로 사용하고, 맨 위 발판에 올라서지 마세요.',
          '개구부·단부에 안전난간이 없으면 작업 전에 관리자에게 알리세요.',
        ],
        'en': [
          'Always hook on a safety harness when working **2 m or higher**.',
          'Use ladders **in pairs** and never stand on the top step.',
          'If an opening or edge has no guardrail, tell your manager before work.',
        ],
        'vi': [
          'Luôn móc dây an toàn khi làm việc ở độ cao **từ 2 m trở lên**.',
          'Sử dụng thang **theo nhóm 2 người** và không đứng lên bậc trên cùng.',
          'Nếu lỗ mở hoặc mép sàn không có lan can, hãy báo quản lý trước khi làm.',
        ],
      },
      url: Uri.https('www.moel.go.kr', '/'),
    ),
  ];
}
