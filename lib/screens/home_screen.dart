import 'dart:io';

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../demo_profile.dart';
import '../history_service.dart';
import '../language_service.dart';
import '../notice_data.dart';
import '../result_localization.dart';
import '../risk_level.dart';
import '../widgets/common.dart';
import '../widgets/language_sheet.dart';
import '../widgets/notice_card.dart';
import 'history_detail_screen.dart';
import 'notice_list_screen.dart';
import 'search_screen.dart';

/// 홈 탭. 인사말, 검색, 안전 공지, 최근 분석 미리보기.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onViewAllHistory});

  /// 최근 분석의 "전체 보기". 기록 탭으로 넘어간다.
  final VoidCallback onViewAllHistory;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  /// 최근 분석에 보여줄 최대 개수 (2열 x 2줄).
  static const _recentCount = 4;

  List<HistoryEntry>? _recent;

  @override
  void initState() {
    super.initState();
    reload();
  }

  /// 최근 분석을 다시 불러온다. 홈 탭으로 돌아오거나 촬영을 마쳤을 때
  /// [MainTabScreen] 이 호출한다.
  Future<void> reload() async {
    final entries = await HistoryService.instance.getAll();
    if (!mounted) return;
    setState(() => _recent = entries.take(_recentCount).toList());
  }

  void _openNotices() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NoticeListScreen()));
  }

  void _openSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final notices = safetyNotices();
    final recent = _recent;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          // 하단 바가 떠 있어 내용이 그 뒤로 이어지므로, 끝에 바 높이만큼 여백을 둔다.
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _LanguageButton(
                  label: language.label,
                  onTap: () => showLanguageSheet(context),
                ),
                const SizedBox(width: 8),
                _BellButton(
                  tooltip: language.notificationsLabel,
                  onTap: _openNotices,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              language.greetingTemplate.replaceAll('{name}', DemoProfile.name),
              style: const TextStyle(
                fontSize: 28,
                height: 1.3,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _SearchBox(hint: language.searchPlaceholder, onTap: _openSearch),
            const SizedBox(height: 28),
            SectionHeader(
              title: language.safetyNoticeTitle,
              actionLabel: language.viewAllButton,
              onAction: _openNotices,
            ),
            const SizedBox(height: 12),
            for (final notice in notices) ...[
              NoticeCard(notice: notice),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 20),
            SectionHeader(
              title: language.recentAnalysisTitle,
              actionLabel: language.viewAllButton,
              onAction: widget.onViewAllHistory,
            ),
            const SizedBox(height: 12),
            if (recent == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (recent.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  language.noHistoryMessage,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.25,
                ),
                itemCount: recent.length,
                itemBuilder: (context, index) {
                  final entry = recent[index];
                  return _RecentCard(
                    entry: entry,
                    language: language,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HistoryDetailScreen(entry: entry),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// 오른쪽 위 테두리 알약 버튼 (🌐 한국어). 누르면 언어 선택 시트.
class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const shape = StadiumBorder(
      side: BorderSide(color: AppColors.borderStrong),
    );
    return Material(
      color: AppColors.surface,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language,
                size: 20,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 새 공지가 있다는 틸색 점이 달린 종 버튼.
class _BellButton extends StatelessWidget {
  const _BellButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 28,
            color: AppColors.textPrimary,
          ),
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.brand,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 누르면 검색 화면으로 넘어가는 검색창 모양 버튼.
class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldBg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textFaint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 최근 분석 카드. 사진 위에 위험도 배지(오른쪽 위)와 이름·시각(왼쪽 아래)을 얹는다.
class _RecentCard extends StatelessWidget {
  const _RecentCard({
    required this.entry,
    required this.language,
    required this.onTap,
  });

  final HistoryEntry entry;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final risk = RiskSummary.of(entry.result);
    final day =
        relativeDayLabel(entry.timestamp, language) ?? entry.formattedDate;
    return Material(
      color: AppColors.thumbBg,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(entry.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const Icon(
                Icons.photo_camera_outlined,
                size: 40,
                color: AppColors.textFaint,
              ),
            ),
            if (risk != null)
              Positioned(
                top: 10,
                right: 10,
                child: _WhitePill(
                  child: Text(
                    '${risk.level.label(language)} ${risk.count}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: risk.level.color,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: _WhitePill(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        resolveLocalizedText(entry.result['name'], language),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$day ${entry.formattedTime}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhitePill extends StatelessWidget {
  const _WhitePill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
