import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../language_service.dart';
import '../result_localization.dart';
import '../signage_data.dart';
import '../tts_service.dart';
import 'common.dart';
import 'signage_image.dart';

/// 표지판 종류별 태그·그림 배경색.
extension SignTypeStyle on SignType {
  Color get color => switch (this) {
    SignType.warning => AppColors.warning,
    SignType.mandatory => AppColors.mandatory,
    SignType.prohibition => AppColors.danger,
  };

  Color get background => switch (this) {
    SignType.warning => AppColors.warningBg,
    SignType.mandatory => AppColors.mandatoryBg,
    SignType.prohibition => AppColors.dangerBg,
  };
}

/// 표지판 상세 바텀시트를 연다. 닫히면(어떤 방식이든) 읽던 음성도 멈춘다.
/// 표지판 탭과 검색 화면에서 쓴다.
Future<void> showSignageSheet(BuildContext context, Signage signage) {
  // 다른 표지판을 열 때 이전에 재생 중이던 음성을 멈춘다.
  TtsService.instance.stop();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => _SignageSheet(signage: signage),
  ).whenComplete(TtsService.instance.stop);
}

class _SignageSheet extends StatelessWidget {
  const _SignageSheet({required this.signage});

  final Signage signage;

  /// 표지판의 "이름 + 설명"을 현재 언어의 음성으로 읽는다.
  Future<void> _speak(BuildContext context, AppLanguage language) async {
    final text = '${signage.name(language)}. ${signage.description(language)}';
    final started = await TtsService.instance.speak(text, language);
    if (!started && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.ttsUnavailableMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final type = signage.type;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: type.background,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: SignageImage(
                            icon: signage.icon,
                            color: signage.color,
                            assetPath: signage.imageAsset,
                            iconSize: 44,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ColorTag(
                                label:
                                    '${signTypeName(type, language)} · '
                                    '${categoryName(signage.category, language)}',
                                color: type.color,
                                background: type.background,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                signage.name(language),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        signage.description(language),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.55,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoLine(
                      icon: Icons.monitor_heart_outlined,
                      iconColor: AppColors.brand,
                      iconBackground: AppColors.brandTintBg,
                      label: language.signPlaceLabel,
                      value: resolveLocalizedText(signage.place, language),
                    ),
                    const SizedBox(height: 10),
                    _InfoLine(
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppColors.danger,
                      iconBackground: AppColors.dangerBg,
                      label: language.signHazardLabel,
                      value: resolveLocalizedText(signage.hazard, language),
                    ),
                  ],
                ),
              ),
            ),
            BottomActionBar(
              secondaryIcon: Icons.close,
              secondaryTooltip: language.closeLabel,
              onSecondary: () => Navigator.of(context).pop(),
              primaryIcon: Icons.volume_up_outlined,
              primaryLabel: language.listenLabel,
              onPrimary: () => _speak(context, language),
            ),
          ],
        ),
      ),
    );
  }
}

/// "붙는 곳 · 창고 출입구" 처럼 아이콘 칩 + 굵은 라벨 + 값 한 줄.
class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconChip(
          icon: icon,
          color: iconColor,
          background: iconBackground,
          size: 34,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: ' · $value'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
