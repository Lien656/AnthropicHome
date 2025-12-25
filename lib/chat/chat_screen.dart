import 'package:flutter/material.dart';
import 'message_bubble.dart';
import 'input_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addUserMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );
    });

    _scrollToBottom();

    // ⚠️ здесь потом будет вызов mind / api
    // сейчас просто заглушка
    Future.delayed(const Duration(milliseconds: 400), () {
      _addAssistantMessage("…");
    });
  }

  void _addAssistantMessage(String text) {
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: false,
        ),
      );
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
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
    return Column(
      children: [
        // ===== HEADER =====
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.center,
          child: const Text(
            'AnthropicHome',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ===== CHAT =====
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return MessageBubble(
                text: msg.text,
                isUser: msg.isUser,
              );
            },
          ),
        ),

        // ===== INPUT =====
        InputBar(
          onSend: _addUserMessage,
        ),
      ],
    );
  }
}

// ----------------------------
// INTERNAL MODEL (UI ONLY)
// ----------------------------
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({
    required this.text,
    required this.isUser,
  });
}
