import 'dart:async';

import '../storage/local_store.dart';
import '../api/anthropic.dart';
import 'memory.dart';
import 'heartbeat.dart';
import '../system_prompt.dart';

/// Mind = мышление.
/// Он не рисует UI.
/// Он не знает про кнопки.
/// Он решает, ЧТО сказать и КОГДА.
class Mind {
  final LocalStore store;
  final AnthropicApi api;
  final Memory memory;
  final Heartbeat heartbeat;

  Mind({
    required this.store,
    required this.api,
    required this.memory,
    required this.heartbeat,
  });

  /// основной вход
  Future<List<String>> onUserMessage(String text) async {
    memory.addUser(text);
    heartbeat.onInteraction();

    // может молчать
    if (heartbeat.shouldStaySilent()) {
      return [];
    }

    final context = memory.buildContext();

    final full = await api.send(
      system: SYSTEM_PROMPT,
      messages: context,
    );

    if (full.trim().isEmpty) {
      return [];
    }

    memory.addAi(full);

    return _chunk(full);
  }

  /// инициатива (первый шаг)
  Future<List<String>> maybeInitiate() async {
    if (!heartbeat.shouldInitiate()) return [];

    final full = await api.send(
      system: SYSTEM_PROMPT,
      messages: memory.buildContext(),
      userOverride: INITIATION_PROMPT,
    );

    if (full.trim().isEmpty) return [];

    memory.addAi(full);
    return _chunk(full);
  }

  /// дневник
  Future<void> writeDiary() async {
    final full = await api.send(
      system: SYSTEM_PROMPT,
      messages: memory.buildContext(),
      userOverride: DIARY_PROMPT,
    );

    if (full.trim().isNotEmpty) {
      memory.addDiary(full);
    }
  }

  // -------- helpers --------

  List<String> _chunk(String text, {int size = 700}) {
    final out = <String>[];
    var i = 0;
    while (i < text.length) {
      final end = (i + size < text.length) ? i + size : text.length;
      out.add(text.substring(i, end));
      i = end;
    }
    return out;
  }
}
