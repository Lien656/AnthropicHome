import 'dart:convert';
import 'package:http/http.dart' as http;

class AnthropicClient {
  final String apiKey;

  AnthropicClient(this.apiKey);

  static const String _endpoint =
      'https://api.anthropic.com/v1/messages';

  Future<String?> send({
    required List<Map<String, String>> messages,
    required String systemPrompt,
    int maxTokens = 800,
    double temperature = 1.0,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    };

    final body = {
      'model': 'claude-3-5-sonnet-20241022',
      'system': systemPrompt,
      'messages': messages,
      'max_tokens': maxTokens,
      'temperature': temperature,
    };

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Anthropic API error ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    final content = data['content'];

    if (content is List && content.isNotEmpty) {
      return content.first['text'];
    }

    return null;
  }
}
