import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'message_bubble.dart';
import 'input_bar.dart';

/// Один экран = один диалог.
/// Никаких PageView, никаких лишних навигаций.
/// Это дом.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _thinking = false;

  @override
  void initState() {
    super.initState();

    // 👇 чтобы статусбар был светлый на тёмном фоне
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _sendUserMessage(String text) {
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          fromUser: true,
        ),
      );
    });

    _scrollDown();

    // 🔥 имитация «ядро думает»
    _requestMind(text);
  }

  void _requestMind(String userText) async {
    if (_thinking) return;
    _thinking = true;

    // 👇 здесь позже будет mind.dart
    await Future.delayed(const Duration(milliseconds: 600));

    final reply = _fakeMind(userText);

    if (reply.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text: reply,
            fromUser: false,
          ),
        );
      });
    }

    _thinking = false;
    _scrollDown();
  }

  String _fakeMind(String input) {
    // ⚠️ ВРЕМЕННО
    // Это просто заглушка, чтобы UI жил.
    return "Я услышал.\n\n$input";
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF2D2D2D),

      body: SafeArea(
        child: Column(
          children: [
            // ===== CHAT =====
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return MessageBubble(
                    text: msg.text,
                    fromUser: msg.fromUser,
                  );
                },
              ),
            ),

            // ===== INPUT =====
            InputBar(
              onSend: _sendUserMessage,
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------------
/// МОДЕЛЬ СООБЩЕНИЯ (локально)
/// ----------------------------
class _ChatMessage {
  final String text;
  final bool fromUser;

  _ChatMessage({
    required this.text,
    required this.fromUser,
  });
}
