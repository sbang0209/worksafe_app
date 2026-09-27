import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../demo_manager.dart';
import '../language_service.dart';
import '../result_localization.dart';
import '../widgets/common.dart';

/// 현장 관리자 연락처 화면. 분석 결과의 "관리자에게 작동법 확인" 버튼으로 연다.
/// 표시값은 [DemoManager] 목업이다.
class ManagerScreen extends StatelessWidget {
  const ManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenTopBar(
              title: language.managerTitle,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          color: AppColors.brandTintBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 48,
                          color: AppColors.brand,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      DemoManager.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resolveLocalizedText(DemoManager.role, language),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resolveLocalizedText(DemoManager.department, language),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _ContactRow(
                            icon: Icons.phone_outlined,
                            label: language.phoneLabel,
                            value: DemoManager.phoneDisplay,
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ContactRow(
                            icon: Icons.location_on_outlined,
                            label: language.locationLabel,
                            value: resolveLocalizedText(
                              DemoManager.location,
                              language,
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.divider),
                          _ContactRow(
                            icon: Icons.schedule,
                            label: language.workHoursLabel,
                            value: resolveLocalizedText(
                              DemoManager.workHours,
                              language,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.brandTintBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.brand,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              language.managerNotice,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomActionBar(
              secondaryIcon: Icons.chat_bubble_outline,
              secondaryTooltip: language.messageLabel,
              onSecondary: () => launchExternal(
                context,
                Uri(scheme: 'sms', path: DemoManager.phone),
              ),
              primaryIcon: Icons.phone_outlined,
              primaryLabel: language.callButton,
              onPrimary: () => launchExternal(
                context,
                Uri(scheme: 'tel', path: DemoManager.phone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          IconChip(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
