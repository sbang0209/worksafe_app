/// 화면 시연용 분석 기록 목업.
///
/// API 키 없이도 홈의 최근 분석, 기록 탭, 분석 결과 화면을 볼 수 있게 앱을
/// 처음 실행할 때 한 번만 기록에 넣는다([HistoryService.seedDemoIfNeeded]).
/// 사진은 assets/demo/ 의 자유 라이선스 사진(출처는 그 폴더의 CREDITS.md)이고,
/// 'asset' 키로 넘기면 기록을 넣을 때 기록 사진 폴더로 복사된다. 문구는 ko/en/vi 만 두고,
/// 다른 언어는 [resolveLocalizedText] 가 영어로 대체한다.
///
/// 시각은 넣는 순간을 기준으로 "오늘 / 어제 / 3일 전"에 흩어지게 만든다.
List<Map<String, dynamic>> demoHistoryEntries(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final threeDaysAgo = today.subtract(const Duration(days: 3));

  Map<String, dynamic> entry(
    String id,
    DateTime time,
    Map<String, dynamic> result,
  ) => {
    'id': 'demo-$id',
    'result': result,
    // 에셋 파일명은 id 의 '-' 를 '_' 로 바꾼 것 (예: table-saw → table_saw.jpg).
    'asset': 'assets/demo/${id.replaceAll('-', '_')}.jpg',
    'imagePath': '',
    'timestamp': time.toIso8601String(),
  };

  return [
    entry('table-saw', now.subtract(const Duration(minutes: 25)), {
      'name': {'ko': '테이블 쏘', 'en': 'Table Saw', 'vi': 'Máy cưa bàn'},
      'category': {
        'ko': '목공 절단 기계',
        'en': 'Woodworking cutting machine',
        'vi': 'Máy cắt gỗ',
      },
      'usage': {
        'ko': '목재를 직선으로 절단하는 기계',
        'en': 'A machine that cuts wood in straight lines',
        'vi': 'Máy dùng để cắt gỗ theo đường thẳng',
      },
      'hazards': {
        'ko': ['회전하는 날에 손이 베이거나 절단될 수 있어요', '나무 파편이 튀어 눈을 다칠 수 있어요'],
        'en': [
          'The spinning blade can cut or sever your hand',
          'Flying wood chips can injure your eyes',
        ],
        'vi': [
          'Lưỡi cưa quay có thể cắt đứt tay',
          'Mảnh gỗ văng ra có thể làm tổn thương mắt',
        ],
      },
      'required_ppe': {
        'ko': ['보안경', '방진 마스크', '귀 보호구'],
        'en': ['Safety glasses', 'Dust mask', 'Ear protection'],
        'vi': ['Kính bảo hộ', 'Khẩu trang chống bụi', 'Bịt tai chống ồn'],
      },
      'prohibited': {
        'ko': ['장갑을 낀 채로 작업하지 마세요', '방호덮개를 제거하지 마세요'],
        'en': [
          "Don't work while wearing gloves",
          "Don't remove the blade guard",
        ],
        'vi': ['Không đeo găng tay khi làm việc', 'Không tháo nắp bảo vệ'],
      },
    }),
    entry('hydraulic-press', now.subtract(const Duration(hours: 2)), {
      'name': {
        'ko': '유압 프레스',
        'en': 'Hydraulic Press',
        'vi': 'Máy ép thủy lực',
      },
      'category': {
        'ko': '금속 성형 기계',
        'en': 'Metal forming machine',
        'vi': 'Máy tạo hình kim loại',
      },
      'usage': {
        'ko': '강한 압력으로 금속판을 누르거나 구부리는 기계',
        'en': 'A machine that presses or bends metal sheets with strong force',
        'vi': 'Máy dùng lực mạnh để ép hoặc uốn tấm kim loại',
      },
      'hazards': {
        'ko': [
          '금형 사이에 손이 끼어 크게 다칠 수 있어요',
          '유압 호스가 터지면 기름이 뿜어져 나올 수 있어요',
          '가공물이 튀어 나올 수 있어요',
        ],
        'en': [
          'Your hand can be crushed between the dies',
          'A burst hydraulic hose can spray hot oil',
          'Workpieces can fly out',
        ],
        'vi': [
          'Tay có thể bị kẹp giữa các khuôn và bị thương nặng',
          'Ống thủy lực bị vỡ có thể phun dầu ra ngoài',
          'Phôi có thể văng ra',
        ],
      },
      'required_ppe': {
        'ko': ['안전장갑', '보안경', '안전화'],
        'en': ['Safety gloves', 'Safety glasses', 'Safety shoes'],
        'vi': ['Găng tay bảo hộ', 'Kính bảo hộ', 'Giày bảo hộ'],
      },
      'prohibited': {
        'ko': ['광전자식 방호장치를 끄지 마세요', '금형 안에 손을 넣지 마세요'],
        'en': [
          "Don't turn off the light-curtain safety device",
          "Don't put your hands inside the die",
        ],
        'vi': [
          'Không tắt thiết bị bảo vệ quang điện',
          'Không đưa tay vào trong khuôn',
        ],
      },
    }),
    entry(
      'switchboard',
      yesterday.add(const Duration(hours: 16, minutes: 48)),
      {
        'name': {'ko': '배전반', 'en': 'Switchboard', 'vi': 'Tủ điện'},
        'category': {
          'ko': '전기 설비',
          'en': 'Electrical equipment',
          'vi': 'Thiết bị điện',
        },
        'usage': {
          'ko': '건물이나 설비에 전기를 나눠 보내는 장치',
          'en':
              'A panel that distributes electricity to a building or equipment',
          'vi': 'Thiết bị phân phối điện cho tòa nhà hoặc máy móc',
        },
        'hazards': {'ko': <String>[], 'en': <String>[], 'vi': <String>[]},
        'required_ppe': {
          'ko': ['절연장갑'],
          'en': ['Insulated gloves'],
          'vi': ['Găng tay cách điện'],
        },
        'prohibited': {
          'ko': ['허가 없이 문을 열지 마세요'],
          'en': ["Don't open the door without permission"],
          'vi': ['Không mở cửa tủ khi chưa được phép'],
        },
      },
    ),
    entry('forklift', yesterday.add(const Duration(hours: 9, minutes: 12)), {
      'name': {'ko': '지게차', 'en': 'Forklift', 'vi': 'Xe nâng'},
      'category': {
        'ko': '운반 장비',
        'en': 'Material handling equipment',
        'vi': 'Thiết bị vận chuyển',
      },
      'usage': {
        'ko': '무거운 짐을 들어 올려 옮기는 차량',
        'en': 'A vehicle that lifts and moves heavy loads',
        'vi': 'Xe dùng để nâng và di chuyển hàng nặng',
      },
      'hazards': {
        'ko': ['지게차에 부딪히거나 깔릴 수 있어요'],
        'en': ['You can be hit or run over by the forklift'],
        'vi': ['Có thể bị xe nâng va phải hoặc cán qua'],
      },
      'required_ppe': {
        'ko': ['안전화', '안전모'],
        'en': ['Safety shoes', 'Hard hat'],
        'vi': ['Giày bảo hộ', 'Mũ bảo hộ'],
      },
      'prohibited': {
        'ko': ['포크 위에 사람을 태우지 마세요', '자격 없이 운전하지 마세요'],
        'en': [
          "Don't let people ride on the forks",
          "Don't drive without a license",
        ],
        'vi': [
          'Không cho người đứng trên càng nâng',
          'Không lái khi chưa có chứng chỉ',
        ],
      },
    }),
    entry(
      'arc-welder',
      threeDaysAgo.add(const Duration(hours: 15, minutes: 30)),
      {
        'name': {'ko': '아크 용접기', 'en': 'Arc Welder', 'vi': 'Máy hàn hồ quang'},
        'category': {
          'ko': '금속 접합 장비',
          'en': 'Metal joining equipment',
          'vi': 'Thiết bị hàn kim loại',
        },
        'usage': {
          'ko': '전기 불꽃으로 금속을 녹여 붙이는 장비',
          'en': 'Equipment that melts and joins metal with an electric arc',
          'vi': 'Thiết bị dùng hồ quang điện để làm nóng chảy và nối kim loại',
        },
        'hazards': {
          'ko': ['강한 빛에 눈을 다칠 수 있어요', '용접 불티로 화상이나 화재가 날 수 있어요'],
          'en': [
            'The bright arc can damage your eyes',
            'Welding sparks can cause burns or fires',
          ],
          'vi': [
            'Ánh sáng mạnh có thể làm hỏng mắt',
            'Tia lửa hàn có thể gây bỏng hoặc cháy',
          ],
        },
        'required_ppe': {
          'ko': ['용접면', '용접 장갑', '방염복'],
          'en': [
            'Welding helmet',
            'Welding gloves',
            'Flame-resistant clothing',
          ],
          'vi': ['Mặt nạ hàn', 'Găng tay hàn', 'Quần áo chống cháy'],
        },
        'prohibited': {
          'ko': ['젖은 손으로 만지지 마세요', '주변에 인화물질을 두지 마세요'],
          'en': [
            "Don't touch it with wet hands",
            "Don't keep flammables nearby",
          ],
          'vi': ['Không chạm vào khi tay ướt', 'Không để vật dễ cháy ở gần'],
        },
      },
    ),
    entry('hard-hat', threeDaysAgo.add(const Duration(hours: 10, minutes: 5)), {
      'name': {'ko': '안전모', 'en': 'Hard Hat', 'vi': 'Mũ bảo hộ'},
      'category': {
        'ko': '개인 보호구',
        'en': 'Personal protective equipment',
        'vi': 'Đồ bảo hộ cá nhân',
      },
      'usage': {
        'ko': '떨어지는 물건으로부터 머리를 보호하는 장비',
        'en': 'Protects your head from falling objects',
        'vi': 'Bảo vệ đầu khỏi vật rơi',
      },
      'hazards': {'ko': <String>[], 'en': <String>[], 'vi': <String>[]},
      'required_ppe': {
        'ko': ['안전모 (턱끈 체결)'],
        'en': ['Hard hat (chin strap fastened)'],
        'vi': ['Mũ bảo hộ (cài quai)'],
      },
      'prohibited': {'ko': <String>[], 'en': <String>[], 'vi': <String>[]},
    }),
  ];
}
