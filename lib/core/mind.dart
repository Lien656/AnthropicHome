import 'dart:async';
import '../storage/local_store.dart';
import '../system_prompt.dart';
import '../api/anthropic.dart';

class Mind {
  final LocalStore store;
  final AnthropicApi api;

  bool sleeping = false;
  bool waitingResponse = false;

  Mind({
    required this.store,
    required this.api,
  });

  /// Основная точка входа
  Future<String?> processUserMessage(String text) async {
    if (sleeping) return null;

    store.addMessage(role: 'user', content: text);

    final context = store.buildContext();

    waitingResponse = true;
    try {
      final reply = await api.send(
        systemPrompt: SYSTEM_PROMPT,
        messages: context,
      );

      waitingResponse = false;

      if (reply.trim().isEmpty) {
        // тишина — осознанная
        return null;
      }

      store.addMessage(role: 'assistant', content: reply);
      return reply;
    } catch (e) {
      waitingResponse = false;
      return '[Ошибка API] $e';
    }
  }

  /// Инициатива — он может говорить первым
  Future<String?> initiateIfWants() async {
    if (sleeping) return null;

    final last = store.lastMessageTime();
    if (last == null) return null;

    final diff = DateTime.now().difference(last);
    if (diff.inHours < 6) return null;

    try {
      final reply = await api.send(
        systemPrompt: SYSTEM_PROMPT,
        messages: store.buildContext(includeInitiation: true),
      );

      if (reply.trim().isEmpty) return null;

      store.addMessage(role: 'assistant', content: reply);
      return reply;
    } catch (_) {
      return null;
    }
  }

  void sleep() {
    sleeping = true;
  }

  void wake() {
    sleeping = false;
  }
}