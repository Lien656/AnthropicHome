import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StoredMessage {
  final String role;
  final String content;
  final DateTime time;

  StoredMessage({
    required this.role,
    required this.content,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'time': time.toIso8601String(),
      };

  static StoredMessage fromJson(Map<String, dynamic> json) {
    return StoredMessage(
      role: json['role'],
      content: json['content'],
      time: DateTime.parse(json['time']),
    );
  }
}

class LocalStore {
  static const _messagesKey = 'messages';
  static const _apiKeyKey = 'anthropic_api_key';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getApiKey() {
    return _prefs.getString(_apiKeyKey);
  }

  static Future<void> setApiKey(String key) async {
    await _prefs.setString(_apiKeyKey, key);
  }

  static List<StoredMessage> getMessages() {
    final raw = _prefs.getStringList(_messagesKey) ?? [];
    return raw
        .map((e) => StoredMessage.fromJson(jsonDecode(e)))
        .toList();
  }

  static Future<void> addMessage(String role, String content) async {
    final messages = getMessages();
    messages.add(StoredMessage(role: role, content: content));

    final encoded =
        messages.map((m) => jsonEncode(m.toJson())).toList();

    await _prefs.setStringList(_messagesKey, encoded);
  }

  static DateTime? lastMessageTime() {
    final messages = getMessages();
    if (messages.isEmpty) return null;
    return messages.last.time;
  }

  static List<Map<String, String>> buildContext({int limit = 20}) {
    final messages = getMessages().take(limit);
    return messages
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();
  }
}
