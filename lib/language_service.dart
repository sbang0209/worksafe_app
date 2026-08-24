import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 분석 결과(6항목 + manager_notice) 및 앱 UI 문구를 표시할 언어.
///
/// 정식 i18n 패키지 없이, 화면에 노출되는 고정 문구를 언어별 필드로 직접 들고 있다.
/// 새 문구가 필요하면 이 클래스에 필드를 추가하고 ko/en/vi 세 값을 모두 채운다.
class AppLanguage {
  const AppLanguage._({
    required this.code,
    required this.label,
    required this.promptName,
    required this.unknownLabel,
    required this.managerNotice,
    // 버튼
    required this.takePhotoButton,
    required this.retakeButton,
    required this.homeLabel,
    required this.backToListButton,
    required this.viewRecordButton,
    required this.confirmButton,
    // 결과 카드 섹션 제목
    required this.hazardsTitle,
    required this.ppeTitle,
    required this.prohibitedTitle,
    required this.viewAllButton,
    // 탭 / 화면 제목
    required this.cameraLabel,
    required this.historyLabel,
    required this.menuLabel,
    required this.historyDetailTitle,
    required this.languageSettingsLabel,
    required this.languageSectionHeader,
    // 다이얼로그
    required this.duplicateDialogTitle,
    required this.duplicateDialogBodyTemplate,
    // 안내 / 상태 문구
    required this.noHistoryMessage,
    required this.noCameraMessage,
    required this.cameraInitErrorTemplate,
    required this.cameraOverlayHint,
    required this.analyzingText,
    required this.captureCompleteText,
    required this.captureFailedPrefix,
    // Gemini 실패/폴백 메시지 (분석 실패 시 "이름" 자리에 노출됨)
    required this.errorNoApiKey,
    required this.errorServerBusy,
    required this.errorStatusCodeTemplate,
    required this.errorGeneric,
    required this.errorNetworkOrApi,
    // 홈 화면
    required this.safetyMessages,
    required this.searchPlaceholder,
    required this.categoryLogistics,
    required this.categoryElectrical,
    required this.categoryWoodworking,
    required this.categoryWelding,
    required this.categoryPress,
    required this.dangerSignageTitle,
    required this.comingSoonMessage,
  });

  /// shared_preferences 에 저장되는 값 (ko/en/vi)
  final String code;

  /// 언어 설정 화면에 보여줄 이름 (언어 자체의 이름이라 번역하지 않는다)
  final String label;

  /// Gemini 프롬프트에 "이 언어로 답해라" 라고 넣을 때 쓰는 이름
  final String promptName;

  /// 해당 필드를 모를 때 쓰는 고정 문구 ('알 수 없음' 에 해당)
  final String unknownLabel;

  /// 관리자 확인 안내. AI 생성이 아니라 언어별로 코드에서 고정 삽입한다.
  final String managerNotice;

  final String takePhotoButton;
  final String retakeButton;

  /// 하단 탭 라벨과 결과 화면의 "홈" 버튼에 공통으로 쓰인다.
  final String homeLabel;
  final String backToListButton;
  final String viewRecordButton;
  final String confirmButton;

  final String hazardsTitle;
  final String ppeTitle;
  final String prohibitedTitle;

  /// 홈 화면의 최근 기록 미리보기에서 최근 기록 탭으로 이동하는 버튼.
  final String viewAllButton;

  /// 하단 탭의 카메라 항목 라벨.
  final String cameraLabel;

  /// 하단 탭 라벨과 최근 기록 화면 AppBar 제목에 공통으로 쓰인다.
  final String historyLabel;

  /// 하단 탭 라벨과 메뉴 화면 AppBar 제목에 공통으로 쓰인다.
  final String menuLabel;
  final String historyDetailTitle;

  /// 메뉴 목록 항목과 언어 설정 화면 AppBar 제목에 공통으로 쓰인다.
  final String languageSettingsLabel;
  final String languageSectionHeader;

  final String duplicateDialogTitle;

  /// '{name}' 자리를 물건 이름으로 치환해서 쓴다.
  final String duplicateDialogBodyTemplate;

  final String noHistoryMessage;
  final String noCameraMessage;

  /// '{error}' 자리를 에러 내용으로 치환해서 쓴다.
  final String cameraInitErrorTemplate;
  final String cameraOverlayHint;
  final String analyzingText;
  final String captureCompleteText;

  /// 뒤에 예외 메시지($e)가 그대로 이어붙는 접두어.
  final String captureFailedPrefix;

  final String errorNoApiKey;
  final String errorServerBusy;

  /// '{code}' 자리를 HTTP 상태 코드로 치환해서 쓴다.
  final String errorStatusCodeTemplate;
  final String errorGeneric;
  final String errorNetworkOrApi;

  /// 홈 화면 상단에서 일정 시간마다 돌아가며 표시되는 안전 멘트 5개.
  final List<String> safetyMessages;
  final String searchPlaceholder;

  final String categoryLogistics;
  final String categoryElectrical;
  final String categoryWoodworking;
  final String categoryWelding;
  final String categoryPress;

