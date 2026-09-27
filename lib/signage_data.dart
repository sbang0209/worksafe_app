import 'package:flutter/material.dart';

import 'language_service.dart';

/// 표지판 화면 상단 카테고리 5개.
enum SignageCategory { logistics, electrical, woodworking, welding, press }

/// 표지판 종류.
enum SignType { warning, mandatory, prohibition }

String signTypeName(SignType type, AppLanguage language) {
  switch (type) {
    case SignType.warning:
      return language.signTypeWarning;
    case SignType.mandatory:
      return language.signTypeMandatory;
    case SignType.prohibition:
      return language.signTypeProhibition;
  }
}

IconData categoryIcon(SignageCategory category) {
  switch (category) {
    case SignageCategory.logistics:
      return Icons.local_shipping;
    case SignageCategory.electrical:
      return Icons.bolt;
    case SignageCategory.woodworking:
      return Icons.carpenter;
    case SignageCategory.welding:
      return Icons.local_fire_department;
    case SignageCategory.press:
      return Icons.precision_manufacturing;
  }
}

String categoryName(SignageCategory category, AppLanguage language) {
  switch (category) {
    case SignageCategory.logistics:
      return language.categoryLogistics;
    case SignageCategory.electrical:
      return language.categoryElectrical;
    case SignageCategory.woodworking:
      return language.categoryWoodworking;
    case SignageCategory.welding:
      return language.categoryWelding;
    case SignageCategory.press:
      return language.categoryPress;
  }
}

/// 위험 표지판 하나. 이름/설명은 3개 언어를 모두 들고 있다가
/// 현재 [AppLanguage] 에 맞는 값을 돌려준다.
class Signage {
  const Signage({
    required this.category,
    required this.type,
    required this.place,
    required this.hazard,
    required this.assetName,
    required this.icon,
    required this.color,
    required this.nameKo,
    required this.nameEn,
    required this.nameVi,
    required this.descriptionKo,
    required this.descriptionEn,
    required this.descriptionVi,
  });

  final SignageCategory category;

  /// 경고 / 지시 / 금지. 표지판 상세의 태그와 그림 배경색을 정한다.
  final SignType type;

  /// 이 표지판이 붙는 곳과 관련 위험. 언어별 맵이라 [resolveLocalizedText] 로 꺼낸다.
  /// (ko/en/vi 만 있고, 다른 언어는 영어로 대체된다.)
  final Map<String, String> place;
  final Map<String, String> hazard;

  /// assets/signs/ 아래 표지판 그림의 파일명(확장자 제외).
  /// 여러 표지판이 같은 그림을 공유할 수 있다(예: 고전압/감전 → high_voltage).
  final String assetName;

  /// 그림을 불러오지 못했을 때 자리 표시로 쓰는 아이콘/색.
  final IconData icon;
  final Color color;

  /// 실제로 화면에 넘길 애셋 경로.
  String get imageAsset => 'assets/signs/$assetName.png';

  final String nameKo;
  final String nameEn;
  final String nameVi;
  final String descriptionKo;
  final String descriptionEn;
  final String descriptionVi;

  String name(AppLanguage language) {
    switch (language.code) {
      case 'ko':
        return nameKo;
      case 'vi':
        return nameVi;
      // 번역이 없는 언어(캄보디아어·네팔어·태국어)는 영어로 보여준다.
      default:
        return nameEn;
    }
  }

  String description(AppLanguage language) {
    switch (language.code) {
      case 'ko':
        return descriptionKo;
      case 'vi':
        return descriptionVi;
      default:
        return descriptionEn;
    }
  }
}

