/// 시연용 고정 계정.
///
/// 실제 인증 서버가 없는 단계라, 로그인 화면은 이 값과 입력을 그대로 비교한다.
/// 계정을 바꿀 일이 있으면 이 파일만 고치면 된다.
///
/// 주의: 값이 앱에 그대로 박히므로 실제 계정은 절대 여기에 두지 않는다.
/// 서버 인증이 붙으면 [matches] 를 API 호출로 바꾸고 이 상수들은 지운다.
class DemoAccount {
  DemoAccount._();

  static const id = 'worksafe';
  static const password = '1234';

  /// 앞뒤 공백은 오타로 보고 무시한다(모바일 키보드 자동 공백 대비).
  static bool matches(String inputId, String inputPassword) {
    return inputId.trim() == id && inputPassword.trim() == password;
  }
}
