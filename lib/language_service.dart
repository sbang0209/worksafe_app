import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 분석 결과(6항목) 및 앱 UI 문구를 표시할 언어.
///
/// 정식 i18n 패키지 없이, 화면에 노출되는 고정 문구를 언어별 필드로 직접 들고 있다.
/// 새 문구가 필요하면 이 클래스에 필드를 추가하고 모든 언어 값을 채운다.
class AppLanguage {
  const AppLanguage._({
    required this.code,
    required this.label,
    required this.englishName,
    required this.flag,
    required this.promptName,
    required this.unknownLabel,
    required this.managerNotice,
    // 공통 버튼
    required this.retakeButton,
    required this.homeLabel,
    required this.viewRecordButton,
    required this.confirmButton,
    required this.cancelButton,
    required this.deleteButton,
    required this.closeLabel,
    required this.shareLabel,
    // 분석 결과
    required this.hazardsTitle,
    required this.ppeTitle,
    required this.prohibitedTitle,
    required this.analysisResultTitle,
    required this.askManagerButton,
    // 하단 탭
    required this.cameraLabel,
    required this.signageLabel,
    required this.historyTabLabel,
    required this.historyLabel,
    required this.menuLabel,
    // 언어 선택
    required this.languageSettingsLabel,
    required this.languagePickerTitle,
    required this.languagePickerSubtitle,
    required this.languageNames,
    // 메뉴
    required this.howToUseLabel,
    required this.howToUseSteps,
    required this.appInfoLabel,
    required this.appDescription,
    required this.clearHistoryLabel,
    required this.clearHistoryConfirmMessage,
    required this.historyClearedMessage,
    required this.appSettingsSection,
    required this.dataAccountSection,
    required this.employeeNumberTemplate,
    // 다이얼로그
    required this.duplicateDialogTitle,
    required this.duplicateDialogBodyTemplate,
    // 카메라 / 상태 문구
    required this.noHistoryMessage,
    required this.noCameraMessage,
    required this.cameraInitErrorTemplate,
    required this.cameraOverlayHint,
    required this.analyzingText,
    required this.captureFailedPrefix,
    required this.galleryLabel,
    required this.switchCameraLabel,
    // Gemini 실패/폴백 메시지 (분석 실패 시 "이름" 자리에 노출됨)
    required this.errorNoApiKey,
    required this.errorServerBusy,
    required this.errorStatusCodeTemplate,
    required this.errorGeneric,
    required this.errorNetworkOrApi,
    // 홈 / 검색 / 공지
    required this.greetingTemplate,
    required this.searchPlaceholder,
    required this.noSearchResultMessage,
    required this.safetyNoticeTitle,
    required this.recentAnalysisTitle,
    required this.viewAllButton,
    required this.notificationsLabel,
    required this.daysAgoTemplate,
    required this.todayLabel,
    required this.yesterdayLabel,
    required this.noticeUrgentLabel,
    required this.noticeCampaignLabel,
    required this.noticeKeyPointsTitle,
    required this.viewOriginalButton,
    required this.launchFailedMessage,
    // 표지판
    required this.categoryLogistics,
    required this.categoryElectrical,
    required this.categoryWoodworking,
    required this.categoryWelding,
    required this.categoryPress,
    required this.signageSubtitle,
    required this.signTypeWarning,
    required this.signTypeMandatory,
    required this.signTypeProhibition,
    required this.signPlaceLabel,
    required this.signHazardLabel,
    required this.listenLabel,
    required this.ttsUnavailableMessage,
    // 현장 관리자
    required this.managerTitle,
    required this.phoneLabel,
    required this.locationLabel,
    required this.workHoursLabel,
    required this.callButton,
    required this.messageLabel,
    // 최근 기록
    required this.historyCountTemplate,
    required this.filterAllLabel,
    required this.levelDangerLabel,
    required this.levelCautionLabel,
    required this.levelMandatoryLabel,
    required this.noFilteredHistoryMessage,
    // 스플래시
    required this.appSlogan,
  });

  /// shared_preferences 와 분석 결과 맵의 언어 키 (ko/en/vi/km/ne/th)
  final String code;

  /// 그 언어 자체로 쓴 이름 (번역하지 않는다). 예: '한국어', 'ภาษาไทย'
  final String label;

  /// 영어 이름. 언어 선택 시트에서 지금 고른 언어의 보조 줄에 쓴다.
  final String englishName;

  /// 언어 선택 시트에 보여줄 국기 이모지.
  final String flag;

  /// Gemini 프롬프트에 "이 언어로 답해라" 라고 넣을 때 쓰는 이름
  final String promptName;

  /// 해당 필드를 모를 때 쓰는 고정 문구 ('알 수 없음' 에 해당)
  final String unknownLabel;

  /// 관리자 확인 안내. AI 생성이 아니라 언어별로 코드에서 고정 삽입한다.
  final String managerNotice;

  final String retakeButton;

  /// 하단 탭의 홈 라벨.
  final String homeLabel;
  final String viewRecordButton;
  final String confirmButton;
  final String cancelButton;
  final String deleteButton;
  final String closeLabel;
  final String shareLabel;

  final String hazardsTitle;
  final String ppeTitle;
  final String prohibitedTitle;

  /// 분석 결과 화면(촬영 직후 / 기록 상세) 상단 제목.
  final String analysisResultTitle;

  /// 분석 결과 화면 하단의 주요 버튼. 누르면 현장 관리자 화면으로 간다.
  final String askManagerButton;

  /// 하단 탭 가운데 카메라 버튼과 카메라 화면 제목.
  final String cameraLabel;

  /// 하단 탭의 표지판 항목 라벨이자 표지판 화면 제목.
  final String signageLabel;

  /// 하단 탭의 기록 항목 라벨. 화면 제목은 [historyLabel] 을 쓴다.
  final String historyTabLabel;
  final String historyLabel;
  final String menuLabel;

  /// 메뉴의 언어 설정 항목.
  final String languageSettingsLabel;

  /// 언어 선택 시트의 제목과 안내 문구.
  final String languagePickerTitle;
  final String languagePickerSubtitle;

  /// 이 언어로 쓴 각 언어의 이름. 키는 [code]. 예: 한국어 UI 의 'en' → '영어'
  final Map<String, String> languageNames;

