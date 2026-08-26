import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_info.dart';
import '../history_service.dart';
import '../language_service.dart';
import 'language_settings_screen.dart';
import 'login_screen.dart';

/// 메뉴 탭. 언어 설정, 사용 방법, 앱 정보 같은 앱 전역 항목을 카드 목록으로 둔다.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _openLanguageSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LanguageSettingsScreen()));
  }

  /// 사용법을 번호가 붙은 짧은 문장으로 보여준다.
  /// 글을 오래 읽지 않아도 되게 단계마다 한 줄씩만 둔다.
  void _showHowToUse(BuildContext context, AppLanguage language) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(language.howToUseLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < language.howToUseSteps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        language.howToUseSteps[i],
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(language.confirmButton),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context, AppLanguage language) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(language.appInfoLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 56,
              color: AppColors.accentDark,
            ),
            const SizedBox(height: 12),
            Text(
              AppInfo.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.accentDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppInfo.version,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 14),
            Text(
              language.appDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(language.confirmButton),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory(
    BuildContext context,
    AppLanguage language,
  ) async {
    final shouldClear = await _confirm(
      context: context,
      title: language.clearHistoryLabel,
      message: language.clearHistoryConfirmMessage,
      actionLabel: language.deleteButton,
    );
    if (shouldClear != true) return;
    // 기록 목록과 저장된 사진 파일을 함께 지운다.
    await HistoryService.instance.clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(language.historyClearedMessage)));
  }

  Future<void> _confirmLogout(
    BuildContext context,
    AppLanguage language,
  ) async {
    final shouldLogout = await _confirm(
      context: context,
      title: language.logoutLabel,
      message: language.logoutConfirmMessage,
      actionLabel: language.logoutLabel,
    );
    if (shouldLogout != true || !context.mounted) return;
    // 쌓여 있던 화면을 모두 걷어내서, 뒤로가기로 앱 안으로 돌아올 수 없게 한다.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// 되돌릴 수 없는 동작(삭제/로그아웃) 앞에 띄우는 확인 다이얼로그.
  /// 실행 버튼은 빨간색이라 취소와 눈에 띄게 구분된다.
  Future<bool?> _confirm({
    required BuildContext context,
    required String title,
    required String message,
    required String actionLabel,
  }) {
    final language = LanguageService.instance.current;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(language.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              actionLabel,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    return Scaffold(
      appBar: AppBar(title: Text(language.menuLabel), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _MenuCard(
            icon: Icons.language,
            label: language.languageSettingsLabel,
            onTap: () => _openLanguageSettings(context),
          ),
          _MenuCard(
            icon: Icons.help_outline,
            label: language.howToUseLabel,
            onTap: () => _showHowToUse(context, language),
          ),
          _MenuCard(
            icon: Icons.info_outline,
            label: language.appInfoLabel,
            onTap: () => _showAppInfo(context, language),
          ),
          _MenuCard(
            icon: Icons.delete_outline,
            label: language.clearHistoryLabel,
            onTap: () => _confirmClearHistory(context, language),
          ),
          _MenuCard(
            icon: Icons.logout,
            label: language.logoutLabel,
            onTap: () => _confirmLogout(context, language),
            // 로그아웃만 빨간색으로 다른 항목과 구분한다.
            danger: true,
          ),
        ],
      ),
    );
  }
}

/// 메뉴 항목 하나. 흰 카드에 아이콘 + 라벨 + 오른쪽 화살표.
class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// true 면 아이콘과 글자를 빨간색으로 칠한다(되돌릴 수 없는 동작).
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red.shade700 : AppColors.accentDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1.5,
        shadowColor: AppColors.cardShadow,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: danger ? color : Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 26, color: AppColors.neutral),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
