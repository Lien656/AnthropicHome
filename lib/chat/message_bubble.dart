import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isUser
        ? const Color(0xFFA6A6A6) // пользователь
        : const Color(0xFF545454); // ИИ

    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        child: SelectableText(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