  /// 메뉴 목록 항목이자 사용 방법 다이얼로그의 제목에 함께 쓰인다.
  final String howToUseLabel;

  /// 사용 방법 다이얼로그에 번호를 붙여 한 줄씩 보여줄 단계 설명.
  final List<String> howToUseSteps;

  final String appInfoLabel;
  final String appDescription;
  final String clearHistoryLabel;
  final String clearHistoryConfirmMessage;

  /// 기록을 모두 지운 뒤 띄우는 스낵바 문구.
  final String historyClearedMessage;

  /// 메뉴 화면의 묶음 제목.
  final String appSettingsSection;
  final String dataAccountSection;

  /// 프로필의 사원번호 줄. '{number}' 자리를 사원번호로 치환해서 쓴다.
  final String employeeNumberTemplate;

  final String duplicateDialogTitle;

  /// '{name}' 자리를 물건 이름으로 치환해서 쓴다.
  final String duplicateDialogBodyTemplate;

  final String noHistoryMessage;
  final String noCameraMessage;

  /// '{error}' 자리를 에러 내용으로 치환해서 쓴다.
  final String cameraInitErrorTemplate;
  final String cameraOverlayHint;
  final String analyzingText;

  /// 뒤에 예외 메시지($e)가 그대로 이어붙는 접두어.
  final String captureFailedPrefix;

  /// 카메라 화면의 갤러리 / 카메라 전환 버튼 툴팁.
  final String galleryLabel;
  final String switchCameraLabel;

  final String errorNoApiKey;
  final String errorServerBusy;

  /// '{code}' 자리를 HTTP 상태 코드로 치환해서 쓴다.
  final String errorStatusCodeTemplate;
  final String errorGeneric;
  final String errorNetworkOrApi;

  /// 홈 인사말. '{name}' 자리에 이름이 들어가고 '\n' 에서 줄을 바꾼다.
  final String greetingTemplate;
  final String searchPlaceholder;
  final String noSearchResultMessage;

  /// 홈의 섹션 제목과 공지 목록 화면 제목.
  final String safetyNoticeTitle;
  final String recentAnalysisTitle;
  final String viewAllButton;

  /// 홈 오른쪽 위 종 버튼 툴팁.
  final String notificationsLabel;

  /// '{n}' 자리에 며칠 전인지 들어간다.
  final String daysAgoTemplate;
  final String todayLabel;
  final String yesterdayLabel;

  /// 공지 등급 라벨.
  final String noticeUrgentLabel;
  final String noticeCampaignLabel;
  final String noticeKeyPointsTitle;
  final String viewOriginalButton;

  /// 브라우저/전화/문자 앱을 열지 못했을 때 보여주는 안내 문구.
  final String launchFailedMessage;

  final String categoryLogistics;
  final String categoryElectrical;
  final String categoryWoodworking;
  final String categoryWelding;
  final String categoryPress;

  /// 표지판 화면 제목 아래 안내 줄.
  final String signageSubtitle;

  /// 표지판 종류 (경고 / 지시 / 금지).
  final String signTypeWarning;
  final String signTypeMandatory;
  final String signTypeProhibition;

  /// 표지판 상세의 "붙는 곳" / "위험" 줄 라벨.
  final String signPlaceLabel;
  final String signHazardLabel;

  /// "음성으로 듣기" 버튼 (표지판 상세 / 결과 스피커 툴팁).
  final String listenLabel;

  /// 폰이 현재 언어의 음성(TTS)을 지원하지 않을 때 보여주는 안내 문구.
  final String ttsUnavailableMessage;

  /// 현장 관리자 화면.
  final String managerTitle;
  final String phoneLabel;
  final String locationLabel;
  final String workHoursLabel;
  final String callButton;
  final String messageLabel;

  /// 최근 기록 제목 아래 요약 줄. '{count}' 자리에 강조된 기록 수가 들어간다.
  final String historyCountTemplate;
  final String filterAllLabel;

  /// 위험도 배지·필터 라벨 (위험 / 주의 / 필수).
  final String levelDangerLabel;
  final String levelCautionLabel;
  final String levelMandatoryLabel;

  /// 필터를 걸었을 때 맞는 기록이 없으면 보여주는 문구.
  final String noFilteredHistoryMessage;

  /// 스플래시 화면에서 앱 이름 아래에 뜨는 슬로건.
  final String appSlogan;

