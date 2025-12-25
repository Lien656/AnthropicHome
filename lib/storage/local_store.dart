import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static const _apiKeyKey = 'anthropic_api_key';
  static const _historyKey = 'chat_history';
  static const _coreMemoryKey = 'core_memory';
  static const _episodicMemoryKey = 'episodic_memory';

  // ---------- API KEY ----------

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  // ---------- CHAT HISTORY ----------

  Future<List<Map<String, String>>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Map<String, String>.from(e as Map))
        .toList();
  }

  Future<void> saveHistory(List<Map<String, String>> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // ---------- CORE MEMORY (always remembered) ----------

  Future<List<String>> loadCoreMemory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_coreMemoryKey);
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw));
  }

  Future<void> saveCoreMemory(List<String> memory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_coreMemoryKey, jsonEncode(memory));
  }

  // ---------- EPISODIC MEMORY (optional / recall) ----------

  Future<List<String>> loadEpisodicMemory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_episodicMemoryKey);
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw));
  }

  Future<void> saveEpisodicMemory(List<String> memory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_episodicMemoryKey, jsonEncode(memory));
  }

  // ---------- RESET (если вдруг понадобится) ----------

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_coreMemoryKey);
    await prefs.remove(_episodicMemoryKey);
  }
}