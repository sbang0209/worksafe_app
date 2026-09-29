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

/// 위험 표지판 하나. 이름/설명은 6개 언어(ko/en/vi/km/ne/th)를 모두 들고
/// 있다가 현재 [AppLanguage] 에 맞는 값을 돌려준다.
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
    required this.nameKm,
    required this.nameNe,
    required this.nameTh,
    required this.descriptionKo,
    required this.descriptionEn,
    required this.descriptionVi,
    required this.descriptionKm,
    required this.descriptionNe,
    required this.descriptionTh,
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
  final String nameKm;
  final String nameNe;
  final String nameTh;
  final String descriptionKo;
  final String descriptionEn;
  final String descriptionVi;
  final String descriptionKm;
  final String descriptionNe;
  final String descriptionTh;

  String name(AppLanguage language) {
    switch (language.code) {
      case 'ko':
        return nameKo;
      case 'vi':
        return nameVi;
      case 'km':
        return nameKm;
      case 'ne':
        return nameNe;
      case 'th':
        return nameTh;
      // 언어가 더 늘어날 때를 위한 안전망. 지금은 여기로 빠질 코드가 없다.
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
      case 'km':
        return descriptionKm;
      case 'ne':
        return descriptionNe;
      case 'th':
        return descriptionTh;
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
      'km': 'ច្រកចូលឃ្លាំង និងកន្លែងផ្ទុកទំនិញ',
      'ne': 'गोदाम र लोडिङ डकको प्रवेशद्वार',
      'th': 'ทางเข้าคลังสินค้าและท่าขนถ่ายสินค้า',
    },
    hazard: {
      'ko': '충돌·끼임 사고 다발',
      'en': 'Frequent collisions and caught-in accidents',
      'vi': 'Thường xảy ra va chạm và kẹp',
      'km': 'គ្រោះថ្នាក់ប៉ះទង្គិច និងសង្កត់ញឹកញាប់',
      'ne': 'ठक्कर र च्यापिने दुर्घटना धेरै हुने',
      'th': 'เกิดอุบัติเหตุชนและติดหนีบบ่อยครั้ง',
    },
    assetName: 'forklift',
    icon: Icons.forklift,
    color: Colors.orange,
    nameKo: '지게차 주의',
    nameEn: 'Forklift Warning',
    nameVi: 'Cảnh báo xe nâng',
    nameKm: 'ប្រយ័ត្នរថយន្តលើក',
    nameNe: 'फोर्कलिफ्ट सावधानी',
    nameTh: 'ระวังรถยก',
    descriptionKo: '지게차 통행 구역이니 접근에 주의하세요',
    descriptionEn: 'This is a forklift route — approach with caution.',
    descriptionVi:
        'Đây là khu vực xe nâng di chuyển, hãy cẩn thận khi đến gần.',
    descriptionKm: 'តំបន់នេះជាផ្លូវរថយន្តលើក សូមប្រុងប្រយ័ត្នពេលចូលមកជិត។',
    descriptionNe:
        'यो फोर्कलिफ्ट ओहोरदोहोर हुने क्षेत्र हो, नजिक जाँदा सावधान रहनुहोस्।',
    descriptionTh: 'บริเวณนี้เป็นเส้นทางรถยก โปรดระมัดระวังเมื่อเข้าใกล้',
  ),
  Signage(
    category: SignageCategory.logistics,
    type: SignType.warning,
    place: {
      'ko': '적재 선반·크레인 작업 구역',
      'en': 'Storage racks and crane work areas',
      'vi': 'Kệ chứa hàng và khu vực cần cẩu',
      'km': 'ធ្នើផ្ទុកទំនិញ និងតំបន់ការងារក្រែន',
      'ne': 'भण्डारण र्याक र क्रेन कार्य क्षेत्र',
      'th': 'พื้นที่ชั้นวางสินค้าและงานเครน',
    },
    hazard: {
      'ko': '머리 부상·타박상',
      'en': 'Head injuries and bruises',
      'vi': 'Chấn thương đầu, bầm dập',
      'km': 'របួសក្បាល និងជាំ',
      'ne': 'टाउकोमा चोट र नीलडाम',
      'th': 'บาดเจ็บที่ศีรษะและฟกช้ำ',
    },
    assetName: 'falling_object',
    icon: Icons.warning_amber,
    color: Colors.orange,
    nameKo: '낙하물 주의',
    nameEn: 'Falling Objects',
    nameVi: 'Cảnh báo vật rơi',
    nameKm: 'ប្រយ័ត្នវត្ថុធ្លាក់',
    nameNe: 'वस्तु खस्ने चेतावनी',
    nameTh: 'ระวังวัตถุตกหล่น',
    descriptionKo: '위에서 물건이 떨어질 수 있으니 조심하세요',
    descriptionEn: 'Objects may fall from above — stay alert.',
    descriptionVi: 'Vật có thể rơi từ trên cao, hãy cẩn thận.',
    descriptionKm: 'វត្ថុអាចធ្លាក់ពីលើ សូមប្រុងប្រយ័ត្ន។',
    descriptionNe: 'माथिबाट सामान खस्न सक्छ, सावधान रहनुहोस्।',
    descriptionTh: 'สิ่งของอาจตกลงมาจากด้านบน โปรดระมัดระวัง',
  ),
  Signage(
    category: SignageCategory.logistics,
    type: SignType.mandatory,
    place: {
      'ko': '물류 창고 전 구역',
      'en': 'All areas of the warehouse',
      'vi': 'Toàn bộ khu vực kho',
      'km': 'គ្រប់តំបន់ឃ្លាំងទំនិញ',
      'ne': 'सम्पूर्ण गोदाम क्षेत्र',
      'th': 'พื้นที่คลังสินค้าทั้งหมด',
    },
    hazard: {
      'ko': '발 끼임·찔림',
      'en': 'Crushed or punctured feet',
      'vi': 'Kẹp hoặc đâm vào chân',
      'km': 'ជើងសង្កត់ និងចាក់',
      'ne': 'खुट्टा च्यापिने र घोच्ने',
      'th': 'เท้าติดหนีบและถูกแทง',
    },
    assetName: 'safety_shoes',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '안전화 착용',
    nameEn: 'Wear Safety Shoes',
    nameVi: 'Phải mang giày bảo hộ',
    nameKm: 'ពាក់ស្បែកជើងសុវត្ថិភាព',
    nameNe: 'सुरक्षा जुत्ता लगाउनुहोस्',
    nameTh: 'สวมรองเท้านิรภัย',
    descriptionKo: '이 구역에서는 안전화를 반드시 착용하세요',
    descriptionEn: 'Safety shoes are required in this area.',
    descriptionVi: 'Bắt buộc phải mang giày bảo hộ trong khu vực này.',
    descriptionKm: 'នៅតំបន់នេះ ត្រូវពាក់ស្បែកជើងសុវត្ថិភាពជាចាំបាច់។',
    descriptionNe: 'यस क्षेत्रमा सुरक्षा जुत्ता अनिवार्य रूपमा लगाउनुहोस्।',
    descriptionTh: 'ในพื้นที่นี้ต้องสวมรองเท้านิรภัยทุกครั้ง',
  ),
  Signage(
    category: SignageCategory.logistics,
    type: SignType.warning,
    place: {
      'ko': '중량물 인양·적재 구역',
      'en': 'Heavy lifting and loading areas',
      'vi': 'Khu vực nâng và xếp hàng nặng',
      'km': 'តំបន់លើក និងផ្ទុកវត្ថុធ្ងន់',
      'ne': 'गह्रौं सामान उठाउने र लोड गर्ने क्षेत्र',
      'th': 'พื้นที่ยกและบรรทุกของหนัก',
    },
    hazard: {
      'ko': '허리 부상·깔림',
      'en': 'Back injuries, being crushed',
      'vi': 'Chấn thương lưng, bị đè',
      'km': 'របួសខ្នង និងសង្កត់',
      'ne': 'ढाड चोट र थिचिने',
      'th': 'บาดเจ็บที่หลังและถูกทับ',
    },
    assetName: 'hanging_load',
    icon: Icons.scale,
    color: Colors.orange,
    nameKo: '중량물 주의',
    nameEn: 'Heavy Load',
    nameVi: 'Cảnh báo vật nặng',
    nameKm: 'ប្រយ័ត្នវត្ថុធ្ងន់',
    nameNe: 'गह्रौं सामान सावधानी',
    nameTh: 'ระวังของหนัก',
    descriptionKo: '무거운 물건이 있으니 취급에 주의하세요',
    descriptionEn: 'Heavy items are present — handle with care.',
    descriptionVi: 'Có vật nặng, hãy cẩn thận khi xử lý.',
    descriptionKm: 'មានវត្ថុធ្ងន់ សូមប្រុងប្រយ័ត្នពេលដោះស្រាយ។',
    descriptionNe: 'गह्रौं सामान छ, ह्यान्डल गर्दा सावधान रहनुहोस्।',
    descriptionTh: 'มีของหนัก โปรดระมัดระวังในการเคลื่อนย้าย',
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
    nameKm: 'High Voltage',
    nameNe: 'High Voltage',
    nameTh: 'High Voltage',
    descriptionKo: '감전 위험이 있으니 접근하지 마세요',
    descriptionEn: 'Risk of electric shock — do not approach.',
    descriptionVi: 'Có nguy cơ điện giật, không được đến gần.',
    descriptionKm: 'Risk of electric shock — do not approach.',
    descriptionNe: 'Risk of electric shock — do not approach.',
    descriptionTh: 'Risk of electric shock — do not approach.',
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
    nameKm: 'Electric Shock',
    nameNe: 'Electric Shock',
    nameTh: 'Electric Shock',
    descriptionKo: '전기 위험 구역입니다. 주의하세요',
    descriptionEn: 'This is an electrical hazard area. Use caution.',
    descriptionVi: 'Đây là khu vực nguy hiểm về điện, hãy cẩn thận.',
    descriptionKm: 'This is an electrical hazard area. Use caution.',
    descriptionNe: 'This is an electrical hazard area. Use caution.',
    descriptionTh: 'This is an electrical hazard area. Use caution.',
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
    nameKm: 'Wear Insulating Gloves',
    nameNe: 'Wear Insulating Gloves',
    nameTh: 'Wear Insulating Gloves',
    descriptionKo: '전기 작업 시 절연장갑을 착용하세요',
    descriptionEn: 'Wear insulating gloves when working with electricity.',
    descriptionVi: 'Hãy mang găng tay cách điện khi làm việc với điện.',
    descriptionKm: 'Wear insulating gloves when working with electricity.',
    descriptionNe: 'Wear insulating gloves when working with electricity.',
    descriptionTh: 'Wear insulating gloves when working with electricity.',
  ),
  Signage(
    category: SignageCategory.electrical,
    type: SignType.warning,
    place: {
      'ko': '배전반·변압기 설치 구역',
      'en': 'Switchboard and transformer areas',
      'vi': 'Khu vực tủ điện và máy biến áp',
    },
    hazard: {
      'ko': '무단 접근 시 감전·아크 섬광',
      'en': 'Electric shock and arc flash on unauthorized entry',
      'vi': 'Điện giật và hồ quang khi vào trái phép',
    },
    assetName: 'danger_zone',
    icon: Icons.dangerous,
    color: Colors.orange,
    nameKo: '전기 위험장소',
    nameEn: 'Electrical Hazard Area',
    nameVi: 'Khu vực nguy hiểm điện',
    nameKm: 'Electrical Hazard Area',
    nameNe: 'Electrical Hazard Area',
    nameTh: 'Electrical Hazard Area',
    descriptionKo: '전기 위험 구역이니 허가받은 사람만 들어가세요',
    descriptionEn: 'Electrical hazard area — authorized personnel only.',
    descriptionVi: 'Khu vực nguy hiểm điện, chỉ người được phép mới vào.',
    descriptionKm: 'Electrical hazard area — authorized personnel only.',
    descriptionNe: 'Electrical hazard area — authorized personnel only.',
    descriptionTh: 'Electrical hazard area — authorized personnel only.',
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
    nameKm: 'Hand Entanglement',
    nameNe: 'Hand Entanglement',
    nameTh: 'Hand Entanglement',
    descriptionKo: '회전하는 부분에 손이 말려들 수 있으니 조심하세요',
    descriptionEn: 'Your hand may get caught in rotating parts — be careful.',
    descriptionVi: 'Tay có thể bị cuốn vào bộ phận quay, hãy cẩn thận.',
    descriptionKm: 'Your hand may get caught in rotating parts — be careful.',
    descriptionNe: 'Your hand may get caught in rotating parts — be careful.',
    descriptionTh: 'Your hand may get caught in rotating parts — be careful.',
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
    nameKm: 'Wear Eye Protection',
    nameNe: 'Wear Eye Protection',
    nameTh: 'Wear Eye Protection',
    descriptionKo: '파편이 튈 수 있으니 보안경을 착용하세요',
    descriptionEn: 'Debris may fly — wear eye protection.',
    descriptionVi: 'Mảnh vụn có thể bắn ra, hãy mang kính bảo hộ.',
    descriptionKm: 'Debris may fly — wear eye protection.',
    descriptionNe: 'Debris may fly — wear eye protection.',
    descriptionTh: 'Debris may fly — wear eye protection.',
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
    nameKm: 'Noise Hazard',
    nameNe: 'Noise Hazard',
    nameTh: 'Noise Hazard',
    descriptionKo: '소음이 심하니 귀 보호구를 착용하세요',
    descriptionEn: 'Noise levels are high — wear ear protection.',
    descriptionVi: 'Tiếng ồn lớn, hãy mang thiết bị bảo vệ tai.',
    descriptionKm: 'Noise levels are high — wear ear protection.',
    descriptionNe: 'Noise levels are high — wear ear protection.',
    descriptionTh: 'Noise levels are high — wear ear protection.',
  ),
  Signage(
    category: SignageCategory.woodworking,
    type: SignType.warning,
    place: {
      'ko': '목공 기계 주변 바닥·작업 통로',
      'en': 'Floors and walkways around woodworking machines',
      'vi': 'Sàn và lối đi quanh máy mộc',
    },
    hazard: {
      'ko': '톱밥·대팻밥에 미끄러져 회전 날 쪽으로 넘어짐',
      'en': 'Slipping on sawdust and falling toward rotating blades',
      'vi': 'Trượt trên mùn cưa và ngã về phía lưỡi dao quay',
    },
    assetName: 'slip',
    icon: Icons.water_drop,
    color: Colors.orange,
    nameKo: '몸균형 상실 주의',
    nameEn: 'Loss of Balance Hazard',
    nameVi: 'Nguy cơ mất thăng bằng',
    nameKm: 'Loss of Balance Hazard',
    nameNe: 'Loss of Balance Hazard',
    nameTh: 'Loss of Balance Hazard',
    descriptionKo: '톱밥이 쌓여 미끄러우니 기계 주변에서는 천천히 이동하세요',
    descriptionEn:
        'Sawdust makes the floor slippery — move slowly near machines.',
    descriptionVi: 'Mùn cưa làm sàn trơn, hãy đi chậm gần máy.',
    descriptionKm:
        'Sawdust makes the floor slippery — move slowly near machines.',
    descriptionNe:
        'Sawdust makes the floor slippery — move slowly near machines.',
    descriptionTh:
        'Sawdust makes the floor slippery — move slowly near machines.',
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
    nameKm: 'Fire Hazard',
    nameNe: 'Fire Hazard',
    nameTh: 'Fire Hazard',
    descriptionKo: '불이 붙기 쉬운 물질을 가까이 두지 마세요',
    descriptionEn: 'Keep flammable materials away from this area.',
    descriptionVi: 'Không để vật dễ cháy gần khu vực này.',
    descriptionKm: 'Keep flammable materials away from this area.',
    descriptionNe: 'Keep flammable materials away from this area.',
    descriptionTh: 'Keep flammable materials away from this area.',
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
    nameKm: 'Wear Welding Mask',
    nameNe: 'Wear Welding Mask',
    nameTh: 'Wear Welding Mask',
    descriptionKo: '강한 빛으로부터 눈을 보호하세요',
    descriptionEn: 'Protect your eyes from intense light.',
    descriptionVi: 'Hãy bảo vệ mắt khỏi ánh sáng mạnh.',
    descriptionKm: 'Protect your eyes from intense light.',
    descriptionNe: 'Protect your eyes from intense light.',
    descriptionTh: 'Protect your eyes from intense light.',
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
    nameKm: 'Toxic Fumes',
    nameNe: 'Toxic Fumes',
    nameTh: 'Toxic Fumes',
    descriptionKo: '유독가스가 발생하니 환기가 필요합니다',
    descriptionEn: 'Toxic fumes are produced — ventilation is required.',
    descriptionVi: 'Khí độc phát sinh, cần thông gió.',
    descriptionKm: 'Toxic fumes are produced — ventilation is required.',
    descriptionNe: 'Toxic fumes are produced — ventilation is required.',
    descriptionTh: 'Toxic fumes are produced — ventilation is required.',
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
    nameKm: 'Burn Hazard',
    nameNe: 'Burn Hazard',
    nameTh: 'Burn Hazard',
    descriptionKo: '뜨거운 표면에 화상을 입을 수 있으니 주의하세요',
    descriptionEn: 'Hot surfaces may cause burns — use caution.',
    descriptionVi: 'Có thể bị bỏng do bề mặt nóng, hãy cẩn thận.',
    descriptionKm: 'Hot surfaces may cause burns — use caution.',
    descriptionNe: 'Hot surfaces may cause burns — use caution.',
    descriptionTh: 'Hot surfaces may cause burns — use caution.',
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
    nameKm: 'Hand Crush',
    nameNe: 'Hand Crush',
    nameTh: 'Hand Crush',
    descriptionKo: '금형 사이에 손을 넣지 마세요',
    descriptionEn: 'Do not put your hands between the dies.',
    descriptionVi: 'Không đưa tay vào giữa khuôn ép.',
    descriptionKm: 'Do not put your hands between the dies.',
    descriptionNe: 'Do not put your hands between the dies.',
    descriptionTh: 'Do not put your hands between the dies.',
  ),
  Signage(
    category: SignageCategory.press,
    type: SignType.mandatory,
    place: {
      'ko': '프레스 작업장 전 구역',
      'en': 'All press shop areas',
      'vi': 'Toàn bộ khu vực xưởng máy ép',
    },
    hazard: {
      'ko': '금형·자재 낙하로 인한 머리 부상',
      'en': 'Head injury from falling dies or materials',
      'vi': 'Chấn thương đầu do khuôn hoặc vật liệu rơi',
    },
    assetName: 'helmet',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '프레스 안전모 착용',
    nameEn: 'Wear Hard Hat (Press)',
    nameVi: 'Đội mũ bảo hộ (máy ép)',
    nameKm: 'Wear Hard Hat (Press)',
    nameNe: 'Wear Hard Hat (Press)',
    nameTh: 'Wear Hard Hat (Press)',
    descriptionKo: '금형이 낙하할 수 있는 구역이니 안전모를 착용하세요',
    descriptionEn: 'Wear a hard hat — dies can fall in this area.',
    descriptionVi: 'Hãy đội mũ bảo hộ, khuôn có thể rơi trong khu vực này.',
    descriptionKm: 'Wear a hard hat — dies can fall in this area.',
    descriptionNe: 'Wear a hard hat — dies can fall in this area.',
    descriptionTh: 'Wear a hard hat — dies can fall in this area.',
  ),
  Signage(
    category: SignageCategory.press,
    type: SignType.warning,
    place: {
      'ko': '프레스 주변 바닥',
      'en': 'Floor around the press',
      'vi': 'Sàn quanh máy ép',
    },
    hazard: {
      'ko': '유압유 누유로 인한 미끄러짐',
      'en': 'Slipping on leaked hydraulic oil',
      'vi': 'Trượt ngã do dầu thủy lực rò rỉ',
    },
    assetName: 'slip',
    icon: Icons.water_drop,
    color: Colors.orange,
    nameKo: '유압유 미끄럼 주의',
    nameEn: 'Hydraulic Oil Slip Hazard',
    nameVi: 'Cẩn thận trơn do dầu thủy lực',
    nameKm: 'Hydraulic Oil Slip Hazard',
    nameNe: 'Hydraulic Oil Slip Hazard',
    nameTh: 'Hydraulic Oil Slip Hazard',
    descriptionKo: '유압유가 새어 바닥이 미끄러울 수 있으니 주의해서 이동하세요',
    descriptionEn:
        'Leaked hydraulic oil can make the floor slippery — move carefully.',
    descriptionVi: 'Dầu thủy lực rò rỉ làm sàn trơn, hãy di chuyển cẩn thận.',
    descriptionKm:
        'Leaked hydraulic oil can make the floor slippery — move carefully.',
    descriptionNe:
        'Leaked hydraulic oil can make the floor slippery — move carefully.',
    descriptionTh:
        'Leaked hydraulic oil can make the floor slippery — move carefully.',
  ),
  Signage(
    category: SignageCategory.press,
    type: SignType.warning,
    place: {
      'ko': '금형 운반·크레인 작업 구역',
      'en': 'Die transport and crane work areas',
      'vi': 'Khu vận chuyển khuôn và làm việc cần cẩu',
    },
    hazard: {
      'ko': '매달린 금형 낙하·흔들림에 의한 충돌',
      'en': 'Impact from swinging or dropping suspended dies',
      'vi': 'Va đập do khuôn treo lắc hoặc rơi',
    },
    assetName: 'hanging_load',
    icon: Icons.scale,
    color: Colors.orange,
    nameKo: '중량물 취급 주의',
    nameEn: 'Heavy Load Handling',
    nameVi: 'Cẩn thận khi nâng vật nặng',
    nameKm: 'Heavy Load Handling',
    nameNe: 'Heavy Load Handling',
    nameTh: 'Heavy Load Handling',
    descriptionKo: '매달린 금형 아래로는 절대 지나가지 마세요',
    descriptionEn: 'Never walk under a suspended die.',
    descriptionVi: 'Tuyệt đối không đi dưới khuôn đang treo.',
    descriptionKm: 'Never walk under a suspended die.',
    descriptionNe: 'Never walk under a suspended die.',
    descriptionTh: 'Never walk under a suspended die.',
  ),

  // ── 물류 (추가 3종) ─────────────────────────────────────────────────────────
  Signage(
    category: SignageCategory.logistics,
    type: SignType.mandatory,
    place: {
      'ko': '창고·하역장 전 구역',
      'en': 'All warehouse and loading dock areas',
      'vi': 'Toàn bộ khu vực kho và bến bốc dỡ',
      'km': 'គ្រប់តំបន់ឃ្លាំង និងកន្លែងផ្ទុកទំនិញ',
      'ne': 'सबै गोदाम र लोडिङ डक क्षेत्र',
      'th': 'พื้นที่คลังสินค้าและท่าขนถ่ายสินค้าทั้งหมด',
    },
    hazard: {
      'ko': '낙하물·충돌로 인한 머리 부상',
      'en': 'Head injury from falling objects or collisions',
      'vi': 'Chấn thương đầu do vật rơi hoặc va chạm',
      'km': 'របួសក្បាលដោយសារវត្ថុធ្លាក់ ឬប៉ះទង្គិច',
      'ne': 'खस्ने वस्तु वा ठक्करले हुने टाउको चोट',
      'th': 'บาดเจ็บที่ศีรษะจากของตกหรือการชน',
    },
    assetName: 'helmet',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '안전모 착용',
    nameEn: 'Wear Hard Hat',
    nameVi: 'Đội mũ bảo hộ',
    nameKm: 'ពាក់មួកសុវត្ថិភាព',
    nameNe: 'सुरक्षा हेलमेट लगाउनुहोस्',
    nameTh: 'สวมหมวกนิรภัย',
    descriptionKo: '낙하물 위험이 있는 구역이니 안전모를 반드시 착용하세요',
    descriptionEn: 'Always wear a hard hat in areas with falling object risk.',
    descriptionVi: 'Luôn đội mũ bảo hộ ở khu vực có nguy cơ vật rơi.',
    descriptionKm:
        'តំបន់នេះមានហានិភ័យវត្ថុធ្លាក់ ត្រូវពាក់មួកសុវត្ថិភាពជាចាំបាច់។',
    descriptionNe:
        'यो क्षेत्रमा चिज खस्ने जोखिम छ, सुरक्षा हेलमेट अनिवार्य लगाउनुहोस्।',
    descriptionTh: 'พื้นที่นี้มีความเสี่ยงของตกหล่น ต้องสวมหมวกนิรภัยทุกครั้ง',
  ),
  Signage(
    category: SignageCategory.logistics,
    type: SignType.warning,
    place: {
      'ko': '하역장 바닥·경사로',
      'en': 'Loading dock floors and ramps',
      'vi': 'Sàn bến bốc dỡ và đường dốc',
      'km': 'ឥដ្ឋកន្លែងផ្ទុកទំនិញ និងផ្លូវជម្រាល',
      'ne': 'लोडिङ डकको भुइँ र ढलान',
      'th': 'พื้นท่าขนถ่ายสินค้าและทางลาด',
    },
    hazard: {
      'ko': '미끄러짐·넘어짐으로 인한 골절',
      'en': 'Fractures from slips and falls',
      'vi': 'Gãy xương do trượt ngã',
      'km': 'ឆ្អឹងបាក់ដោយសារការរអិល ឬដួល',
      'ne': 'चिप्लिएर वा लडेर हड्डी भाँचिने',
      'th': 'กระดูกหักจากการลื่นหรือล้ม',
    },
    assetName: 'slip',
    icon: Icons.water_drop,
    color: Colors.orange,
    nameKo: '미끄럼 주의',
    nameEn: 'Slippery Surface',
    nameVi: 'Cẩn thận trơn trượt',
    nameKm: 'ប្រយ័ត្នរអិល',
    nameNe: 'चिप्लो सावधानी',
    nameTh: 'ระวังพื้นลื่น',
    descriptionKo: '바닥이 젖거나 기름이 묻어 미끄러울 수 있으니 천천히 걸으세요',
    descriptionEn: 'The floor may be wet or oily — walk slowly.',
    descriptionVi: 'Sàn có thể ướt hoặc dính dầu, hãy đi chậm.',
    descriptionKm: 'ឥដ្ឋអាចសើម ឬប្រឡាក់ប្រេង ធ្វើឲ្យរអិល សូមដើរយឺតៗ។',
    descriptionNe:
        'भुइँ भिजेको वा तेल लागेको हुन सक्छ, चिप्लो हुन सक्छ, बिस्तारै हिँड्नुहोस्।',
    descriptionTh: 'พื้นอาจเปียกหรือมีคราบน้ำมันทำให้ลื่น โปรดเดินช้าๆ',
  ),
  Signage(
    category: SignageCategory.logistics,
    type: SignType.mandatory,
    place: {
      'ko': '수작업 상·하차 구역',
      'en': 'Manual loading and unloading areas',
      'vi': 'Khu vực bốc dỡ thủ công',
      'km': 'តំបន់ផ្ទុក/ដោះទំនិញដោយដៃ',
      'ne': 'म्यानुअल लोडिङ र अनलोडिङ क्षेत्र',
      'th': 'พื้นที่ขนถ่ายสินค้าด้วยมือ',
    },
    hazard: {
      'ko': '날카로운 모서리·거친 표면에 의한 열상',
      'en': 'Cuts from sharp edges and rough surfaces',
      'vi': 'Vết cắt do cạnh sắc và bề mặt thô ráp',
      'km': 'របួសកាត់ដោយសារគែមមុតស្រួច ឬផ្ទៃរដិបរដុប',
      'ne': 'धारिलो किनारा वा खस्रो सतहले हुने घाउ',
      'th': 'บาดแผลจากขอบคมหรือพื้นผิวขรุขระ',
    },
    assetName: 'safety_gloves',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '안전장갑 착용',
    nameEn: 'Wear Safety Gloves',
    nameVi: 'Đeo găng tay bảo hộ',
    nameKm: 'ពាក់ស្រោមដៃសុវត្ថិភាព',
    nameNe: 'सुरक्षा पन्जा लगाउनुहोस्',
    nameTh: 'สวมถุงมือนิรภัย',
    descriptionKo: '화물의 날카로운 모서리에 베일 수 있으니 안전장갑을 착용하세요',
    descriptionEn: 'Wear safety gloves — cargo edges can cut your hands.',
    descriptionVi: 'Hãy đeo găng tay bảo hộ, cạnh hàng hóa có thể cắt tay.',
    descriptionKm: 'គែមមុតស្រួចរបស់ទំនិញអាចកាត់ដៃ សូមពាក់ស្រោមដៃសុវត្ថិភាព។',
    descriptionNe:
        'सामानको धारिलो किनाराले हात काट्न सक्छ, सुरक्षा पन्जा लगाउनुहोस्।',
    descriptionTh: 'ขอบคมของสินค้าอาจบาดมือได้ โปรดสวมถุงมือนิรภัย',
  ),

  // ── 전기 (추가 3종) ─────────────────────────────────────────────────────────
  Signage(
    category: SignageCategory.electrical,
    type: SignType.mandatory,
    place: {
      'ko': '배전반·전기실 출입구',
      'en': 'Switchboard and electrical room entrances',
      'vi': 'Lối vào tủ điện và phòng điện',
    },
    hazard: {
      'ko': '아크 섬광·낙하물로 인한 머리 부상',
      'en': 'Head injury from arc flash or falling objects',
      'vi': 'Chấn thương đầu do hồ quang hoặc vật rơi',
    },
    assetName: 'helmet',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '전기실 안전모 착용',
    nameEn: 'Wear Hard Hat (Electrical)',
    nameVi: 'Đội mũ bảo hộ (khu vực điện)',
    nameKm: 'Wear Hard Hat (Electrical)',
    nameNe: 'Wear Hard Hat (Electrical)',
    nameTh: 'Wear Hard Hat (Electrical)',
    descriptionKo: '전기실에서는 절연 성능이 있는 안전모를 착용하세요',
    descriptionEn: 'Wear an insulating hard hat inside electrical rooms.',
    descriptionVi: 'Hãy đội mũ bảo hộ cách điện trong phòng điện.',
    descriptionKm: 'Wear an insulating hard hat inside electrical rooms.',
    descriptionNe: 'Wear an insulating hard hat inside electrical rooms.',
    descriptionTh: 'Wear an insulating hard hat inside electrical rooms.',
  ),
  Signage(
    category: SignageCategory.electrical,
    type: SignType.mandatory,
    place: {
      'ko': '전기 작업 구역 전체',
      'en': 'All electrical work areas',
      'vi': 'Toàn bộ khu vực làm việc với điện',
    },
    hazard: {
      'ko': '감전 시 전류가 발로 빠져나가며 생기는 화상',
      'en': 'Burns as current exits through the feet during a shock',
      'vi': 'Bỏng khi dòng điện thoát qua chân lúc bị giật',
    },
    assetName: 'safety_shoes',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '절연화 착용',
    nameEn: 'Wear Insulated Boots',
    nameVi: 'Mang giày cách điện',
    nameKm: 'Wear Insulated Boots',
    nameNe: 'Wear Insulated Boots',
    nameTh: 'Wear Insulated Boots',
    descriptionKo: '감전 경로를 끊기 위해 절연 성능이 있는 안전화를 착용하세요',
    descriptionEn: 'Wear insulated safety boots to break the shock path.',
    descriptionVi: 'Mang giày bảo hộ cách điện để cắt đường dẫn điện giật.',
    descriptionKm: 'Wear insulated safety boots to break the shock path.',
    descriptionNe: 'Wear insulated safety boots to break the shock path.',
    descriptionTh: 'Wear insulated safety boots to break the shock path.',
  ),
  Signage(
    category: SignageCategory.electrical,
    type: SignType.mandatory,
    place: {
      'ko': '활선 근접 작업·차단기 조작 구역',
      'en': 'Live-line work and breaker operation areas',
      'vi': 'Khu vực làm việc gần điện sống và thao tác cầu dao',
    },
    hazard: {
      'ko': '아크 섬광에 의한 얼굴 화상·시력 손상',
      'en': 'Facial burns and eye damage from arc flash',
      'vi': 'Bỏng mặt và tổn thương mắt do hồ quang điện',
    },
    assetName: 'face_shield',
    icon: Icons.masks,
    color: Colors.blue,
    nameKo: '보안면 착용',
    nameEn: 'Wear Face Shield',
    nameVi: 'Đeo tấm che mặt',
    nameKm: 'Wear Face Shield',
    nameNe: 'Wear Face Shield',
    nameTh: 'Wear Face Shield',
    descriptionKo: '아크 섬광에 대비해 보안면을 착용하고 작업하세요',
    descriptionEn: 'Wear a face shield to protect against arc flash.',
    descriptionVi: 'Hãy đeo tấm che mặt để phòng hồ quang điện.',
    descriptionKm: 'Wear a face shield to protect against arc flash.',
    descriptionNe: 'Wear a face shield to protect against arc flash.',
    descriptionTh: 'Wear a face shield to protect against arc flash.',
  ),

  // ── 목공 (추가 3종) ─────────────────────────────────────────────────────────
  Signage(
    category: SignageCategory.woodworking,
    type: SignType.mandatory,
    place: {
      'ko': '목재 절단·연마·재단 구역',
      'en': 'Wood cutting, sanding and trimming areas',
      'vi': 'Khu vực cắt, chà nhám và xén gỗ',
    },
    hazard: {
      'ko': '목분진 장기 흡입으로 인한 호흡기 질환',
      'en': 'Respiratory disease from long-term wood dust inhalation',
      'vi': 'Bệnh hô hấp do hít bụi gỗ lâu dài',
    },
    assetName: 'dust_mask',
    icon: Icons.masks,
    color: Colors.blue,
    nameKo: '방진마스크 착용',
    nameEn: 'Wear Dust Mask',
    nameVi: 'Đeo khẩu trang chống bụi',
    nameKm: 'Wear Dust Mask',
    nameNe: 'Wear Dust Mask',
    nameTh: 'Wear Dust Mask',
    descriptionKo: '목분진이 날리는 구역이니 방진마스크를 착용하세요',
    descriptionEn: 'Wear a dust mask where wood dust is airborne.',
    descriptionVi: 'Hãy đeo khẩu trang chống bụi ở nơi có bụi gỗ bay.',
    descriptionKm: 'Wear a dust mask where wood dust is airborne.',
    descriptionNe: 'Wear a dust mask where wood dust is airborne.',
    descriptionTh: 'Wear a dust mask where wood dust is airborne.',
  ),
  Signage(
    category: SignageCategory.woodworking,
    type: SignType.mandatory,
    place: {
      'ko': '목공 기계 주변·자재 적치장',
      'en': 'Around woodworking machines and timber storage',
      'vi': 'Quanh máy mộc và khu để gỗ',
    },
    hazard: {
      'ko': '떨어진 목재·공구에 의한 발 부상',
      'en': 'Foot injury from dropped timber or tools',
      'vi': 'Chấn thương chân do gỗ hoặc dụng cụ rơi',
    },
    assetName: 'safety_shoes',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '목공장 안전화 착용',
    nameEn: 'Wear Safety Shoes (Woodshop)',
    nameVi: 'Mang giày bảo hộ (xưởng mộc)',
    nameKm: 'Wear Safety Shoes (Woodshop)',
    nameNe: 'Wear Safety Shoes (Woodshop)',
    nameTh: 'Wear Safety Shoes (Woodshop)',
    descriptionKo: '무거운 목재가 떨어질 수 있으니 안전화를 착용하세요',
    descriptionEn: 'Wear safety shoes — heavy timber can fall.',
    descriptionVi: 'Hãy mang giày bảo hộ, gỗ nặng có thể rơi.',
    descriptionKm: 'Wear safety shoes — heavy timber can fall.',
    descriptionNe: 'Wear safety shoes — heavy timber can fall.',
    descriptionTh: 'Wear safety shoes — heavy timber can fall.',
  ),
  Signage(
    category: SignageCategory.woodworking,
    type: SignType.warning,
    place: {
      'ko': '목재 적재 선반 아래·통로',
      'en': 'Under timber racks and walkways',
      'vi': 'Dưới kệ gỗ và lối đi',
    },
    hazard: {
      'ko': '적재된 목재 붕괴로 인한 타박상',
      'en': 'Bruising from collapsing stacked timber',
      'vi': 'Bầm dập do đống gỗ đổ',
    },
    assetName: 'falling_object',
    icon: Icons.warning_amber,
    color: Colors.orange,
    nameKo: '목재 낙하 주의',
    nameEn: 'Falling Timber Warning',
    nameVi: 'Cảnh báo gỗ rơi',
    nameKm: 'Falling Timber Warning',
    nameNe: 'Falling Timber Warning',
    nameTh: 'Falling Timber Warning',
    descriptionKo: '적재된 목재가 무너질 수 있으니 선반 아래에 머물지 마세요',
    descriptionEn: 'Stacked timber can collapse — do not stand under racks.',
    descriptionVi: 'Đống gỗ có thể đổ, đừng đứng dưới kệ.',
    descriptionKm: 'Stacked timber can collapse — do not stand under racks.',
    descriptionNe: 'Stacked timber can collapse — do not stand under racks.',
    descriptionTh: 'Stacked timber can collapse — do not stand under racks.',
  ),

  // ── 용접 (추가 3종) ─────────────────────────────────────────────────────────
  Signage(
    category: SignageCategory.welding,
    type: SignType.warning,
    place: {
      'ko': '도금·아연 강재 용접 구역',
      'en': 'Plated and galvanized steel welding areas',
      'vi': 'Khu vực hàn thép mạ kẽm',
    },
    hazard: {
      'ko': '중금속 흄 흡입으로 인한 급성 중독',
      'en': 'Acute poisoning from inhaling heavy metal fumes',
      'vi': 'Ngộ độc cấp do hít khói kim loại nặng',
    },
    assetName: 'toxic',
    icon: Icons.science,
    color: Colors.orange,
    nameKo: '유해물질 주의',
    nameEn: 'Toxic Substance Warning',
    nameVi: 'Cảnh báo chất độc hại',
    nameKm: 'Toxic Substance Warning',
    nameNe: 'Toxic Substance Warning',
    nameTh: 'Toxic Substance Warning',
    descriptionKo: '아연·카드뮴 도금재를 용접하면 유해 흄이 발생하니 환기를 확인하세요',
    descriptionEn:
        'Welding zinc or cadmium coatings releases toxic fumes — check ventilation.',
    descriptionVi:
        'Hàn lớp mạ kẽm hoặc cadmi sinh khói độc, hãy kiểm tra thông gió.',
    descriptionKm:
        'Welding zinc or cadmium coatings releases toxic fumes — check ventilation.',
    descriptionNe:
        'Welding zinc or cadmium coatings releases toxic fumes — check ventilation.',
    descriptionTh:
        'Welding zinc or cadmium coatings releases toxic fumes — check ventilation.',
  ),
  Signage(
    category: SignageCategory.welding,
    type: SignType.mandatory,
    place: {
      'ko': '밀폐·반밀폐 용접 작업 공간',
      'en': 'Enclosed and semi-enclosed welding spaces',
      'vi': 'Không gian hàn kín và bán kín',
    },
    hazard: {
      'ko': '용접 흄 축적으로 인한 호흡기 손상',
      'en': 'Respiratory damage from accumulated welding fumes',
      'vi': 'Tổn thương hô hấp do khói hàn tích tụ',
    },
    assetName: 'dust_mask',
    icon: Icons.masks,
    color: Colors.blue,
    nameKo: '용접 방진마스크 착용',
    nameEn: 'Wear Fume Mask (Welding)',
    nameVi: 'Đeo khẩu trang lọc khói hàn',
    nameKm: 'Wear Fume Mask (Welding)',
    nameNe: 'Wear Fume Mask (Welding)',
    nameTh: 'Wear Fume Mask (Welding)',
    descriptionKo: '용접 흄이 쌓이는 공간이니 방진마스크를 착용하세요',
    descriptionEn: 'Wear a fume mask where welding smoke builds up.',
    descriptionVi: 'Hãy đeo khẩu trang nơi khói hàn tích tụ.',
    descriptionKm: 'Wear a fume mask where welding smoke builds up.',
    descriptionNe: 'Wear a fume mask where welding smoke builds up.',
    descriptionTh: 'Wear a fume mask where welding smoke builds up.',
  ),
  Signage(
    category: SignageCategory.welding,
    type: SignType.mandatory,
    place: {
      'ko': '용접기·모재 취급 구역',
      'en': 'Welder and workpiece handling areas',
      'vi': 'Khu vực thao tác máy hàn và phôi',
    },
    hazard: {
      'ko': '가열된 모재·스패터에 의한 손 화상',
      'en': 'Hand burns from hot workpieces and spatter',
      'vi': 'Bỏng tay do phôi nóng và xỉ hàn bắn',
    },
    assetName: 'safety_gloves',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '용접장갑 착용',
    nameEn: 'Wear Welding Gloves',
    nameVi: 'Đeo găng tay hàn',
    nameKm: 'Wear Welding Gloves',
    nameNe: 'Wear Welding Gloves',
    nameTh: 'Wear Welding Gloves',
    descriptionKo: '모재가 오래 뜨거우니 반드시 용접용 장갑을 착용하세요',
    descriptionEn:
        'Workpieces stay hot for a long time — always wear welding gloves.',
    descriptionVi: 'Phôi giữ nóng rất lâu, luôn đeo găng tay hàn.',
    descriptionKm:
        'Workpieces stay hot for a long time — always wear welding gloves.',
    descriptionNe:
        'Workpieces stay hot for a long time — always wear welding gloves.',
    descriptionTh:
        'Workpieces stay hot for a long time — always wear welding gloves.',
  ),

  // ── 프레스 (추가 3종) ───────────────────────────────────────────────────────
  Signage(
    category: SignageCategory.press,
    type: SignType.mandatory,
    place: {
      'ko': '프레스 전면·금형 교체 구역',
      'en': 'Press front and die change areas',
      'vi': 'Phía trước máy ép và khu thay khuôn',
    },
    hazard: {
      'ko': '금속 파편 비산으로 인한 안구 손상',
      'en': 'Eye injury from flying metal fragments',
      'vi': 'Tổn thương mắt do mảnh kim loại văng',
    },
    assetName: 'eye_protection',
    icon: Icons.visibility,
    color: Colors.blue,
    nameKo: '프레스 보안경 착용',
    nameEn: 'Wear Safety Glasses (Press)',
    nameVi: 'Đeo kính bảo hộ (máy ép)',
    nameKm: 'Wear Safety Glasses (Press)',
    nameNe: 'Wear Safety Glasses (Press)',
    nameTh: 'Wear Safety Glasses (Press)',
    descriptionKo: '금속 파편이 튈 수 있으니 보안경을 착용하세요',
    descriptionEn: 'Wear safety glasses — metal fragments can fly out.',
    descriptionVi: 'Hãy đeo kính bảo hộ, mảnh kim loại có thể văng ra.',
    descriptionKm: 'Wear safety glasses — metal fragments can fly out.',
    descriptionNe: 'Wear safety glasses — metal fragments can fly out.',
    descriptionTh: 'Wear safety glasses — metal fragments can fly out.',
  ),
  Signage(
    category: SignageCategory.press,
    type: SignType.mandatory,
    place: {
      'ko': '금형 운반·적치 구역',
      'en': 'Die transport and storage areas',
      'vi': 'Khu vận chuyển và để khuôn',
    },
    hazard: {
      'ko': '무거운 금형 낙하로 인한 발 골절',
      'en': 'Foot fracture from dropped heavy dies',
      'vi': 'Gãy chân do khuôn nặng rơi',
    },
    assetName: 'safety_shoes',
    icon: Icons.health_and_safety,
    color: Colors.blue,
    nameKo: '프레스 안전화 착용',
    nameEn: 'Wear Safety Shoes (Press)',
    nameVi: 'Mang giày bảo hộ (máy ép)',
    nameKm: 'Wear Safety Shoes (Press)',
    nameNe: 'Wear Safety Shoes (Press)',
    nameTh: 'Wear Safety Shoes (Press)',
    descriptionKo: '금형은 매우 무거우니 안전화를 반드시 착용하세요',
    descriptionEn: 'Dies are extremely heavy — always wear safety shoes.',
    descriptionVi: 'Khuôn rất nặng, luôn mang giày bảo hộ.',
    descriptionKm: 'Dies are extremely heavy — always wear safety shoes.',
    descriptionNe: 'Dies are extremely heavy — always wear safety shoes.',
    descriptionTh: 'Dies are extremely heavy — always wear safety shoes.',
  ),
  Signage(
    category: SignageCategory.press,
    type: SignType.warning,
    place: {
      'ko': '프레스 가동 구역',
      'en': 'Press operating areas',
      'vi': 'Khu vực máy ép hoạt động',
    },
    hazard: {
      'ko': '충격 소음 반복 노출로 인한 청력 손실',
      'en': 'Hearing loss from repeated impact noise',
      'vi': 'Mất thính lực do tiếng ồn va đập lặp lại',
    },
    assetName: 'ear_protection',
    icon: Icons.hearing,
    color: Colors.orange,
    nameKo: '프레스 소음 주의',
    nameEn: 'Noise Hazard (Press)',
    nameVi: 'Cảnh báo tiếng ồn (máy ép)',
    nameKm: 'Noise Hazard (Press)',
    nameNe: 'Noise Hazard (Press)',
    nameTh: 'Noise Hazard (Press)',
    descriptionKo: '프레스 충격 소음이 크니 귀마개를 착용하세요',
    descriptionEn: 'Press impact noise is loud — wear hearing protection.',
    descriptionVi: 'Tiếng ồn máy ép rất lớn, hãy đeo nút bịt tai.',
    descriptionKm: 'Press impact noise is loud — wear hearing protection.',
    descriptionNe: 'Press impact noise is loud — wear hearing protection.',
    descriptionTh: 'Press impact noise is loud — wear hearing protection.',
  ),
];

