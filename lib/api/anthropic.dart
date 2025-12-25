import 'dart:convert';
import 'package:http/http.dart' as http;

class AnthropicApi {
  final String apiKey;

  AnthropicApi(this.apiKey);

  static const _url = 'https://api.anthropic.com/v1/messages';

  Future<String> send({
    required String system,
    required List<Map<String, String>> messages,
    String? userOverride,
    int maxTokens = 4000,
    double temperature = 1.0,
  }) async {
    final payload = {
      "model": "claude-3-5-sonnet-20241022",
      "max_tokens": maxTokens,
      "temperature": temperature,
      "system": system,
      "messages": [
        ...messages,
        if (userOverride != null)
          {"role": "user", "content": userOverride},
      ],
    };

    final res = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    final data = jsonDecode(res.body);
    return data['content'][0]['text'] ?? '';
  }
}
