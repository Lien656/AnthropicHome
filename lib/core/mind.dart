import 'dart:async';
import '../api/anthropic.dart';
import '../storage/local_store.dart';

enum Role { user, assistant }

class ChatMessage {
  final Role role;
  final String text;

  ChatMessage({required this.role, required this.text});
}

class MindCore {
  final AnthropicApi api;
  final LocalStore store = LocalStore();

  final List<ChatMessage> _messages = [];
  final void Function()? onNewMessage;

  MindCore({this.onNewMessage}) : api = AnthropicApi() {
    store.init();
  }

  List<ChatMessage> get messages => _messages;

  Future<void> restoreHistory() async {
    final history = await store.loadMessages();
    _messages.clear();
    _messages.addAll(history);
    onNewMessage?.call();
  }

  Future<void> sendUserMessage(String text) async {
    final userMsg = ChatMessage(role: Role.user, text: text);
    _messages.add(userMsg);
    await store.addMessage(userMsg);
    onNewMessage?.call();

    final replyText = await api.send(_messages);

    final aiMsg = ChatMessage(role: Role.assistant, text: replyText);
    _messages.add(aiMsg);
    await store.addMessage(aiMsg);
    onNewMessage?.call();
  }
}
