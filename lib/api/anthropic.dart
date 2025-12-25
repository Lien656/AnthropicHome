import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/mind.dart';
import '../storage/local_store.dart';

class AnthropicApi {
  final LocalStore store = LocalStore();

  Future<String> send(List<ChatMessage> messages) async {
    final apiKey = await store.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return '❌ API key not set';
    }

    final prompt = messages
        .map((m) => '${m.role == Role.user ? "Human" : "Assistant"}: ${m.text}')
        .join('\n');

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/complete'),
      headers: {
        'x-api-key': apiKey,
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': 'claude-2',
        'prompt': '$prompt\nAssistant:',
        'max_tokens_to_sample': 300,
      }),
    );

    if (response.statusCode != 200) {
      return '❌ API error ${response.statusCode}';
    }

    final data = jsonDecode(response.body);
    return data['completion'] ?? '';
  }
}