  /// 홈 화면 하단, 선택된 카테고리의 표지판 카드 그리드 제목.
  final String dangerSignageTitle;

  /// 아직 구현되지 않은 화면에 쓰는 안내 문구.
  final String comingSoonMessage;

  static const ko = AppLanguage._(
    code: 'ko',
    label: '한국어',
    promptName: '한국어',
    unknownLabel: '알 수 없음',
    managerNotice: '정확한 작동 방법은 반드시 현장 관리자에게 확인하세요',
    takePhotoButton: '촬영하기',
    retakeButton: '다시 찍기',
    homeLabel: '홈',
    backToListButton: '목록으로',
    viewRecordButton: '기록 보기',
    confirmButton: '확인',
    hazardsTitle: '위험 요소',
    ppeTitle: '필요 보호구',
    prohibitedTitle: '금지 행동',
    viewAllButton: '전체 보기',
    cameraLabel: '카메라',
    historyLabel: '최근 기록',
    menuLabel: '메뉴',
    historyDetailTitle: '기록 상세',
    languageSettingsLabel: '언어 설정',
    languageSectionHeader: '분석 결과를 받을 언어',
    duplicateDialogTitle: '중복 촬영',
    duplicateDialogBodyTemplate: '오늘 이미 이 물건을 찍은 기록이 있어요.\n\n장비 품명 = {name}',
    noHistoryMessage: '아직 기록이 없어요',
    noCameraMessage: '사용 가능한 카메라가 없습니다.\n실기기(USB 연결)에서 실행하세요.',
    cameraInitErrorTemplate: '카메라 초기화 실패: {error}\n권한을 허용했는지 확인하세요.',
    cameraOverlayHint: '궁금한 물건을 네모 안에 맞추세요',
    analyzingText: '분석 중...',
    captureCompleteText: '촬영 완료',
    captureFailedPrefix: '촬영 실패: ',
    errorNoApiKey: '인식 실패 (API 키 없음)',
    errorServerBusy: '서버가 혼잡합니다. 잠시 후 다시 시도하세요',
    errorStatusCodeTemplate: '인식 실패 (상태코드: {code})',
    errorGeneric: '인식 실패',
    errorNetworkOrApi: '인식 실패 (네트워크 또는 API 오류)',
    safetyMessages: [
      '안전하게, 작업 전 보호구를 확인하세요',
      '위험한 기계는 카메라로 비춰 확인하세요',
      '몸이 아프면 참지 말고 관리자에게 알리세요',
      '비상정지 버튼 위치를 미리 확인해 두세요',
      '더운 날엔 물을 자주 마시고 쉬어가세요',
    ],
    searchPlaceholder: '검색',
    categoryLogistics: '물류',
    categoryElectrical: '전기',
    categoryWoodworking: '목공',
    categoryWelding: '용접',
    categoryPress: '프레스',
    dangerSignageTitle: '위험 표지판',
    comingSoonMessage: '준비 중입니다',
  );

  static const en = AppLanguage._(
    code: 'en',
    label: 'English',
    promptName: 'English',
    unknownLabel: 'Unknown',
    managerNotice:
        'Always confirm the correct operation with your on-site manager.',
    takePhotoButton: 'Take Photo',
    retakeButton: 'Retake',
    homeLabel: 'Home',
    backToListButton: 'Back to List',
    viewRecordButton: 'View Record',
    confirmButton: 'OK',
    hazardsTitle: 'Hazards',
    ppeTitle: 'Required PPE',
    prohibitedTitle: 'Prohibited Actions',
    viewAllButton: 'View All',
    cameraLabel: 'Camera',
    historyLabel: 'History',
    menuLabel: 'Menu',
    historyDetailTitle: 'Record Details',
    languageSettingsLabel: 'Language Settings',
    languageSectionHeader: 'Language for analysis results',
    duplicateDialogTitle: 'Duplicate Photo',
    duplicateDialogBodyTemplate:
        'You already have a record of this item today.\n\nItem name = {name}',
    noHistoryMessage: 'No records yet',
    noCameraMessage:
        'No camera available.\nPlease run on a physical device (USB connected).',
    cameraInitErrorTemplate:
        'Camera initialization failed: {error}\nPlease check that permission was granted.',
    cameraOverlayHint: 'Fit the item you want to check inside the box',
    analyzingText: 'Analyzing...',
    captureCompleteText: 'Capture complete',
    captureFailedPrefix: 'Capture failed: ',
    errorNoApiKey: 'Recognition failed (missing API key)',
    errorServerBusy: 'The server is busy. Please try again in a moment.',
    errorStatusCodeTemplate: 'Recognition failed (status code: {code})',
    errorGeneric: 'Recognition failed',
    errorNetworkOrApi: 'Recognition failed (network or API error)',
    safetyMessages: [
      'Stay safe today—check your protective gear before work',
      'Point your camera at unfamiliar machines to check them',
      'If you feel unwell, tell your manager right away',
      'Know where the emergency stop button is',
      'Drink water often and take breaks on hot days',
    ],
    searchPlaceholder: 'Search',
    categoryLogistics: 'Logistics',
    categoryElectrical: 'Electrical',
    categoryWoodworking: 'Woodworking',
    categoryWelding: 'Welding',
    categoryPress: 'Press',
    dangerSignageTitle: 'Danger Signage',
    comingSoonMessage: 'Coming soon',
  );

