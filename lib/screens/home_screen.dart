import 'dart:async';

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../demo_profile.dart';
import '../language_service.dart';
import '../signage_data.dart';
import '../widgets/signage_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const _rotationInterval = Duration(seconds: 8);

  int _messageIndex = 0;
  Timer? _messageTimer;
  SignageCategory _selectedCategory = SignageCategory.values.first;

  @override
  void initState() {
    super.initState();
    _messageTimer = Timer.periodic(_rotationInterval, (_) {
      final language = LanguageService.instance.current;
      setState(() {
        _messageIndex = (_messageIndex + 1) % language.safetyMessages.length;
      });
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _selectCategory(SignageCategory category) {
    setState(() => _selectedCategory = category);
  }

  void _openSignageDialog(Signage signage) {
    final language = LanguageService.instance.current;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 180,
              child: SignageImage(
                icon: signage.icon,
                color: signage.color,
                assetPath: signage.imageAsset,
                iconSize: 56,
                borderRadius: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              signage.name(language),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              signage.description(language),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(language.confirmButton),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final messages = language.safetyMessages;
    final messageIndex = _messageIndex % messages.length;
    final signageItems = signageForCategory(_selectedCategory);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileNoticeCard(
                name: DemoProfile.name,
                employeeNumber: language.employeeNumberTemplate.replaceAll(
                  '{number}',
                  DemoProfile.employeeNumber,
                ),
                noticeTitle: language.noticeTitle,
                message: messages[messageIndex],
                messageIndex: messageIndex,
                expandLabel: language.expandLabel,
                collapseLabel: language.collapseLabel,
              ),
              const SizedBox(height: 20),
              _SearchField(hintText: language.searchPlaceholder),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final category in SignageCategory.values)
                    Expanded(
                      child: _CategoryButton(
                        name: categoryName(category, language),
                        icon: categoryIcon(category),
                        selected: category == _selectedCategory,
                        onTap: () => _selectCategory(category),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              _SectionTitle(language.dangerSignageTitle),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: GridView.builder(
                  key: ValueKey(_selectedCategory),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: signageItems.length,
                  itemBuilder: (context, index) {
                    final signage = signageItems[index];
                    return _SignageCard(
                      signage: signage,
                      name: signage.name(language),
                      onTap: () => _openSignageDialog(signage),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 홈 화면의 섹션 제목(공지사항 / 위험 표지판)에 공통으로 쓰는 스타일.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

/// 홈 화면 맨 위 카드. 위쪽 공지사항은 접었다 펼 수 있고, 아래쪽 프로필은 항상 보인다.
class _ProfileNoticeCard extends StatefulWidget {
  const _ProfileNoticeCard({
    required this.name,
    required this.employeeNumber,
    required this.noticeTitle,
    required this.message,
    required this.messageIndex,
    required this.expandLabel,
    required this.collapseLabel,
  });

  final String name;
  final String employeeNumber;
  final String noticeTitle;

  /// 지금 보여줄 안전 멘트와 그 인덱스(문구가 바뀔 때 페이드 전환용 키).
  final String message;
  final int messageIndex;

  final String expandLabel;
  final String collapseLabel;

  @override
  State<_ProfileNoticeCard> createState() => _ProfileNoticeCardState();
}

class _ProfileNoticeCardState extends State<_ProfileNoticeCard> {
  /// 공지사항을 펼친 상태인지. 처음에는 펼쳐둔다.
  bool _expanded = true;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 제목 줄 전체를 눌러도 토글되게 해서 화살표만 겨냥하지 않아도 되게 한다.
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.campaign, color: AppColors.accentDark, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.noticeTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: _expanded
                        ? widget.collapseLabel
                        : widget.expandLabel,
                    child: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.accentDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 펼침/접힘을 높이 애니메이션으로 부드럽게 처리한다.
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _SafetyNotice(
                    message: widget.message,
                    index: widget.messageIndex,
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.accentBorder, height: 1),
          const SizedBox(height: 14),
          _ProfileRow(
            name: widget.name,
            employeeNumber: widget.employeeNumber,
          ),
        ],
      ),
    );
  }
}

/// 카드 아래쪽의 프로필 줄. 표시값은 [DemoProfile] 고정값이다.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.name, required this.employeeNumber});

  final String name;

  /// 이미 언어별 문구로 조립된 사원번호 줄 (예: '사원번호 12345').
  final String employeeNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 프로필 사진이 아직 없어서 기본 사람 아이콘을 원형 배경 위에 얹는다.
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.accentLight,
          child: Icon(Icons.person, size: 30, color: AppColors.accentDark),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                employeeNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 카드 안에서 펼쳤을 때 보이는 안전 멘트.
///
/// 흰 카드 안에 또 상자를 만들면 "카드 속 카드"로 보여서, 배경도 테두리도 없이
/// 글자만 가운데 정렬로 둔다.
class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice({required this.message, required this.index});

  final String message;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Text(
          message,
          key: ValueKey(index),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.5,
            color: AppColors.accentDark,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    // 지금은 UI만. 실제 검색 동작은 나중에 연결한다.
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.name,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : AppColors.accent,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? AppColors.accentDark : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignageCard extends StatelessWidget {
  const _SignageCard({
    required this.signage,
    required this.name,
    required this.onTap,
  });

  final Signage signage;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1.5,
      shadowColor: AppColors.cardShadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SignageImage(
                  icon: signage.icon,
                  color: signage.color,
                  assetPath: signage.imageAsset,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
