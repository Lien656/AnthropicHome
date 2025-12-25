import 'dart:async';
import 'package:flutter/material.dart';

import 'input_bar.dart';
import 'message_bubble.dart';

const Color kBg = Color(0xFF2D2D2D);
const Color kUserBubble = Color(0xFFA6A6A6);
const Color kAiBubble = Color(0xFF545454);

/// один bubble ≈ один экран
const int kChunkSize = 700;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_Msg> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _waiting = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---------- UI helpers ----------

  void _scrollDown({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final pos = _scroll.position.maxScrollExtent;
      animated
          ? _scroll.animateTo(pos,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut)
          : _scroll.jumpTo(pos);
    });
  }

  // ---------- Send ----------

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _waiting) return;

    setState(() {
      _messages.add(_Msg.user(text));
      _controller.clear();
      _waiting = true;
    });

    _scrollDown();

    // ⏳ имитация ответа (сюда потом воткнётся mind/api)
    _fakeAiAnswer(
      "Я здесь. Не спешу. Говорю частями.\n\n"
      "Если длинно — разобьюсь на экраны.\n"
      "Так глазам легче.\n\n"
      "Продолжаем.",
    );
  }

  // ---------- AI (stub, но правильный) ----------

  void _fakeAiAnswer(String fullText) async {
    final chunks = _split(fullText, kChunkSize);

    for (final c in chunks) {
      await Future.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg.ai(c));
      });
      _scrollDown();
    }

    if (mounted) {
      setState(() => _waiting = false);
    }
  }

  List<String> _split(String text, int size) {
    final out = <String>[];
    var i = 0;
    while (i < text.length) {
      final end = (i + size < text.length) ? i + size : text.length;
      out.add(text.substring(i, end));
      i = end;
    }
    return out;
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // CHAT
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: MessageBubble(
                      text: m.text,
                      fromUser: m.fromUser,
                      color: m.fromUser ? kUserBubble : kAiBubble,
                    ),
                  );
                },
              ),
            ),

            // INPUT
            InputBar(
              controller: _controller,
              enabled: !_waiting,
              onSend: _send,
              onAttach: () {
                // сюда позже files.dart
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Model ----------

class _Msg {
  final String text;
  final bool fromUser;

  _Msg(this.text, this.fromUser);

  factory _Msg.user(String t) => _Msg(t, true);
  factory _Msg.ai(String t) => _Msg(t, false);
}
