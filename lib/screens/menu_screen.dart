import 'package:flutter/material.dart';

import '../language_service.dart';
import 'language_settings_screen.dart';

/// 메뉴 탭. 언어 설정 등 앱 전역 설정 항목을 목록으로 둔다.
/// (사용법, 앱 정보 등은 이후 항목으로 추가될 예정)
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    return Scaffold(
      appBar: AppBar(title: Text(language.menuLabel), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            leading: const Icon(Icons.language, size: 30),
            title: Text(
              language.languageSettingsLabel,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.chevron_right, size: 28),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LanguageSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
