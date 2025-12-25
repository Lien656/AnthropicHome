import '../storage/local_store.dart';
import '../api/anthropic.dart';

enum Role { user, assistant }

class MindCore {
  final AnthropicApi api;

  MindCore(this.api);

  Future<String> send(String userText) async {
    await LocalStore.addMessage('user', userText);

    final context = LocalStore.buildContext();
    final reply = await api.send(context);

    await LocalStore.addMessage('assistant', reply);
    return reply;
  }
}
