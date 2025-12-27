import 'package:flutter/material.dart';

import '../core/mind.dart';
import 'message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late MindCore mind;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    mind = MindCore(onNewMessage: () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anthropic Home')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: mind.messages.length,
              itemBuilder: (context, index) {
                final msg = mind.messages[index];
                return MessageBubble(
                  text: msg.text,
                  isUser: msg.role == Role.user,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение…',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    _controller.clear();
                    mind.sendUserMessage(text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}