  static const ko = AppLanguage._(
    code: 'ko',
    label: '한국어',
    englishName: 'Korean',
    flag: '🇰🇷',
    promptName: '한국어',
    unknownLabel: '알 수 없음',
    managerNotice: '장비를 작동하기 전에는 반드시 현장 관리자에게 확인하세요.',
    retakeButton: '다시 찍기',
    homeLabel: '홈',
    viewRecordButton: '기록 보기',
    confirmButton: '확인',
    cancelButton: '취소',
    deleteButton: '삭제',
    closeLabel: '닫기',
    shareLabel: '공유',
    hazardsTitle: '이런 위험이 있어요',
    ppeTitle: '이건 꼭 착용하세요',
    prohibitedTitle: '이건 하지 마세요',
    analysisResultTitle: '분석 결과',
    askManagerButton: '관리자에게 작동법 확인',
    cameraLabel: '카메라',
    signageLabel: '표지판',
    historyTabLabel: '기록',
    historyLabel: '최근 기록',
    menuLabel: '메뉴',
    languageSettingsLabel: '언어 설정',
    languagePickerTitle: '언어 선택',
    languagePickerSubtitle: '고른 언어로 앱 전체 문구와 분석 결과가 즉시 바뀝니다',
    languageNames: {
      'ko': '한국어',
      'en': '영어',
      'vi': '베트남어',
      'km': '캄보디아어',
      'ne': '네팔어',
      'th': '태국어',
    },
    howToUseLabel: '사용 방법',
    howToUseSteps: [
      '가운데 카메라 버튼을 눌러 물건을 촬영하세요',
      'AI가 물건과 안전 정보를 알려줘요',
      '기록 탭에서 다시 볼 수 있어요',
    ],
    appInfoLabel: '앱 정보',
    appDescription: '스마트제조 현장 외국인 근로자를 위한 안전 정보 앱',
    clearHistoryLabel: '기록 전체 삭제',
    clearHistoryConfirmMessage: '모든 기록을 삭제하시겠어요?\n저장된 사진도 함께 지워집니다.',
    historyClearedMessage: '모든 기록을 삭제했어요',
    appSettingsSection: '앱 설정',
    dataAccountSection: '데이터 · 계정',
    employeeNumberTemplate: '사원번호 {number}',
    duplicateDialogTitle: '중복 촬영',
    duplicateDialogBodyTemplate: '오늘 이미 이 물건을 찍은 기록이 있어요.\n\n장비 품명 = {name}',
    noHistoryMessage: '아직 기록이 없어요',
    noCameraMessage: '사용 가능한 카메라가 없습니다.\n실기기(USB 연결)에서 실행하세요.',
    cameraInitErrorTemplate: '카메라 초기화 실패: {error}\n권한을 허용했는지 확인하세요.',
    cameraOverlayHint: '궁금한 물건을 화면에 담고 촬영하세요',
    analyzingText: '분석 중...',
    captureFailedPrefix: '촬영 실패: ',
    galleryLabel: '사진 불러오기',
    switchCameraLabel: '카메라 전환',
    errorNoApiKey: '인식 실패 (API 키 없음)',
    errorServerBusy: '서버가 혼잡합니다. 잠시 후 다시 시도하세요',
    errorStatusCodeTemplate: '인식 실패 (상태코드: {code})',
    errorGeneric: '인식 실패',
    errorNetworkOrApi: '인식 실패 (네트워크 또는 API 오류)',
    greetingTemplate: '{name} 님,\n오늘도 안전하게',
    searchPlaceholder: '이름이나 설명으로 장비·표지판 찾기',
    noSearchResultMessage: '검색 결과가 없어요',
    safetyNoticeTitle: '안전 공지',
    recentAnalysisTitle: '최근 분석',
    viewAllButton: '전체 보기',
    notificationsLabel: '알림',
    daysAgoTemplate: '{n}일 전',
    todayLabel: '오늘',
    yesterdayLabel: '어제',
    noticeUrgentLabel: '긴급',
    noticeCampaignLabel: '캠페인',
    noticeKeyPointsTitle: '주요 안내',
    viewOriginalButton: '원문 보기',
    launchFailedMessage: '열 수 없어요',
    categoryLogistics: '물류',
    categoryElectrical: '전기',
    categoryWoodworking: '목공',
    categoryWelding: '용접',
    categoryPress: '프레스',
    signageSubtitle: '현장에 붙는 안전 표지판을 찾아보세요',
    signTypeWarning: '경고',
    signTypeMandatory: '지시',
    signTypeProhibition: '금지',
    signPlaceLabel: '붙는 곳',
    signHazardLabel: '위험',
    listenLabel: '음성으로 듣기',
    ttsUnavailableMessage: '이 언어의 음성을 사용할 수 없습니다',
    managerTitle: '현장 관리자',
    phoneLabel: '전화번호',
    locationLabel: '위치',
    workHoursLabel: '근무 시간',
    callButton: '전화 걸기',
    messageLabel: '문자 보내기',
    historyCountTemplate: '지금까지 {count}건 분석',
    filterAllLabel: '전체',
    levelDangerLabel: '위험',
    levelCautionLabel: '주의',
    levelMandatoryLabel: '필수',
    noFilteredHistoryMessage: '해당하는 기록이 없어요',
    appSlogan: '일 할때도 안전하게',
  );

  static const en = AppLanguage._(
    code: 'en',
    label: 'English',
    englishName: 'English',
    flag: '🇺🇸',
    promptName: 'English',
    unknownLabel: 'Unknown',
    managerNotice:
        'Always check with your on-site manager before operating equipment.',
    retakeButton: 'Retake',
    homeLabel: 'Home',
    viewRecordButton: 'View Record',
    confirmButton: 'OK',
    cancelButton: 'Cancel',
    deleteButton: 'Delete',
    closeLabel: 'Close',
    shareLabel: 'Share',
    hazardsTitle: 'Watch Out for These',
    ppeTitle: 'Always Wear These',
    prohibitedTitle: "Don't Do This",
    analysisResultTitle: 'Analysis Result',
    askManagerButton: 'Ask a Manager How to Use',
    cameraLabel: 'Camera',
    signageLabel: 'Signs',
    historyTabLabel: 'History',
    historyLabel: 'History',
    menuLabel: 'Menu',
    languageSettingsLabel: 'Language',
    languagePickerTitle: 'Choose Language',
    languagePickerSubtitle:
        'All app text and analysis results switch to this language right away',
    languageNames: {
      'ko': 'Korean',
      'en': 'English',
      'vi': 'Vietnamese',
      'km': 'Khmer',
      'ne': 'Nepali',
      'th': 'Thai',
    },
    howToUseLabel: 'How to Use',
    howToUseSteps: [
      'Tap the camera button in the middle and take a photo of the item',
      'AI tells you what it is and how to stay safe',
      'You can see it again in the History tab',
    ],
    appInfoLabel: 'App Info',
    appDescription:
        'A safety information app for foreign workers in smart manufacturing',
    clearHistoryLabel: 'Delete All Records',
    clearHistoryConfirmMessage:
        'Delete all records?\nSaved photos will be deleted too.',
    historyClearedMessage: 'All records deleted',
    appSettingsSection: 'App Settings',
    dataAccountSection: 'Data · Account',
    employeeNumberTemplate: 'Employee No. {number}',
    duplicateDialogTitle: 'Duplicate Photo',
    duplicateDialogBodyTemplate:
        'You already have a record of this item today.\n\nItem name = {name}',
    noHistoryMessage: 'No records yet',
    noCameraMessage:
        'No camera available.\nPlease run on a physical device (USB connected).',
    cameraInitErrorTemplate:
        'Camera initialization failed: {error}\nPlease check that permission was granted.',
    cameraOverlayHint: 'Frame the item on screen and take a photo',
    analyzingText: 'Analyzing...',
    captureFailedPrefix: 'Capture failed: ',
    galleryLabel: 'Choose Photo',
    switchCameraLabel: 'Switch Camera',
    errorNoApiKey: 'Recognition failed (missing API key)',
    errorServerBusy: 'The server is busy. Please try again in a moment.',
    errorStatusCodeTemplate: 'Recognition failed (status code: {code})',
    errorGeneric: 'Recognition failed',
    errorNetworkOrApi: 'Recognition failed (network or API error)',
    greetingTemplate: 'Hi {name},\nstay safe today',
    searchPlaceholder: 'Search equipment and signs',
    noSearchResultMessage: 'No results found',
    safetyNoticeTitle: 'Safety Notices',
    recentAnalysisTitle: 'Recent Analysis',
    viewAllButton: 'View All',
    notificationsLabel: 'Notifications',
    daysAgoTemplate: '{n} days ago',
    todayLabel: 'Today',
    yesterdayLabel: 'Yesterday',
    noticeUrgentLabel: 'Urgent',
    noticeCampaignLabel: 'Campaign',
    noticeKeyPointsTitle: 'Key Points',
    viewOriginalButton: 'View Original',
    launchFailedMessage: "Couldn't open it",
    categoryLogistics: 'Logistics',
    categoryElectrical: 'Electrical',
    categoryWoodworking: 'Woodworking',
    categoryWelding: 'Welding',
    categoryPress: 'Press',
    signageSubtitle: 'Look up the safety signs used on site',
    signTypeWarning: 'Warning',
    signTypeMandatory: 'Mandatory',
    signTypeProhibition: 'Prohibited',
    signPlaceLabel: 'Found at',
    signHazardLabel: 'Hazard',
    listenLabel: 'Listen',
    ttsUnavailableMessage: 'Voice for this language is not available',
    managerTitle: 'On-site Manager',
    phoneLabel: 'Phone',
    locationLabel: 'Location',
    workHoursLabel: 'Working Hours',
    callButton: 'Call',
    messageLabel: 'Send Message',
    historyCountTemplate: '{count} analyzed so far',
    filterAllLabel: 'All',
    levelDangerLabel: 'Danger',
    levelCautionLabel: 'Caution',
    levelMandatoryLabel: 'Required',
    noFilteredHistoryMessage: 'No matching records',
    appSlogan: 'Safe at every job',
  );

