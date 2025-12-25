import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/mind.dart';

class LocalStore {
  static const _messagesKey = 'chat_messages';
  static const _apiKeyKey = 'api_key';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> addMessage(ChatMessage msg) async {
    final list = await loadMessages();
    list.add(msg);
    await _prefs.setString(
      _messagesKey,
      jsonEncode(list.map(_encode).toList()),
    );
  }

  Future<List<ChatMessage>> loadMessages() async {
    final raw = _prefs.getString(_messagesKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map(_decode).toList();
  }

  Future<void> saveApiKey(String key) async {
    await _prefs.setString(_apiKeyKey, key);
  }

  Future<String?> getApiKey() async {
    return _prefs.getString(_apiKeyKey);
  }

  Map<String, dynamic> _encode(ChatMessage m) => {
        'role': m.role.name,
        'text': m.text,
      };

  ChatMessage _decode(dynamic m) => ChatMessage(
        role: m['role'] == 'user' ? Role.user : Role.assistant,
        text: m['text'],
      );
}