/// 카테고리별 위험 표지판 목록 (5개 카테고리 x 4개).
const List<Signage> signageCatalog = [
  // 물류
  Signage(
    category: SignageCategory.logistics,
    type: SignType.warning,
    place: {
      'ko': '창고·하역장 출입구',
      'en': 'Warehouse and loading dock entrances',
      'vi': 'Lối vào kho và bến bốc dỡ',
    },
    hazard: {
      'ko': '충돌·끼임 사고 다발',
      'en': 'Frequent collisions and caught-in accidents',
      'vi': 'Thường xảy ra va chạm và kẹp',
    },
    assetName: 'forklift',
    icon: Icons.forklift,
    color: Colors.orange,
    nameKo: '지게차 주의',
    nameEn: 'Forklift Warning',
    nameVi: 'Cảnh báo xe nâng',
    descriptionKo: '지게차 통행 구역이니 접근에 주의하세요',
    descriptionEn: 'This is a forklift route — approach with caution.',
    descriptionVi:
        'Đây là khu vực xe nâng di chuyển, hãy cẩn thận khi đến gần.',
  ),
  Signage(
    category: SignageCategory.logistics,
    type: SignType.warning,
    place: {
      'ko': '적재 선반·크레인 작업 구역',
      'en': 'Storage racks and crane work areas',
      'vi': 'Kệ chứa hàng và khu vực cần cẩu',
    },
    hazard: {
      'ko': '머리 부상·타박상',
      'en': 'Head injuries and bruises',
      'vi': 'Chấn thương đầu, bầm dập',
    },
    assetName: 'falling_object',
    icon: Icons.warning_amber,
    color: Colors.orange,
    nameKo: '낙하물 주의',
    nameEn: 'Falling Objects',
    nameVi: 'Cảnh báo vật rơi',
    descriptionKo: '위에서 물건이 떨어질 수 있으니 조심하세요',
    descriptionEn: 'Objects may fall from above — stay alert.',
    descriptionVi: 'Vật có thể rơi từ trên cao, hãy cẩn thận.',
  ),
  Signage(
    category: SignageCategory.logistics,
    type: SignType.mandatory,
    place: {
      'ko': '물류 창고 전 구역',
      'en': 'All areas of the warehouse',
      'vi': 'Toàn bộ khu vực kho',
    },
    hazard: {
      'ko': '발 끼임·찔림',
      'en': 'Crushed or punctured feet',
      'vi': 'Kẹp hoặc đâm vào chân',
    },
    assetName: 'safety_shoes',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '안전화 착용',
    nameEn: 'Wear Safety Shoes',
    nameVi: 'Phải mang giày bảo hộ',
    descriptionKo: '이 구역에서는 안전화를 반드시 착용하세요',
    descriptionEn: 'Safety shoes are required in this area.',
    descriptionVi: 'Bắt buộc phải mang giày bảo hộ trong khu vực này.',
  ),
  Signage(
    category: SignageCategory.logistics,
    type: SignType.warning,
    place: {
      'ko': '중량물 인양·적재 구역',
      'en': 'Heavy lifting and loading areas',
      'vi': 'Khu vực nâng và xếp hàng nặng',
    },
    hazard: {
      'ko': '허리 부상·깔림',
      'en': 'Back injuries, being crushed',
      'vi': 'Chấn thương lưng, bị đè',
    },
    assetName: 'hanging_load',
    icon: Icons.scale,
    color: Colors.orange,
    nameKo: '중량물 주의',
    nameEn: 'Heavy Load',
    nameVi: 'Cảnh báo vật nặng',
    descriptionKo: '무거운 물건이 있으니 취급에 주의하세요',
    descriptionEn: 'Heavy items are present — handle with care.',
    descriptionVi: 'Có vật nặng, hãy cẩn thận khi xử lý.',
  ),
  // 전기
  Signage(
    category: SignageCategory.electrical,
    type: SignType.warning,
    place: {
      'ko': '변전실·고압 설비',
      'en': 'Substations and high-voltage equipment',
      'vi': 'Trạm biến áp và thiết bị cao áp',
    },
    hazard: {
      'ko': '감전·화상',
      'en': 'Electric shock and burns',
      'vi': 'Điện giật và bỏng',
    },
    assetName: 'high_voltage',
    icon: Icons.bolt,
    color: Colors.red,
    nameKo: '고전압 주의',
    nameEn: 'High Voltage',
    nameVi: 'Cảnh báo điện áp cao',
    descriptionKo: '감전 위험이 있으니 접근하지 마세요',
    descriptionEn: 'Risk of electric shock — do not approach.',
    descriptionVi: 'Có nguy cơ điện giật, không được đến gần.',
  ),
  Signage(
    category: SignageCategory.electrical,
    type: SignType.warning,
    place: {
      'ko': '배전반·분전함',
      'en': 'Switchboards and distribution panels',
      'vi': 'Tủ điện và bảng phân phối',
    },
    hazard: {
      'ko': '감전 사망 사고',
      'en': 'Fatal electric shock',
      'vi': 'Tai nạn điện giật tử vong',
    },
    assetName: 'high_voltage',
    icon: Icons.flash_on,
    color: Colors.red,
    nameKo: '감전 주의',
    nameEn: 'Electric Shock',
    nameVi: 'Cảnh báo điện giật',
    descriptionKo: '전기 위험 구역입니다. 주의하세요',
    descriptionEn: 'This is an electrical hazard area. Use caution.',
    descriptionVi: 'Đây là khu vực nguy hiểm về điện, hãy cẩn thận.',
  ),
  Signage(
    category: SignageCategory.electrical,
    type: SignType.mandatory,
    place: {
      'ko': '전기 작업 구역',
      'en': 'Electrical work areas',
      'vi': 'Khu vực làm việc về điện',
    },
    hazard: {'ko': '감전', 'en': 'Electric shock', 'vi': 'Điện giật'},
    assetName: 'safety_gloves',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '절연장갑 착용',
    nameEn: 'Wear Insulating Gloves',
    nameVi: 'Phải mang găng tay cách điện',
    descriptionKo: '전기 작업 시 절연장갑을 착용하세요',
    descriptionEn: 'Wear insulating gloves when working with electricity.',
    descriptionVi: 'Hãy mang găng tay cách điện khi làm việc với điện.',
  ),
  Signage(
    category: SignageCategory.electrical,
    type: SignType.mandatory,
    place: {
      'ko': '설비 점검·수리 구역',
      'en': 'Equipment inspection and repair areas',
      'vi': 'Khu vực kiểm tra, sửa chữa thiết bị',
    },
    hazard: {
      'ko': '갑작스런 기계 작동',
      'en': 'Machines starting unexpectedly',
      'vi': 'Máy khởi động bất ngờ',
    },
    assetName: 'danger_zone',
    icon: Icons.power_off,
    color: Colors.blue,
    nameKo: '전원 차단 확인',
    nameEn: 'Power Off Required',
    nameVi: 'Phải ngắt nguồn điện',
    descriptionKo: '작업 전 반드시 전원을 차단하세요',
    descriptionEn: 'Always turn off the power before starting work.',
    descriptionVi: 'Bắt buộc phải ngắt nguồn điện trước khi làm việc.',
  ),
  // 목공
  Signage(
    category: SignageCategory.woodworking,
    type: SignType.warning,
    place: {
      'ko': '목공 기계 투입부',
      'en': 'Woodworking machine feed points',
      'vi': 'Cửa nạp của máy chế biến gỗ',
    },
    hazard: {
      'ko': '손가락 절단·끼임',
      'en': 'Finger amputation and pinching',
      'vi': 'Đứt, kẹp ngón tay',
    },
    assetName: 'danger_zone',
    icon: Icons.pan_tool,
    color: Colors.orange,
    nameKo: '손 끼임 주의',
    nameEn: 'Hand Entanglement',
    nameVi: 'Cảnh báo kẹt tay',
    descriptionKo: '회전하는 부분에 손이 말려들 수 있으니 조심하세요',
    descriptionEn: 'Your hand may get caught in rotating parts — be careful.',
    descriptionVi: 'Tay có thể bị cuốn vào bộ phận quay, hãy cẩn thận.',
  ),
  Signage(
    category: SignageCategory.woodworking,
    type: SignType.mandatory,
    place: {
      'ko': '절단·연마 작업장',
      'en': 'Cutting and grinding areas',
      'vi': 'Khu vực cắt và mài',
    },
    hazard: {
      'ko': '파편에 의한 눈 부상',
      'en': 'Eye injuries from flying chips',
      'vi': 'Chấn thương mắt do mảnh vụn',
    },
    assetName: 'eye_protection',
    icon: Icons.visibility,
    color: Colors.blue,
    nameKo: '보안경 착용',
    nameEn: 'Wear Eye Protection',
    nameVi: 'Phải mang kính bảo hộ',
    descriptionKo: '파편이 튈 수 있으니 보안경을 착용하세요',
    descriptionEn: 'Debris may fly — wear eye protection.',
    descriptionVi: 'Mảnh vụn có thể bắn ra, hãy mang kính bảo hộ.',
  ),
  Signage(
    category: SignageCategory.woodworking,
    type: SignType.warning,
    place: {
      'ko': '목공 기계실',
      'en': 'Woodworking machine rooms',
      'vi': 'Phòng máy chế biến gỗ',
    },
    hazard: {
      'ko': '청력 손상',
      'en': 'Hearing damage',
      'vi': 'Tổn thương thính giác',
    },
    assetName: 'ear_protection',
    icon: Icons.hearing,
    color: Colors.orange,
    nameKo: '소음 주의',
    nameEn: 'Noise Hazard',
    nameVi: 'Cảnh báo tiếng ồn',
    descriptionKo: '소음이 심하니 귀 보호구를 착용하세요',
    descriptionEn: 'Noise levels are high — wear ear protection.',
    descriptionVi: 'Tiếng ồn lớn, hãy mang thiết bị bảo vệ tai.',
  ),
  Signage(
    category: SignageCategory.woodworking,
    type: SignType.warning,
    place: {
      'ko': '톱·절단기 주변',
      'en': 'Around saws and cutters',
      'vi': 'Xung quanh máy cưa, máy cắt',
    },
    hazard: {
      'ko': '베임·절단',
      'en': 'Cuts and amputation',
      'vi': 'Đứt tay, cắt cụt',
    },
    assetName: 'slip',
    icon: Icons.content_cut,
    color: Colors.orange,
    nameKo: '절단 주의',
    nameEn: 'Cutting Hazard',
    nameVi: 'Cảnh báo vật sắc',
    descriptionKo: '날카로운 날에 베일 수 있으니 조심하세요',
    descriptionEn: 'Sharp blades may cut you — be careful.',
    descriptionVi: 'Có thể bị đứt tay bởi lưỡi dao sắc, hãy cẩn thận.',
  ),
  // 용접
  Signage(
    category: SignageCategory.welding,
    type: SignType.prohibition,
    place: {
      'ko': '인화물질 보관소',
      'en': 'Flammable storage areas',
      'vi': 'Kho chứa chất dễ cháy',
    },
    hazard: {'ko': '화재·폭발', 'en': 'Fire and explosion', 'vi': 'Cháy nổ'},
    assetName: 'no_fire',
    icon: Icons.local_fire_department,
    color: Colors.red,
    nameKo: '화기 주의',
    nameEn: 'Fire Hazard',
    nameVi: 'Cảnh báo lửa',
    descriptionKo: '불이 붙기 쉬운 물질을 가까이 두지 마세요',
    descriptionEn: 'Keep flammable materials away from this area.',
    descriptionVi: 'Không để vật dễ cháy gần khu vực này.',
  ),
  Signage(
    category: SignageCategory.welding,
    type: SignType.mandatory,
    place: {'ko': '용접 작업장', 'en': 'Welding areas', 'vi': 'Khu vực hàn'},
    hazard: {
      'ko': '눈·얼굴 화상',
      'en': 'Eye and face burns',
      'vi': 'Bỏng mắt và mặt',
    },
    assetName: 'face_shield',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '용접면 착용',
    nameEn: 'Wear Welding Mask',
    nameVi: 'Phải mang mặt nạ hàn',
    descriptionKo: '강한 빛으로부터 눈을 보호하세요',
    descriptionEn: 'Protect your eyes from intense light.',
    descriptionVi: 'Hãy bảo vệ mắt khỏi ánh sáng mạnh.',
  ),
  Signage(
    category: SignageCategory.welding,
    type: SignType.warning,
    place: {
      'ko': '용접·도장 작업장',
      'en': 'Welding and painting areas',
      'vi': 'Khu vực hàn và sơn',
    },
    hazard: {
      'ko': '중독·질식',
      'en': 'Poisoning and suffocation',
      'vi': 'Ngộ độc, ngạt thở',
    },
    assetName: 'gas_mask',
    icon: Icons.air,
    color: Colors.orange,
    nameKo: '유독가스 주의',
    nameEn: 'Toxic Fumes',
    nameVi: 'Cảnh báo khí độc',
    descriptionKo: '유독가스가 발생하니 환기가 필요합니다',
    descriptionEn: 'Toxic fumes are produced — ventilation is required.',
    descriptionVi: 'Khí độc phát sinh, cần thông gió.',
  ),
  Signage(
    category: SignageCategory.welding,
    type: SignType.warning,
    place: {
      'ko': '고온 설비 주변',
      'en': 'Around hot equipment',
      'vi': 'Xung quanh thiết bị nhiệt độ cao',
    },
    hazard: {'ko': '피부 화상', 'en': 'Skin burns', 'vi': 'Bỏng da'},
    assetName: 'high_temp',
    icon: Icons.whatshot,
    color: Colors.orange,
    nameKo: '화상 주의',
    nameEn: 'Burn Hazard',
    nameVi: 'Cảnh báo bỏng',
    descriptionKo: '뜨거운 표면에 화상을 입을 수 있으니 주의하세요',
    descriptionEn: 'Hot surfaces may cause burns — use caution.',
    descriptionVi: 'Có thể bị bỏng do bề mặt nóng, hãy cẩn thận.',
  ),
  // 프레스
  Signage(
    category: SignageCategory.press,
    type: SignType.warning,
    place: {
      'ko': '프레스 금형 주변',
      'en': 'Around press dies',
      'vi': 'Xung quanh khuôn máy ép',
    },
    hazard: {
      'ko': '손 압착·절단',
      'en': 'Crushed or amputated hands',
      'vi': 'Dập, đứt tay',
    },
    assetName: 'danger_zone',
    icon: Icons.back_hand,
    color: Colors.orange,
    nameKo: '손 끼임 주의',
    nameEn: 'Hand Crush',
    nameVi: 'Cảnh báo kẹp tay',
    descriptionKo: '금형 사이에 손을 넣지 마세요',
    descriptionEn: 'Do not put your hands between the dies.',
    descriptionVi: 'Không đưa tay vào giữa khuôn ép.',
  ),
  Signage(
    category: SignageCategory.press,
    type: SignType.mandatory,
    place: {
      'ko': '프레스 작업대',
      'en': 'Press workstations',
      'vi': 'Bàn làm việc máy ép',
    },
    hazard: {
      'ko': '방호장치 해제 시 끼임',
      'en': 'Caught-in when guards are removed',
      'vi': 'Bị kẹp khi tháo thiết bị bảo vệ',
    },
    assetName: 'helmet',
    icon: Icons.shield,
    color: Colors.blue,
    nameKo: '방호장치 확인',
    nameEn: 'Check Safety Guard',
    nameVi: 'Kiểm tra thiết bị bảo vệ',
    descriptionKo: '방호장치를 해제하지 마세요',
    descriptionEn: 'Do not remove the safety guard.',
    descriptionVi: 'Không được tháo bỏ thiết bị bảo vệ.',
  ),
  Signage(
    category: SignageCategory.press,
    type: SignType.warning,
    place: {
      'ko': '기계 조작반',
      'en': 'Machine control panels',
      'vi': 'Bảng điều khiển máy',
    },
    hazard: {
      'ko': '비상시 대응 지연',
      'en': 'Delayed response in emergencies',
      'vi': 'Chậm phản ứng khi khẩn cấp',
    },
    assetName: 'slip',
    icon: Icons.emergency,
    color: Colors.red,
    nameKo: '비상정지',
    nameEn: 'Emergency Stop',
    nameVi: 'Dừng khẩn cấp',
    descriptionKo: '비상정지 버튼 위치를 확인해 두세요',
    descriptionEn: 'Know the location of the emergency stop button.',
    descriptionVi: 'Hãy xác định trước vị trí nút dừng khẩn cấp.',
  ),
  Signage(
    category: SignageCategory.press,
    type: SignType.mandatory,
    place: {
      'ko': '프레스 조작부',
      'en': 'Press operating controls',
      'vi': 'Bộ điều khiển máy ép',
    },
    hazard: {
      'ko': '한 손 조작 시 끼임',
      'en': 'Caught-in when using one hand',
      'vi': 'Bị kẹp khi thao tác một tay',
    },
    assetName: 'hanging_load',
    icon: Icons.front_hand,
    color: Colors.blue,
    nameKo: '양수조작 확인',
    nameEn: 'Two-Hand Control',
    nameVi: 'Kiểm tra điều khiển hai tay',
    descriptionKo: '양손 조작 버튼을 정상적으로 사용하세요',
    descriptionEn: 'Use the two-hand control buttons properly.',
    descriptionVi: 'Hãy sử dụng đúng cách nút điều khiển hai tay.',
  ),
];

List<Signage> signageForCategory(SignageCategory category) =>
    signageCatalog.where((s) => s.category == category).toList();