  static const vi = AppLanguage._(
    code: 'vi',
    label: 'Tiếng Việt',
    englishName: 'Vietnamese',
    flag: '🇻🇳',
    promptName: 'Tiếng Việt (Vietnamese)',
    unknownLabel: 'Không rõ',
    managerNotice:
        'Hãy luôn hỏi quản lý hiện trường trước khi vận hành thiết bị.',
    retakeButton: 'Chụp lại',
    homeLabel: 'Trang chủ',
    viewRecordButton: 'Xem bản ghi',
    confirmButton: 'Đồng ý',
    cancelButton: 'Hủy',
    deleteButton: 'Xóa',
    closeLabel: 'Đóng',
    shareLabel: 'Chia sẻ',
    hazardsTitle: 'Có những nguy hiểm này',
    ppeTitle: 'Bắt buộc phải mang',
    prohibitedTitle: 'Không được làm điều này',
    analysisResultTitle: 'Kết quả phân tích',
    askManagerButton: 'Hỏi quản lý cách vận hành',
    cameraLabel: 'Máy ảnh',
    signageLabel: 'Biển báo',
    historyTabLabel: 'Lịch sử',
    historyLabel: 'Lịch sử gần đây',
    menuLabel: 'Menu',
    languageSettingsLabel: 'Ngôn ngữ',
    languagePickerTitle: 'Chọn ngôn ngữ',
    languagePickerSubtitle:
        'Toàn bộ nội dung ứng dụng và kết quả phân tích sẽ đổi ngay sang ngôn ngữ đã chọn',
    languageNames: {
      'ko': 'Tiếng Hàn',
      'en': 'Tiếng Anh',
      'vi': 'Tiếng Việt',
      'km': 'Tiếng Khmer',
      'ne': 'Tiếng Nepal',
      'th': 'Tiếng Thái',
    },
    howToUseLabel: 'Hướng dẫn sử dụng',
    howToUseSteps: [
      'Nhấn nút máy ảnh ở giữa và chụp ảnh vật cần kiểm tra',
      'AI cho bạn biết đó là gì và cách làm việc an toàn',
      'Bạn có thể xem lại trong tab Lịch sử',
    ],
    appInfoLabel: 'Thông tin ứng dụng',
    appDescription:
        'Ứng dụng thông tin an toàn cho lao động nước ngoài tại nhà máy thông minh',
    clearHistoryLabel: 'Xóa toàn bộ lịch sử',
    clearHistoryConfirmMessage:
        'Xóa toàn bộ bản ghi?\nẢnh đã lưu cũng sẽ bị xóa.',
    historyClearedMessage: 'Đã xóa toàn bộ bản ghi',
    appSettingsSection: 'Cài đặt ứng dụng',
    dataAccountSection: 'Dữ liệu · Tài khoản',
    employeeNumberTemplate: 'Mã nhân viên {number}',
    duplicateDialogTitle: 'Trùng lặp ảnh chụp',
    duplicateDialogBodyTemplate:
        'Hôm nay bạn đã chụp vật này rồi.\n\nTên thiết bị = {name}',
    noHistoryMessage: 'Chưa có bản ghi nào',
    noCameraMessage:
        'Không có camera khả dụng.\nVui lòng chạy trên thiết bị thật (kết nối USB).',
    cameraInitErrorTemplate:
        'Khởi tạo camera thất bại: {error}\nVui lòng kiểm tra quyền truy cập đã được cấp chưa.',
    cameraOverlayHint: 'Đưa vật cần kiểm tra vào màn hình rồi chụp',
    analyzingText: 'Đang phân tích...',
    captureFailedPrefix: 'Chụp ảnh thất bại: ',
    galleryLabel: 'Chọn ảnh',
    switchCameraLabel: 'Đổi camera',
    errorNoApiKey: 'Nhận diện thất bại (thiếu khóa API)',
    errorServerBusy: 'Máy chủ đang quá tải. Vui lòng thử lại sau.',
    errorStatusCodeTemplate: 'Nhận diện thất bại (mã trạng thái: {code})',
    errorGeneric: 'Nhận diện thất bại',
    errorNetworkOrApi: 'Nhận diện thất bại (lỗi mạng hoặc API)',
    greetingTemplate: 'Chào {name},\nhôm nay cũng an toàn nhé',
    searchPlaceholder: 'Tìm thiết bị, biển báo theo tên hoặc mô tả',
    noSearchResultMessage: 'Không có kết quả',
    safetyNoticeTitle: 'Thông báo an toàn',
    recentAnalysisTitle: 'Phân tích gần đây',
    viewAllButton: 'Xem tất cả',
    notificationsLabel: 'Thông báo',
    daysAgoTemplate: '{n} ngày trước',
    todayLabel: 'Hôm nay',
    yesterdayLabel: 'Hôm qua',
    noticeUrgentLabel: 'Khẩn cấp',
    noticeCampaignLabel: 'Chiến dịch',
    noticeKeyPointsTitle: 'Nội dung chính',
    viewOriginalButton: 'Xem bản gốc',
    launchFailedMessage: 'Không thể mở',
    categoryLogistics: 'Hậu cần',
    categoryElectrical: 'Điện',
    categoryWoodworking: 'Mộc',
    categoryWelding: 'Hàn',
    categoryPress: 'Máy ép',
    signageSubtitle: 'Tra cứu các biển báo an toàn tại hiện trường',
    signTypeWarning: 'Cảnh báo',
    signTypeMandatory: 'Bắt buộc',
    signTypeProhibition: 'Cấm',
    signPlaceLabel: 'Vị trí',
    signHazardLabel: 'Nguy cơ',
    listenLabel: 'Nghe bằng giọng nói',
    ttsUnavailableMessage: 'Không có sẵn giọng đọc cho ngôn ngữ này',
    managerTitle: 'Quản lý hiện trường',
    phoneLabel: 'Số điện thoại',
    locationLabel: 'Vị trí',
    workHoursLabel: 'Giờ làm việc',
    callButton: 'Gọi điện',
    messageLabel: 'Nhắn tin',
    historyCountTemplate: 'Đã phân tích {count} lần',
    filterAllLabel: 'Tất cả',
    levelDangerLabel: 'Nguy hiểm',
    levelCautionLabel: 'Chú ý',
    levelMandatoryLabel: 'Bắt buộc',
    noFilteredHistoryMessage: 'Không có bản ghi phù hợp',
    appSlogan: 'An toàn trong mọi công việc',
  );