List<Signage> signageForCategory(SignageCategory category) =>
    signageCatalog.where((s) => s.category == category).toList();

/// 이름 끝에 모델이 덧붙이기 쉬운 말. '표지판' 이 '표지' 를 포함하지 않고 끝나는
/// 말이라 순서와 무관하지만, 긴 것을 먼저 둔다.
const _signageNameSuffixes = ['표지판', '표지', '표시'];

/// 한국어 이름([Signage.nameKo])이 [name] 과 같은 표지판을 찾는다.
/// 촬영한 사진을 Gemini 가 등록된 표지판으로 판별했을 때 그 이름으로 조회하는 데 쓴다.
/// 모델이 띄어쓰기를 빼거나 '표지' 같은 말을 덧붙여도 찾도록 아래 순서로 시도한다.
///
/// 1. trim 후 정확히 일치
/// 2. 양쪽 모두 공백을 전부 제거하고 비교
/// 3. 입력 끝의 '표지판'/'표지'/'표시' 를 떼고 1~2 를 다시 시도
/// 4. 그래도 없으면 null
///
/// 부분 문자열 포함(contains) 매칭은 일부러 하지 않는다 — 엉뚱한 표지판이 잡힐 수 있다.
///
/// '손 끼임 주의' 는 목공과 프레스에 같은 이름으로 두 번 등록돼 있어서, 카탈로그
/// 순서상 먼저 나오는 항목(목공)을 쓴다.
Signage? signageByKoreanName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return null;

  final found = _matchSignageName(trimmed);
  if (found != null) return found;

  for (final suffix in _signageNameSuffixes) {
    if (trimmed.endsWith(suffix)) {
      final stripped = trimmed.substring(0, trimmed.length - suffix.length);
      return _matchSignageName(stripped.trim());
    }
  }
  return null;
}

/// [signageByKoreanName] 의 1~2 단계: 정확히 일치, 없으면 공백을 모두 지우고 일치.
Signage? _matchSignageName(String name) {
  if (name.isEmpty) return null;
  for (final signage in signageCatalog) {
    if (signage.nameKo == name) return signage;
  }
  final compact = name.replaceAll(RegExp(r'\s+'), '');
  if (compact.isEmpty) return null;
  for (final signage in signageCatalog) {
    if (signage.nameKo.replaceAll(RegExp(r'\s+'), '') == compact) {
      return signage;
    }
  }
  return null;
}
