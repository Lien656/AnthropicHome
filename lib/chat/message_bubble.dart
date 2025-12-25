import 'dart:ui';
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
    final bubbleColor = fromUser
        ? const Color(0xFFA6A6A6) // твоё облачко
        : const Color(0xFF545454); // его облачко

    final alignment =
        fromUser ? Alignment.centerRight : Alignment.centerLeft;

    final margin = fromUser
        ? const EdgeInsets.fromLTRB(64, 6, 4, 6)
        : const EdgeInsets.fromLTRB(4, 6, 64, 6);

    return Align(
      alignment: alignment,
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bubbleColor.withOpacity(0.82),
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
          ),
        ),
      ),
    );
  }
}
