import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../demo_account.dart';
import '../language_service.dart';
import 'main_tab_screen.dart';

/// 스플래시 다음에 뜨는 로그인 화면.
///
/// 시연 단계라 서버 인증 없이 [DemoAccount] 와 입력을 비교하기만 한다.
/// 성공하면 pushReplacement 로 홈에 넘겨서 뒤로가기로 돌아오지 못하게 한다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  /// 실패 문구를 띄울지 여부. 다시 입력하기 시작하면 지운다.
  bool _showError = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_showError) setState(() => _showError = false);
  }

  void _submit() {
    if (!DemoAccount.matches(_idController.text, _passwordController.text)) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainTabScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // 언어 설정은 main() 에서 첫 프레임 전에 불러오므로 저장된 언어로 뜬다.
    final language = LanguageService.instance.current;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 56,
                  color: AppColors.accentDark,
                ),
                const SizedBox(height: 12),
                Text(
                  'WorkSafe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.accentDark,
                  ),
                ),
                const SizedBox(height: 36),
                TextField(
                  controller: _idController,
                  onChanged: (_) => _clearError(),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                  autocorrect: false,
                  decoration: _fieldDecoration(
                    label: language.loginIdLabel,
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  onChanged: (_) => _clearError(),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: _fieldDecoration(
                    label: language.loginPasswordLabel,
                    icon: Icons.lock_outline,
                  ),
                ),
                const SizedBox(height: 12),
                // 실패했을 때만 문구를 채운다. 자리를 항상 잡아두면 문구가 뜰 때
                // 아래 버튼이 밀려 내려가지 않는다.
                SizedBox(
                  height: 20,
                  child: _showError
                      ? Text(
                          language.loginFailedMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red.shade700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    language.loginButton,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.accentDark),
      prefixIcon: Icon(icon, color: AppColors.accent),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.accentBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