  static const km = AppLanguage._(
    code: 'km',
    label: 'ភាសាខ្មែរ',
    englishName: 'Khmer',
    flag: '🇰🇭',
    promptName: 'ភាសាខ្មែរ (Khmer)',
    unknownLabel: 'មិនដឹង',
    managerNotice:
        'មុនពេលប្រើប្រាស់ឧបករណ៍ ត្រូវសួរអ្នកគ្រប់គ្រងការដ្ឋានជានិច្ច។',
    retakeButton: 'ថតម្តងទៀត',
    homeLabel: 'ទំព័រដើម',
    viewRecordButton: 'មើលកំណត់ត្រា',
    confirmButton: 'យល់ព្រម',
    cancelButton: 'បោះបង់',
    deleteButton: 'លុប',
    closeLabel: 'បិទ',
    shareLabel: 'ចែករំលែក',
    hazardsTitle: 'មានគ្រោះថ្នាក់ទាំងនេះ',
    ppeTitle: 'ត្រូវពាក់ទាំងនេះ',
    prohibitedTitle: 'កុំធ្វើការទាំងនេះ',
    analysisResultTitle: 'លទ្ធផលវិភាគ',
    askManagerButton: 'សួរអ្នកគ្រប់គ្រងពីរបៀបប្រើ',
    cameraLabel: 'កាមេរ៉ា',
    signageLabel: 'ស្លាកសញ្ញា',
    historyTabLabel: 'កំណត់ត្រា',
    historyLabel: 'កំណត់ត្រាថ្មីៗ',
    menuLabel: 'ម៉ឺនុយ',
    languageSettingsLabel: 'ភាសា',
    languagePickerTitle: 'ជ្រើសរើសភាសា',
    languagePickerSubtitle:
        'អត្ថបទទាំងអស់ និងលទ្ធផលវិភាគនឹងប្តូរទៅភាសាដែលបានជ្រើសភ្លាមៗ',
    languageNames: {
      'ko': 'ភាសាកូរ៉េ',
      'en': 'ភាសាអង់គ្លេស',
      'vi': 'ភាសាវៀតណាម',
      'km': 'ភាសាខ្មែរ',
      'ne': 'ភាសានេប៉ាល់',
      'th': 'ភាសាថៃ',
    },
    howToUseLabel: 'របៀបប្រើ',
    howToUseSteps: [
      'ចុចប៊ូតុងកាមេរ៉ានៅកណ្តាល ហើយថតរូបវត្ថុ',
      'AI នឹងប្រាប់អ្នកថាវាជាអ្វី និងរបៀបធ្វើការឱ្យមានសុវត្ថិភាព',
      'អ្នកអាចមើលម្តងទៀតនៅផ្ទាំងកំណត់ត្រា',
    ],
    appInfoLabel: 'ព័ត៌មានកម្មវិធី',
    appDescription:
        'កម្មវិធីព័ត៌មានសុវត្ថិភាពសម្រាប់កម្មករបរទេសក្នុងរោងចក្រឆ្លាតវៃ',
    clearHistoryLabel: 'លុបកំណត់ត្រាទាំងអស់',
    clearHistoryConfirmMessage:
        'លុបកំណត់ត្រាទាំងអស់?\nរូបថតដែលបានរក្សាទុកក៏នឹងត្រូវលុបដែរ។',
    historyClearedMessage: 'បានលុបកំណត់ត្រាទាំងអស់',
    appSettingsSection: 'ការកំណត់កម្មវិធី',
    dataAccountSection: 'ទិន្នន័យ · គណនី',
    employeeNumberTemplate: 'លេខបុគ្គលិក {number}',
    duplicateDialogTitle: 'ថតស្ទួន',
    duplicateDialogBodyTemplate:
        'ថ្ងៃនេះអ្នកបានថតវត្ថុនេះរួចហើយ។\n\nឈ្មោះឧបករណ៍ = {name}',
    noHistoryMessage: 'មិនទាន់មានកំណត់ត្រានៅឡើយ',
    noCameraMessage:
        'គ្មានកាមេរ៉ាដែលអាចប្រើបាន។\nសូមដំណើរការលើឧបករណ៍ពិត (ភ្ជាប់ USB)។',
    cameraInitErrorTemplate:
        'ចាប់ផ្តើមកាមេរ៉ាបរាជ័យ: {error}\nសូមពិនិត្យថាបានអនុញ្ញាតសិទ្ធិហើយ។',
    cameraOverlayHint: 'ដាក់វត្ថុដែលចង់ដឹងក្នុងអេក្រង់ ហើយថត',
    analyzingText: 'កំពុងវិភាគ...',
    captureFailedPrefix: 'ថតបរាជ័យ: ',
    galleryLabel: 'ជ្រើសរូបថត',
    switchCameraLabel: 'ប្តូរកាមេរ៉ា',
    errorNoApiKey: 'ស្គាល់បរាជ័យ (គ្មានសោ API)',
    errorServerBusy: 'ម៉ាស៊ីនមេរវល់។ សូមព្យាយាមម្តងទៀតបន្តិចក្រោយ',
    errorStatusCodeTemplate: 'ស្គាល់បរាជ័យ (លេខកូដស្ថានភាព: {code})',
    errorGeneric: 'ស្គាល់បរាជ័យ',
    errorNetworkOrApi: 'ស្គាល់បរាជ័យ (បញ្ហាបណ្តាញ ឬ API)',
    greetingTemplate: 'សួស្តី {name}\nថ្ងៃនេះក៏ត្រូវមានសុវត្ថិភាព',
    searchPlaceholder: 'ស្វែងរកឧបករណ៍ និងស្លាកសញ្ញា',
    noSearchResultMessage: 'រកមិនឃើញលទ្ធផល',
    safetyNoticeTitle: 'សេចក្តីជូនដំណឹងសុវត្ថិភាព',
    recentAnalysisTitle: 'ការវិភាគថ្មីៗ',
    viewAllButton: 'មើលទាំងអស់',
    notificationsLabel: 'ការជូនដំណឹង',
    daysAgoTemplate: '{n} ថ្ងៃមុន',
    todayLabel: 'ថ្ងៃនេះ',
    yesterdayLabel: 'ម្សិលមិញ',
    noticeUrgentLabel: 'បន្ទាន់',
    noticeCampaignLabel: 'យុទ្ធនាការ',
    noticeKeyPointsTitle: 'ចំណុចសំខាន់',
    viewOriginalButton: 'មើលឯកសារដើម',
    launchFailedMessage: 'មិនអាចបើកបានទេ',
    categoryLogistics: 'ដឹកជញ្ជូន',
    categoryElectrical: 'អគ្គិសនី',
    categoryWoodworking: 'ជាងឈើ',
    categoryWelding: 'ផ្សារ',
    categoryPress: 'ម៉ាស៊ីនសង្កត់',
    signageSubtitle: 'ស្វែងរកស្លាកសញ្ញាសុវត្ថិភាពនៅការដ្ឋាន',
    signTypeWarning: 'ព្រមាន',
    signTypeMandatory: 'បង្គាប់',
    signTypeProhibition: 'ហាមឃាត់',
    signPlaceLabel: 'ទីតាំង',
    signHazardLabel: 'គ្រោះថ្នាក់',
    listenLabel: 'ស្តាប់ជាសំឡេង',
    ttsUnavailableMessage: 'មិនមានសំឡេងសម្រាប់ភាសានេះទេ',
    managerTitle: 'អ្នកគ្រប់គ្រងការដ្ឋាន',
    phoneLabel: 'លេខទូរស័ព្ទ',
    locationLabel: 'ទីតាំង',
    workHoursLabel: 'ម៉ោងធ្វើការ',
    callButton: 'ហៅទូរស័ព្ទ',
    messageLabel: 'ផ្ញើសារ',
    historyCountTemplate: 'បានវិភាគ {count} ដង',
    filterAllLabel: 'ទាំងអស់',
    levelDangerLabel: 'គ្រោះថ្នាក់',
    levelCautionLabel: 'ប្រុងប្រយ័ត្ន',
    levelMandatoryLabel: 'ចាំបាច់',
    noFilteredHistoryMessage: 'គ្មានកំណត់ត្រាដែលត្រូវគ្នា',
    appSlogan: 'ធ្វើការដោយសុវត្ថិភាព',
  );

