import 'package:flutter/material.dart';

import 'language_service.dart';

/// 홈 화면 상단 카테고리 5개.
enum SignageCategory { logistics, electrical, woodworking, welding, press }

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
      case 'en':
        return nameEn;
      case 'vi':
        return nameVi;
      default:
        return nameKo;
    }
  }

  String description(AppLanguage language) {
    switch (language.code) {
      case 'en':
        return descriptionEn;
      case 'vi':
        return descriptionVi;
      default:
        return descriptionKo;
    }
  }
}

/// 카테고리별 위험 표지판 목록 (5개 카테고리 x 4개).
const List<Signage> signageCatalog = [
  // 물류
  Signage(
    category: SignageCategory.logistics,
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
