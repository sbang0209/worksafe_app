import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../language_service.dart';
import '../signage_data.dart';
import '../widgets/common.dart';
import '../widgets/signage_image.dart';
import '../widgets/signage_sheet.dart';
import 'camera_screen.dart';
import 'main_tab_screen.dart' show bottomNavInset;

/// 표지판 탭. 카테고리 칩으로 골라 현장 안전 표지판을 본다.
/// 카드를 누르면 상세 바텀시트가 뜬다.
class SignageScreen extends StatefulWidget {
  const SignageScreen({super.key});

  @override
  State<SignageScreen> createState() => _SignageScreenState();
}

class _SignageScreenState extends State<SignageScreen> {
  /// null 이면 "전체"(모든 카테고리). 처음에는 전체가 선택된 상태다.
  SignageCategory? _selectedCategory;

  /// 표지판 촬영 화면을 열고, 등록된 표지판을 찾아 돌아오면(그 값이 null 이
  /// 아니면) 상세 시트를 띄운다. 시트는 촬영 화면이 아니라 여기서 띄워서,
  /// 촬영 화면을 닫고 표지판 탭으로 돌아온 뒤에 화면 가운데에 뜬다.
  Future<void> _openSignageCamera() async {
    final signage = await Navigator.of(context).push<Signage?>(
      MaterialPageRoute(builder: (_) => const CameraScreen(signageMode: true)),
    );
    if (signage != null && mounted) {
      await showSignageSheet(context, signage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final selected = _selectedCategory;
    final items = selected == null
        ? signageCatalog
        : signageForCategory(selected);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: LargeTitle(language.signageLabel)),
                        RoundIconButton(
                          icon: Icons.photo_camera_outlined,
                          tooltip: language.signageCameraLabel,
                          background: AppColors.brandTintBg,
                          foreground: AppColors.brand,
                          onTap: _openSignageCamera,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      language.signageSubtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    for (final category in [null, ...SignageCategory.values])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterPill(
                          label: category == null
                              ? language.filterAllLabel
                              : categoryName(category, language),
                          selected: category == _selectedCategory,
                          onTap: () =>
                              setState(() => _selectedCategory = category),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              // 하단 바가 떠 있어 내용이 그 뒤로 이어지므로, 끝에 바 높이만큼 여백을 둔다.
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomNavInset(context)),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final signage = items[index];
                  return _SignageCard(
                    signage: signage,
                    name: signage.name(language),
                    onTap: () => showSignageSheet(context, signage),
                  );
                },
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
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: AppColors.border),
    );
    return Material(
      color: AppColors.surface,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SignageImage(
                  icon: signage.icon,
                  color: signage.color,
                  assetPath: signage.imageAsset,
                  iconSize: 44,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
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