  static const ne = AppLanguage._(
    code: 'ne',
    label: 'नेपाली',
    englishName: 'Nepali',
    flag: '🇳🇵',
    promptName: 'नेपाली (Nepali)',
    unknownLabel: 'थाहा छैन',
    managerNotice: 'उपकरण चलाउनु अघि सधैं साइट प्रबन्धकसँग सोध्नुहोस्।',
    retakeButton: 'फेरि खिच्नुहोस्',
    homeLabel: 'गृह',
    viewRecordButton: 'रेकर्ड हेर्नुहोस्',
    confirmButton: 'ठीक छ',
    cancelButton: 'रद्द गर्नुहोस्',
    deleteButton: 'मेटाउनुहोस्',
    closeLabel: 'बन्द गर्नुहोस्',
    shareLabel: 'सेयर गर्नुहोस्',
    hazardsTitle: 'यी खतराहरू छन्',
    ppeTitle: 'यी अनिवार्य लगाउनुहोस्',
    prohibitedTitle: 'यो नगर्नुहोस्',
    analysisResultTitle: 'विश्लेषण नतिजा',
    askManagerButton: 'प्रबन्धकसँग चलाउने तरिका सोध्नुहोस्',
    cameraLabel: 'क्यामेरा',
    signageLabel: 'चिन्हहरू',
    historyTabLabel: 'रेकर्ड',
    historyLabel: 'हालका रेकर्ड',
    menuLabel: 'मेनु',
    languageSettingsLabel: 'भाषा',
    languagePickerTitle: 'भाषा छान्नुहोस्',
    languagePickerSubtitle:
        'छानिएको भाषामा एपका सबै शब्द र विश्लेषण नतिजा तुरुन्तै बदलिन्छन्',
    languageNames: {
      'ko': 'कोरियाली',
      'en': 'अंग्रेजी',
      'vi': 'भियतनामी',
      'km': 'खमेर',
      'ne': 'नेपाली',
      'th': 'थाई',
    },
    howToUseLabel: 'प्रयोग गर्ने तरिका',
    howToUseSteps: [
      'बीचको क्यामेरा बटन थिचेर वस्तुको फोटो खिच्नुहोस्',
      'AI ले त्यो के हो र सुरक्षित कसरी काम गर्ने भनेर बताउँछ',
      'रेकर्ड ट्याबमा फेरि हेर्न सकिन्छ',
    ],
    appInfoLabel: 'एप जानकारी',
    appDescription:
        'स्मार्ट कारखानाका विदेशी कामदारहरूका लागि सुरक्षा जानकारी एप',
    clearHistoryLabel: 'सबै रेकर्ड मेटाउनुहोस्',
    clearHistoryConfirmMessage:
        'सबै रेकर्ड मेटाउने हो?\nसुरक्षित फोटोहरू पनि मेटिन्छन्।',
    historyClearedMessage: 'सबै रेकर्ड मेटाइयो',
    appSettingsSection: 'एप सेटिङ',
    dataAccountSection: 'डाटा · खाता',
    employeeNumberTemplate: 'कर्मचारी नं. {number}',
    duplicateDialogTitle: 'दोहोरो फोटो',
    duplicateDialogBodyTemplate:
        'आज यो वस्तुको फोटो पहिले नै खिचिसकिएको छ।\n\nउपकरणको नाम = {name}',
    noHistoryMessage: 'अहिलेसम्म कुनै रेकर्ड छैन',
    noCameraMessage:
        'प्रयोग गर्न मिल्ने क्यामेरा छैन।\nवास्तविक उपकरणमा (USB जोडेर) चलाउनुहोस्।',
    cameraInitErrorTemplate:
        'क्यामेरा सुरु गर्न सकिएन: {error}\nअनुमति दिनुभएको छ कि जाँच गर्नुहोस्।',
    cameraOverlayHint: 'जान्न चाहेको वस्तु स्क्रिनमा राखेर फोटो खिच्नुहोस्',
    analyzingText: 'विश्लेषण हुँदैछ...',
    captureFailedPrefix: 'फोटो खिच्न सकिएन: ',
    galleryLabel: 'फोटो छान्नुहोस्',
    switchCameraLabel: 'क्यामेरा बदल्नुहोस्',
    errorNoApiKey: 'पहिचान असफल (API कुञ्जी छैन)',
    errorServerBusy: 'सर्भर व्यस्त छ। केही बेरपछि फेरि प्रयास गर्नुहोस्',
    errorStatusCodeTemplate: 'पहिचान असफल (स्थिति कोड: {code})',
    errorGeneric: 'पहिचान असफल',
    errorNetworkOrApi: 'पहिचान असफल (नेटवर्क वा API त्रुटि)',
    greetingTemplate: 'नमस्ते {name},\nआज पनि सुरक्षित रहनुहोस्',
    searchPlaceholder: 'नाम वा विवरणले उपकरण·चिन्ह खोज्नुहोस्',
    noSearchResultMessage: 'कुनै नतिजा भेटिएन',
    safetyNoticeTitle: 'सुरक्षा सूचना',
    recentAnalysisTitle: 'हालको विश्लेषण',
    viewAllButton: 'सबै हेर्नुहोस्',
    notificationsLabel: 'सूचनाहरू',
    daysAgoTemplate: '{n} दिन अघि',
    todayLabel: 'आज',
    yesterdayLabel: 'हिजो',
    noticeUrgentLabel: 'जरुरी',
    noticeCampaignLabel: 'अभियान',
    noticeKeyPointsTitle: 'मुख्य बुँदाहरू',
    viewOriginalButton: 'मूल सूचना हेर्नुहोस्',
    launchFailedMessage: 'खोल्न सकिएन',
    categoryLogistics: 'ढुवानी',
    categoryElectrical: 'बिजुली',
    categoryWoodworking: 'काठको काम',
    categoryWelding: 'वेल्डिङ',
    categoryPress: 'प्रेस',
    signageSubtitle: 'कार्यस्थलमा राखिएका सुरक्षा चिन्हहरू खोज्नुहोस्',
    signTypeWarning: 'चेतावनी',
    signTypeMandatory: 'अनिवार्य',
    signTypeProhibition: 'निषेध',
    signPlaceLabel: 'राखिने ठाउँ',
    signHazardLabel: 'खतरा',
    listenLabel: 'आवाजमा सुन्नुहोस्',
    ttsUnavailableMessage: 'यो भाषाको आवाज उपलब्ध छैन',
    managerTitle: 'साइट प्रबन्धक',
    phoneLabel: 'फोन नम्बर',
    locationLabel: 'स्थान',
    workHoursLabel: 'काम गर्ने समय',
    callButton: 'फोन गर्नुहोस्',
    messageLabel: 'सन्देश पठाउनुहोस्',
    historyCountTemplate: 'अहिलेसम्म {count} पटक विश्लेषण',
    filterAllLabel: 'सबै',
    levelDangerLabel: 'खतरा',
    levelCautionLabel: 'सावधान',
    levelMandatoryLabel: 'अनिवार्य',
    noFilteredHistoryMessage: 'मिल्ने रेकर्ड छैन',
    appSlogan: 'काममा पनि सुरक्षित',
  );

