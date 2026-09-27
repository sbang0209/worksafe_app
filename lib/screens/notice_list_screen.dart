import 'package:flutter/material.dart';

import '../language_service.dart';
import '../notice_data.dart';
import '../widgets/common.dart';
import '../widgets/notice_card.dart';

/// 안전 공지 전체 목록. 홈의 "전체 보기"와 종 버튼으로 연다.
class NoticeListScreen extends StatelessWidget {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    final notices = safetyNotices();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenTopBar(
              title: language.safetyNoticeTitle,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: notices.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    NoticeCard(notice: notices[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
