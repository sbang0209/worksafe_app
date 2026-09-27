import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_colors.dart';
import '../language_service.dart';

/// 회색 원(또는 둥근 사각형) 안의 아이콘 버튼. 상단 바의 뒤로가기·공유 등에 쓴다.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 44,
    this.iconSize = 24,
    this.background = AppColors.borderStrong,
    this.foreground = AppColors.textPrimary,
    this.circle = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color background;
  final Color foreground;

  /// false 면 모서리가 둥근 사각형으로 그린다.
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final ShapeBorder shape = circle
        ? const CircleBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    final button = Material(
      color: background,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: foreground),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

/// 뒤로가기 + 가운데 제목 + (오른쪽 버튼) 상단 바.
class ScreenTopBar extends StatelessWidget {
  const ScreenTopBar({
    super.key,
    required this.onBack,
    this.title,
    this.backTooltip,
    this.trailing,
  });

  final VoidCallback onBack;
  final String? title;
  final String? backTooltip;

  /// 오른쪽 버튼. 없으면 제목이 가운데 오도록 같은 폭을 비워 둔다.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.chevron_left,
            iconSize: 28,
            tooltip: backTooltip,
            onTap: onBack,
          ),
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
          trailing ?? const SizedBox(width: 44),
        ],
      ),
    );
  }
}

/// 화면 맨 아래 고정 버튼 줄. 왼쪽 네모 보조 버튼 + 오른쪽 틸색 주요 버튼.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.secondaryIcon,
    required this.secondaryTooltip,
    required this.onSecondary,
    required this.primaryIcon,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryBackground = AppColors.borderStrong,
  });

  final IconData secondaryIcon;
  final String secondaryTooltip;
  final VoidCallback onSecondary;
  final IconData primaryIcon;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final Color secondaryBackground;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          RoundIconButton(
            icon: secondaryIcon,
            tooltip: secondaryTooltip,
            onTap: onSecondary,
            size: 56,
            iconSize: 26,
            circle: false,
            background: secondaryBackground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onPrimary,
              icon: Icon(primaryIcon),
              label: Text(
                primaryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 옅은 색 칩 안의 아이콘. 목록 줄 앞머리나 섹션 제목 앞에 쓴다.
class IconChip extends StatelessWidget {
  const IconChip({
    super.key,
    required this.icon,
    this.color = AppColors.textPrimary,
    this.background = AppColors.fieldBg,
    this.size = 38,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.55, color: color),
    );
  }
}

/// 작은 색 태그(예: "긴급", "위험 2", "경고 · 물류").
class ColorTag extends StatelessWidget {
  const ColorTag({
    super.key,
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// 큰 화면 제목(예: "최근 기록", "메뉴").
class LargeTitle extends StatelessWidget {
  const LargeTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// 알약 모양 필터 칩. 선택되면 틸 배경 + 흰 글자 (기록 필터, 표지판 카테고리).
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brand : AppColors.fieldBg,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 56),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 섹션 제목 + 오른쪽 "전체 보기" 링크.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// '**굵게**' 표시가 들어간 문장을 굵은 글씨가 섞인 TextSpan 으로 바꾼다.
TextSpan boldMarkedText(String text, TextStyle style) {
  final parts = text.split('**');
  return TextSpan(
    style: style,
    children: [
      for (var i = 0; i < parts.length; i++)
        TextSpan(
          text: parts[i],
          // 홀수 번째 조각이 ** 사이에 있던 부분이다.
          style: i.isOdd
              ? const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                )
              : null,
        ),
    ],
  );
}

/// 브라우저·전화·문자 앱을 연다. 열지 못하면 안내 스낵바를 띄운다.
Future<void> launchExternal(BuildContext context, Uri uri) async {
  var launched = false;
  try {
    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    launched = false;
  }
  if (!launched && context.mounted) {
    final language = LanguageService.instance.current;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(language.launchFailedMessage)));
  }
}

/// "오늘" / "어제" / "N일 전" 처럼 오늘과의 날짜 차이를 글로 보여준다.
/// [maxRelativeDays] 보다 오래됐으면 null — 호출한 쪽에서 날짜로 보여준다.
String? relativeDayLabel(
  DateTime time,
  AppLanguage language, {
  int maxRelativeDays = 1,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(time.year, time.month, time.day);
  final diff = today.difference(day).inDays;
  if (diff <= 0) return language.todayLabel;
  if (diff == 1 && maxRelativeDays >= 1) return language.yesterdayLabel;
  if (diff <= maxRelativeDays) {
    return language.daysAgoTemplate.replaceAll('{n}', '$diff');
  }
  return null;
}