  static const th = AppLanguage._(
    code: 'th',
    label: 'ภาษาไทย',
    englishName: 'Thai',
    flag: '🇹🇭',
    promptName: 'ภาษาไทย (Thai)',
    unknownLabel: 'ไม่ทราบ',
    managerNotice: 'ก่อนใช้งานอุปกรณ์ ต้องสอบถามผู้จัดการหน้างานทุกครั้ง',
    retakeButton: 'ถ่ายใหม่',
    homeLabel: 'หน้าหลัก',
    viewRecordButton: 'ดูบันทึก',
    confirmButton: 'ตกลง',
    cancelButton: 'ยกเลิก',
    deleteButton: 'ลบ',
    closeLabel: 'ปิด',
    shareLabel: 'แชร์',
    hazardsTitle: 'มีอันตรายเหล่านี้',
    ppeTitle: 'ต้องสวมใส่สิ่งเหล่านี้',
    prohibitedTitle: 'ห้ามทำสิ่งนี้',
    analysisResultTitle: 'ผลการวิเคราะห์',
    askManagerButton: 'ถามผู้จัดการวิธีใช้งาน',
    cameraLabel: 'กล้อง',
    signageLabel: 'ป้าย',
    historyTabLabel: 'บันทึก',
    historyLabel: 'บันทึกล่าสุด',
    menuLabel: 'เมนู',
    languageSettingsLabel: 'ภาษา',
    languagePickerTitle: 'เลือกภาษา',
    languagePickerSubtitle:
        'ข้อความทั้งหมดในแอปและผลการวิเคราะห์จะเปลี่ยนเป็นภาษาที่เลือกทันที',
    languageNames: {
      'ko': 'ภาษาเกาหลี',
      'en': 'ภาษาอังกฤษ',
      'vi': 'ภาษาเวียดนาม',
      'km': 'ภาษาเขมร',
      'ne': 'ภาษาเนปาล',
      'th': 'ภาษาไทย',
    },
    howToUseLabel: 'วิธีใช้งาน',
    howToUseSteps: [
      'กดปุ่มกล้องตรงกลางแล้วถ่ายรูปสิ่งของ',
      'AI จะบอกว่าสิ่งนั้นคืออะไรและทำงานอย่างไรให้ปลอดภัย',
      'ดูย้อนหลังได้ที่แท็บบันทึก',
    ],
    appInfoLabel: 'ข้อมูลแอป',
    appDescription: 'แอปข้อมูลความปลอดภัยสำหรับแรงงานต่างชาติในโรงงานอัจฉริยะ',
    clearHistoryLabel: 'ลบบันทึกทั้งหมด',
    clearHistoryConfirmMessage:
        'ลบบันทึกทั้งหมดหรือไม่?\nรูปภาพที่บันทึกไว้จะถูกลบด้วย',
    historyClearedMessage: 'ลบบันทึกทั้งหมดแล้ว',
    appSettingsSection: 'ตั้งค่าแอป',
    dataAccountSection: 'ข้อมูล · บัญชี',
    employeeNumberTemplate: 'รหัสพนักงาน {number}',
    duplicateDialogTitle: 'ถ่ายซ้ำ',
    duplicateDialogBodyTemplate:
        'วันนี้คุณถ่ายสิ่งนี้ไปแล้ว\n\nชื่ออุปกรณ์ = {name}',
    noHistoryMessage: 'ยังไม่มีบันทึก',
    noCameraMessage:
        'ไม่มีกล้องที่ใช้งานได้\nกรุณาใช้งานบนอุปกรณ์จริง (เชื่อมต่อ USB)',
    cameraInitErrorTemplate:
        'เปิดกล้องไม่สำเร็จ: {error}\nกรุณาตรวจสอบว่าอนุญาตสิทธิ์แล้ว',
    cameraOverlayHint: 'จัดสิ่งที่อยากรู้ให้อยู่ในจอแล้วถ่ายรูป',
    analyzingText: 'กำลังวิเคราะห์...',
    captureFailedPrefix: 'ถ่ายรูปไม่สำเร็จ: ',
    galleryLabel: 'เลือกรูปภาพ',
    switchCameraLabel: 'สลับกล้อง',
    errorNoApiKey: 'จดจำไม่สำเร็จ (ไม่มีคีย์ API)',
    errorServerBusy: 'เซิร์ฟเวอร์ไม่ว่าง กรุณาลองใหม่อีกครั้ง',
    errorStatusCodeTemplate: 'จดจำไม่สำเร็จ (รหัสสถานะ: {code})',
    errorGeneric: 'จดจำไม่สำเร็จ',
    errorNetworkOrApi: 'จดจำไม่สำเร็จ (เครือข่ายหรือ API ผิดพลาด)',
    greetingTemplate: 'สวัสดี {name}\nวันนี้ก็ทำงานอย่างปลอดภัยนะ',
    searchPlaceholder: 'ค้นหาอุปกรณ์·ป้ายด้วยชื่อหรือคำอธิบาย',
    noSearchResultMessage: 'ไม่พบผลการค้นหา',
    safetyNoticeTitle: 'ประกาศความปลอดภัย',
    recentAnalysisTitle: 'การวิเคราะห์ล่าสุด',
    viewAllButton: 'ดูทั้งหมด',
    notificationsLabel: 'การแจ้งเตือน',
    daysAgoTemplate: '{n} วันที่แล้ว',
    todayLabel: 'วันนี้',
    yesterdayLabel: 'เมื่อวาน',
    noticeUrgentLabel: 'ด่วน',
    noticeCampaignLabel: 'แคมเปญ',
    noticeKeyPointsTitle: 'ประเด็นสำคัญ',
    viewOriginalButton: 'ดูต้นฉบับ',
    launchFailedMessage: 'เปิดไม่ได้',
    categoryLogistics: 'โลจิสติกส์',
    categoryElectrical: 'ไฟฟ้า',
    categoryWoodworking: 'งานไม้',
    categoryWelding: 'งานเชื่อม',
    categoryPress: 'เครื่องกด',
    signageSubtitle: 'ค้นหาป้ายความปลอดภัยที่ติดในหน้างาน',
    signTypeWarning: 'เตือน',
    signTypeMandatory: 'บังคับ',
    signTypeProhibition: 'ห้าม',
    signPlaceLabel: 'ติดที่',
    signHazardLabel: 'อันตราย',
    listenLabel: 'ฟังเสียง',
    ttsUnavailableMessage: 'ไม่มีเสียงสำหรับภาษานี้',
    managerTitle: 'ผู้จัดการหน้างาน',
    phoneLabel: 'เบอร์โทรศัพท์',
    locationLabel: 'สถานที่',
    workHoursLabel: 'เวลาทำงาน',
    callButton: 'โทร',
    messageLabel: 'ส่งข้อความ',
    historyCountTemplate: 'วิเคราะห์แล้ว {count} ครั้ง',
    filterAllLabel: 'ทั้งหมด',
    levelDangerLabel: 'อันตราย',
    levelCautionLabel: 'ระวัง',
    levelMandatoryLabel: 'บังคับ',
    noFilteredHistoryMessage: 'ไม่มีบันทึกที่ตรงกัน',
    appSlogan: 'ทำงานอย่างปลอดภัย',
  );

  static const all = [ko, en, vi, km, ne, th];

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
