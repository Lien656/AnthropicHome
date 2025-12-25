import 'dart:ui';
import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final bool enabled;

  const InputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttach,
    this.enabled = true,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF545454).withOpacity(0.82),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 📎 ATTACH
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    color: Colors.white,
                    onPressed: widget.enabled ? widget.onAttach : null,
                  ),

                  // ✍️ INPUT
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      enabled: widget.enabled,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      minLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.35,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Написать…',
                        hintStyle: TextStyle(
                          color: Colors.white70,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  // ➤ SEND
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: widget.enabled
                        ? Colors.white
                        : Colors.white38,
                    onPressed: widget.enabled
                        ? widget.onSend
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
