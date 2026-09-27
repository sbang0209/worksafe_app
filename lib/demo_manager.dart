/// 현장 관리자 화면에 표시할 시연용 관리자 정보.
///
/// 아직 실제 관리자 데이터가 없어서 목업 고정값을 쓴다. 전화번호·위치 등을
/// 바꿀 일이 있으면 이 파일만 고치면 된다. 언어별 문구는 ko/en/vi 만 두고,
/// 다른 언어는 [resolveLocalizedText] 가 영어로 대체한다.
class DemoManager {
  DemoManager._();

  /// 이름은 고유명사라 번역하지 않는다.
  static const name = '김현장';

  /// 전화/문자 앱에 넘길 번호. 화면에는 [phoneDisplay] 를 보여준다.
  static const phone = '01012345678';
  static const phoneDisplay = '010-1234-5678';

  static const role = {
    'ko': '현장 안전관리자',
    'en': 'Site Safety Manager',
    'vi': 'Quản lý an toàn hiện trường',
  };

  static const department = {
    'ko': '제1공장 · 생산팀',
    'en': 'Plant 1 · Production Team',
    'vi': 'Nhà máy 1 · Đội sản xuất',
  };

  static const location = {
    'ko': '제1공장 2층 관리사무실',
    'en': 'Plant 1, 2F Management Office',
    'vi': 'Văn phòng quản lý tầng 2, Nhà máy 1',
  };

  static const workHours = {
    'ko': '평일 08:00 - 18:00',
    'en': 'Weekdays 08:00 - 18:00',
    'vi': 'Ngày thường 08:00 - 18:00',
  };
}
