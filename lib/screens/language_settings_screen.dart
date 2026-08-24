import 'package:flutter/material.dart';

import '../language_service.dart';

/// "분석 결과를 받을 언어" 를 고르는 화면.
class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  AppLanguage? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final language = await LanguageService.instance.getLanguage();
    if (!mounted) return;
    setState(() => _selected = language);
  }

  Future<void> _select(AppLanguage language) async {
    setState(() => _selected = language);
    await LanguageService.instance.setLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(
        title: Text((selected ?? AppLanguage.ko).languageSettingsLabel),
      ),
      body: selected == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    selected.languageSectionHeader,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                for (final language in AppLanguage.all)
                  ListTile(
                    title: Text(
                      language.label,
                      style: const TextStyle(fontSize: 17),
                    ),
                    trailing: selected.code == language.code
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () => _select(language),
                  ),
              ],
            ),
    );
  }
}
