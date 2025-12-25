import 'package:flutter/material.dart';
import '../core/mind.dart';
import 'input_bar.dart';
import 'message_bubble.dart';
import '../storage/local_store.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final MindCore mind;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    mind = MindCore(onNewMessage: _onNewMessage);
    mind.restoreHistory();
  }

  void _onNewMessage() {
    if (!_scroll.hasClients) return;
    Future.delayed(const Duration(milliseconds: 50), () {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claude'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: mind.messages.length,
              itemBuilder: (context, index) {
                final msg = mind.messages[index];
                return MessageBubble(
                  text: msg.content,
                  isUser: msg.role == Role.user,
                );
              },
            ),
          ),
          InputBar(
            onSend: (text) => mind.sendUserMessage(text),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }
}