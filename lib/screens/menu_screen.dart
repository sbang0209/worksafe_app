import 'package:flutter/material.dart';

import 'language_settings_screen.dart';

/// 메뉴 탭. 언어 설정 등 앱 전역 설정 항목을 목록으로 둔다.
/// (사용법, 앱 정보 등은 이후 항목으로 추가될 예정)
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메뉴')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('언어 설정', style: TextStyle(fontSize: 17)),
            trailing: const Icon(Icons.chevron_right),
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
