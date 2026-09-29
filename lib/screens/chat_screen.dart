import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../gemini_service.dart';
import '../language_service.dart';
import '../tts_service.dart';
import '../widgets/common.dart';

/// 화면에 보여줄 대화 한 마디. [GeminiService] 의 [ChatTurn] 과 달리 오류
/// 여부([isError])를 함께 들고 있어, 말풍선 대신 회색 오류 문구로 그릴지
/// 여기서 결정할 수 있다.
class _ChatMessage {
  const _ChatMessage({
    required this.fromUser,
    required this.text,
    this.isError = false,
  });

  final bool fromUser;
  final String text;
  final bool isError;
}

/// 안전 챗봇 화면. 홈 검색창을 눌러 연다. 대화는 저장하지 않아 화면을 나가면
/// 초기화된다.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _sending) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(fromUser: true, text: text));
      _sending = true;
    });
    _scrollToBottom();

    try {
      // askSafetyQuestion 은 예외를 던지지 않고 실패해도 오류 문구를
      // 문자열로 돌려주지만, 화면 쪽에서도 한 번 더 감싸서 어떤 경우에도
      // 이 화면이 멈추지 않게 한다.
      final reply = await GeminiService.instance.askSafetyQuestion([
        for (final message in _messages)
          ChatTurn(fromUser: message.fromUser, text: message.text),
      ]);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(fromUser: false, text: reply));
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      final language = LanguageService.instance.current;
      setState(() {
        _messages.add(
          _ChatMessage(
            fromUser: false,
            text: language.errorGeneric,
            isError: true,
          ),
        );
        _sending = false;
      });
    }
    _scrollToBottom();
  }

  Future<void> _speak(String text, AppLanguage language) async {
    final started = await TtsService.instance.speak(text, language);
    if (!started && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.ttsUnavailableMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageService.instance.current;
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      // 키보드가 올라오면 Scaffold 가 기본으로 본문을 줄여서, 입력창이 항상
      // 키보드 위에 그대로 보인다(resizeToAvoidBottomInset 기본값 true).
      body: SafeArea(
        child: Column(
          children: [
            ScreenTopBar(
              title: language.chatTitle,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? _WelcomeView(
                      welcome: language.chatWelcome,
                      suggestions: language.chatSuggestions,
                      onSuggestionTap: _send,
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _MessageBubble(
                          message: message,
                          onSpeak: message.fromUser || message.isError
                              ? null
                              : () => _speak(message.text, language),
                        );
                      },
                    ),
            ),
            _ChatInputBar(
              controller: _controller,
              hint: language.chatInputHint,
              sending: _sending,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

/// 메시지가 하나도 없을 때 가운데 보여주는 안내 + 추천 질문 칩.
/// 시연 중 타이핑 없이 바로 질문을 보낼 수 있게 칩을 누르면 그대로 전송된다.
class _WelcomeView extends StatelessWidget {
  const _WelcomeView({
    required this.welcome,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final String welcome;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.textFaint,
            ),
            const SizedBox(height: 16),
            Text(
              welcome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final suggestion in suggestions)
                  FilterPill(
                    label: suggestion,
                    selected: false,
                    onTap: () => onSuggestionTap(suggestion),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 말풍선 하나. 사용자는 오른쪽(브랜드 틸 + 흰 글씨), AI 는 왼쪽(흰 배경).
/// 오류 메시지는 말풍선 없이 회색 문구로만 보여주고 스피커도 달지 않는다.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onSpeak});

  final _ChatMessage message;

  /// null 이면(사용자 메시지 또는 오류) 스피커 아이콘을 그리지 않는다.
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    if (message.isError) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            message.text,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ),
      );
    }

    final fromUser = message.fromUser;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: fromUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: fromUser ? AppColors.brand : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: fromUser ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          if (onSpeak != null)
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 4),
              child: InkWell(
                onTap: onSpeak,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.volume_up_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 하단 입력 줄: TextField + 전송 버튼. 전송 중에는 둘 다 비활성이고,
/// 전송 버튼 자리에 작은 로딩 인디케이터가 뜬다.
class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.hint,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hint;
  final bool sending;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !sending,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: sending ? null : onSend,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textFaint),
                filled: true,
                fillColor: AppColors.fieldBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: sending ? AppColors.borderStrong : AppColors.brand,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: sending ? null : () => onSend(controller.text),
              child: SizedBox(
                width: 48,
                height: 48,
                child: sending
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
