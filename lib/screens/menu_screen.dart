import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_info.dart';
import '../demo_profile.dart';
import '../history_service.dart';
import '../language_service.dart';
import '../widgets/common.dart';
import '../widgets/language_sheet.dart';
import 'main_tab_screen.dart' show bottomNavInset;

/// 메뉴 탭. 프로필 카드 아래에 앱 설정 / 데이터·계정 항목을 묶어서 둔다.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

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
                      backgroundColor: AppColors.brand,
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
            Icon(Icons.health_and_safety, size: 56, color: AppColors.brandDark),
            const SizedBox(height: 12),
            Text(
              AppInfo.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.brandDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppInfo.version,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
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

  /// 되돌릴 수 없는 동작(기록 삭제) 앞에 띄우는 확인 다이얼로그.
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
              style: const TextStyle(color: AppColors.danger),
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
      body: SafeArea(
        bottom: false,
        child: ListView(
          // 하단 바가 떠 있어 내용이 그 뒤로 이어지므로, 끝에 바 높이만큼 여백을 둔다.
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomNavInset(context)),
          children: [
            LargeTitle(language.menuLabel),
            const SizedBox(height: 20),
            _ProfileCard(
              name: DemoProfile.name,
              employeeNumber: language.employeeNumberTemplate.replaceAll(
                '{number}',
                DemoProfile.employeeNumber,
              ),
              languageCode: language.code.toUpperCase(),
              onLanguageTap: () => showLanguageSheet(context),
            ),
            _SectionLabel(language.appSettingsSection),
            _MenuGroup(
              children: [
                _MenuRow(
                  icon: Icons.language,
                  label: language.languageSettingsLabel,
                  value: language.label,
                  iconColor: AppColors.brand,
                  iconBackground: AppColors.brandTintBg,
                  onTap: () => showLanguageSheet(context),
                ),
                _MenuRow(
                  icon: Icons.info_outline,
                  label: language.howToUseLabel,
                  onTap: () => _showHowToUse(context, language),
                ),
                _MenuRow(
                  icon: Icons.shield_outlined,
                  label: language.appInfoLabel,
                  value: AppInfo.version,
                  onTap: () => _showAppInfo(context, language),
                ),
              ],
            ),
            _SectionLabel(language.dataAccountSection),
            _MenuGroup(
              children: [
                // 되돌릴 수 없는 동작이라 글자와 아이콘을 주의 색으로 칠한다.
                _MenuRow(
                  icon: Icons.delete_outline,
                  label: language.clearHistoryLabel,
                  labelColor: AppColors.warning,
                  iconColor: AppColors.warning,
                  iconBackground: AppColors.warningBg,
                  onTap: () => _confirmClearHistory(context, language),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 연한 틸 배경의 프로필 카드. 이니셜 아바타 + 이름/사원번호 + 현재 언어 버튼.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.employeeNumber,
    required this.languageCode,
    required this.onLanguageTap,
  });

  final String name;

  /// 이미 언어별 문구로 조립된 사원번호 줄 (예: '사원번호 12345').
  final String employeeNumber;

  /// 'KO' 처럼 대문자로 보여줄 현재 언어 코드.
  final String languageCode;
  final VoidCallback onLanguageTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brandTintBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.brand,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  employeeNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.surface,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onLanguageTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language,
                      size: 16,
                      color: AppColors.brand,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      languageCode,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brand,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 28, 0, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textFaint,
        ),
      ),
    );
  }
}

/// 테두리 있는 흰 카드 하나에 여러 줄을 구분선으로 나눠 담는다.
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.divider),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// 메뉴 항목 한 줄. 아이콘 칩 + 라벨 + (현재 값) + 오른쪽 화살표.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.labelColor = AppColors.textPrimary,
    this.iconColor = AppColors.textPrimary,
    this.iconBackground = AppColors.fieldBg,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// 오른쪽에 옅게 보여줄 현재 값(예: '한국어', 'v0.1'). 없으면 화살표만.
  final String? value;
  final Color labelColor;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: labelColor,
                ),
              ),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: AppColors.textFaint),
          ],
        ),
      ),
    );
  }
}
