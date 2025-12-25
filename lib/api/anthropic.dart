import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/local_store.dart';

class AnthropicApi {
  static const String _endpoint =
      'https://api.anthropic.com/v1/messages';
  static const String _version = '2023-06-01';

  final LocalStore store;

  AnthropicApi(this.store);

  Future<String> send({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    int maxTokens = 4000,
    double temperature = 1.0,
  }) async {
    final apiKey = await store.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not set');
    }

    final payload = {
      'model': 'claude-3-5-sonnet-20240620',
      'max_tokens': maxTokens,
      'temperature': temperature,
      'system': systemPrompt,
      'messages': messages,
    };

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': _version,
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Anthropic API ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    if (data['content'] == null || data['content'].isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (final block in data['content']) {
      if (block['type'] == 'text') {
        buffer.write(block['text']);
      }
    }

    return buffer.toString();
  }
}