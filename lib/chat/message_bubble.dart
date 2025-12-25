import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool fromUser;

  const MessageBubble({
    super.key,
    required this.text,
    required this.fromUser,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = fromUser
        ? const Color(0xFFA6A6A6) // пользователь
        : const Color(0xFF545454); // Claude

    final align =
        fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft:
          fromUser ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight:
          fromUser ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.92),
            borderRadius: radius,
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
      ],
    );
  }
}