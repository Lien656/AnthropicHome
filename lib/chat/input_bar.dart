import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final void Function(String text) onSend;

  const InputBar({super.key, required this.onSend});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;

  void _onChanged(String text) {
    setState(() {
      _canSend = text.trim().isNotEmpty;
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() => _canSend = false);
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: const BoxDecoration(
          color: Color(0xFF2D2D2D),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.white70),
              onPressed: () {
                // файлы позже
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Написать…',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: _canSend ? Colors.white : Colors.white38,
              ),
              onPressed: _canSend ? _send : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}