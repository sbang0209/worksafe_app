import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../language_service.dart';
import 'common.dart';

/// 언어 선택 바텀시트를 연다. 언어를 고르면 바로 적용하고 닫힌다.
///
/// 홈 오른쪽 위 언어 버튼, 메뉴의 프로필 카드·언어 설정, 카메라 화면에서 쓴다.
Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  Future<void> _select(BuildContext context, AppLanguage language) async {
    Navigator.of(context).pop();
    await LanguageService.instance.setLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    final current = LanguageService.instance.current;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      current.languagePickerTitle,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  RoundIconButton(
                    icon: Icons.close,
                    tooltip: current.closeLabel,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                current.languagePickerSubtitle,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              for (final language in AppLanguage.all)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _LanguageTile(
                    language: language,
                    // 지금 고른 언어는 같은 이름이 두 번 보이지 않게 영어 이름을 쓴다.
                    subtitle: language.code == current.code
                        ? language.englishName
                        : current.languageNames[language.code] ??
                              language.englishName,
                    selected: language.code == current.code,
                    onTap: () => _select(context, language),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: selected
          ? BorderSide.none
          : const BorderSide(color: AppColors.borderStrong),
    );
    return Material(
      color: selected ? AppColors.textPrimary : AppColors.surface,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(language.flag, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.label,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.brand,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 18, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
