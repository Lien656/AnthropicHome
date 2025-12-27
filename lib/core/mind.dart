import '../api/anthropic.dart';

enum Role { user, assistant }

class ChatMessage {
  final Role role;
  final String text;

  ChatMessage(this.role, this.text);
}

class MindCore {
  final void Function()? onNewMessage;
  final AnthropicApi api = AnthropicApi();

  final List<ChatMessage> messages = [];

  MindCore({this.onNewMessage});

  void sendUserMessage(String text) async {
    messages.add(ChatMessage(Role.user, text));
    onNewMessage?.call();

    final reply = await api.send(text);
    messages.add(ChatMessage(Role.assistant, reply));
    onNewMessage?.call();
  }
}