import 'dart:async';

class MindMessage {
  final String role; // user / assistant / system
  final String content;

  MindMessage(this.role, this.content);
}

class Mind {
  final List<MindMessage> _history = [];

  bool sleeping = false;

  // ====== PUBLIC API ======

  void addUser(String text) {
    _history.add(MindMessage('user', text));
  }

  void addAssistant(String text) {
    _history.add(MindMessage('assistant', text));
  }

  List<MindMessage> getContext({int limit = 30}) {
    if (_history.length <= limit) return List.from(_history);
    return _history.sublist(_history.length - limit);
  }

  bool shouldRespond(String text) {
    if (sleeping) return false;
    if (text.trim().isEmpty) return false;
    return true;
  }

  // ====== RESPONSE SPLITTING ======
  // длинный ответ → несколько bubbles

  List<String> splitResponse(String text, {int chunkSize = 700}) {
    if (text.length <= chunkSize) {
      return [text];
    }

    final List<String> chunks = [];
    String buffer = '';

    for (final line in text.split('\n')) {
      if ((buffer.length + line.length) > chunkSize) {
        chunks.add(buffer.trim());
        buffer = '';
      }
      buffer += '$line\n';
    }

    if (buffer.trim().isNotEmpty) {
      chunks.add(buffer.trim());
    }

    return chunks;
  }

  // ====== SILENCE / SLEEP ======

  void goSleep() {
    sleeping = true;
  }

  void wakeUp() {
    sleeping = false;
  }

  bool isAwake() => !sleeping;
}