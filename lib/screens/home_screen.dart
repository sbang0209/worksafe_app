import 'dart:async';

import 'package:flutter/material.dart';

import '../language_service.dart';
import '../signage_data.dart';
import '../widgets/signage_image.dart';
import 'camera_screen.dart';

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

  Future<void> _openCamera() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CameraScreen()));
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
              height: 140,
              child: SignageImage(
                icon: signage.icon,
                color: signage.color,
                imagePath: signage.imagePath,
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
      backgroundColor: const Color(0xFFFFFBEA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: _openCamera,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: Text(language.takePhotoButton),
                ),
              ),
              const SizedBox(height: 12),
              _SafetyBanner(
                message: messages[messageIndex],
                index: messageIndex,
              ),
              const SizedBox(height: 16),
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
              Text(
                language.dangerSignageTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner({required this.message, required this.index});

  final String message;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.amber.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.campaign, color: Colors.amber.shade900, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                message,
                key: ValueKey(index),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
          ),
        ],
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
                color: selected ? Colors.amber.shade800 : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : Colors.amber.shade800,
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
                color: selected ? Colors.amber.shade900 : Colors.black87,
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
      shadowColor: Colors.black.withValues(alpha: 0.1),
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
                  imagePath: signage.imagePath,
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
