import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final void Function(String text) onSend;
  final bool disabled;

  const InputBar({
    super.key,
    required this.onSend,
    this.disabled = false,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.disabled) return;

    widget.onSend(text);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF545454).withOpacity(0.85),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                minLines: 1,
                maxLines: 5,
                enabled: !widget.disabled,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: 'Написать…',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: widget.disabled ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