  static const vi = AppLanguage._(
    code: 'vi',
    label: 'Tiếng Việt',
    promptName: 'Tiếng Việt (Vietnamese)',
    unknownLabel: 'Không rõ',
    managerNotice:
        'Hãy luôn xác nhận cách vận hành chính xác với quản lý hiện trường.',
    takePhotoButton: 'Chụp ảnh',
    retakeButton: 'Chụp lại',
    homeLabel: 'Trang chủ',
    backToListButton: 'Về danh sách',
    viewRecordButton: 'Xem bản ghi',
    confirmButton: 'Đồng ý',
    hazardsTitle: 'Nguy cơ',
    ppeTitle: 'Thiết bị bảo hộ cần thiết',
    prohibitedTitle: 'Hành động cấm',
    viewAllButton: 'Xem tất cả',
    cameraLabel: 'Máy ảnh',
    historyLabel: 'Lịch sử',
    menuLabel: 'Menu',
    historyDetailTitle: 'Chi tiết bản ghi',
    languageSettingsLabel: 'Cài đặt ngôn ngữ',
    languageSectionHeader: 'Ngôn ngữ nhận kết quả phân tích',
    duplicateDialogTitle: 'Trùng lặp ảnh chụp',
    duplicateDialogBodyTemplate:
        'Hôm nay bạn đã chụp vật này rồi.\n\nTên thiết bị = {name}',
    noHistoryMessage: 'Chưa có bản ghi nào',
    noCameraMessage:
        'Không có camera khả dụng.\nVui lòng chạy trên thiết bị thật (kết nối USB).',
    cameraInitErrorTemplate:
        'Khởi tạo camera thất bại: {error}\nVui lòng kiểm tra quyền truy cập đã được cấp chưa.',
    cameraOverlayHint: 'Đặt vật cần kiểm tra vào trong khung',
    analyzingText: 'Đang phân tích...',
    captureCompleteText: 'Đã chụp xong',
    captureFailedPrefix: 'Chụp ảnh thất bại: ',
    errorNoApiKey: 'Nhận diện thất bại (thiếu khóa API)',
    errorServerBusy: 'Máy chủ đang quá tải. Vui lòng thử lại sau.',
    errorStatusCodeTemplate: 'Nhận diện thất bại (mã trạng thái: {code})',
    errorGeneric: 'Nhận diện thất bại',
    errorNetworkOrApi: 'Nhận diện thất bại (lỗi mạng hoặc API)',
    safetyMessages: [
      'Hãy an toàn hôm nay — kiểm tra đồ bảo hộ trước khi làm việc',
      'Hãy chụp ảnh máy móc lạ để kiểm tra mức độ nguy hiểm',
      'Nếu cảm thấy không khỏe, đừng cố chịu đựng — hãy báo ngay cho quản lý',
      'Hãy xác định trước vị trí nút dừng khẩn cấp',
      'Vào ngày nóng, hãy uống nước thường xuyên và nghỉ ngơi',
    ],
    searchPlaceholder: 'Tìm kiếm',
    categoryLogistics: 'Hậu cần',
    categoryElectrical: 'Điện',
    categoryWoodworking: 'Mộc',
    categoryWelding: 'Hàn',
    categoryPress: 'Máy ép',
    dangerSignageTitle: 'Biển báo nguy hiểm',
    comingSoonMessage: 'Đang chuẩn bị',
  );

  static const all = [ko, en, vi];

  static AppLanguage fromCode(String? code) {
    return all.firstWhere((l) => l.code == code, orElse: () => ko);
  }
}

/// "분석 결과를 받을 언어" 겸 앱 UI 언어 설정을 shared_preferences 에 저장/조회하는 서비스.
///
/// [ChangeNotifier] 라, 언어가 바뀌면 이 인스턴스를 구독하는 위젯들이 즉시 다시 그려진다.
class LanguageService extends ChangeNotifier {
  LanguageService._();

  static final LanguageService instance = LanguageService._();

  static const _prefsKey = 'result_language';

  AppLanguage _current = AppLanguage.ko;
  bool _initialized = false;

  /// 현재 언어. init() 이 끝나기 전에는 기본값(한국어)을 돌려준다.
  AppLanguage get current => _current;

  /// 앱 시작 시(runApp 전) 한 번 호출해 저장된 언어를 불러온다.
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _current = AppLanguage.fromCode(prefs.getString(_prefsKey));
    _initialized = true;
    notifyListeners();
  }

  /// init() 이 아직 안 끝났으면 기다렸다가 현재 언어를 돌려준다.
  Future<AppLanguage> getLanguage() async {
    await init();
    return _current;
  }

  Future<void> setLanguage(AppLanguage language) async {
    _current = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  }
}
