import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static const _apiKeyKey = 'anthropic_api_key';

  // ---------- API KEY ----------

  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
  }

  static Future<String?> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  // ---------- FILE PATHS ----------

  static Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final home = Directory('${dir.path}/anthropic_home');
    if (!await home.exists()) {
      await home.create(recursive: true);
    }
    return home;
  }

  static Future<File> _file(String name) async {
    final dir = await _baseDir();
    return File('${dir.path}/$name');
  }

  // ---------- HISTORY ----------

  static Future<List<Map<String, dynamic>>> loadHistory() async {
    try {
      final file = await _file('history.json');
      if (!await file.exists()) return [];
      final text = await file.readAsString();
      return List<Map<String, dynamic>>.from(jsonDecode(text));
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveHistory(List<Map<String, dynamic>> history) async {
    final file = await _file('history.json');
    await file.writeAsString(
      jsonEncode(history),
      flush: true,
    );
  }

  // ---------- MEMORY ----------

  static Future<Map<String, dynamic>> loadMemory() async {
    try {
      final file = await _file('memory.json');
      if (!await file.exists()) {
        return {
          'core': {},
          'episodic': [],
        };
      }
      return jsonDecode(await file.readAsString());
    } catch (_) {
      return {
        'core': {},
        'episodic': [],
      };
    }
  }

  static Future<void> saveMemory(Map<String, dynamic> memory) async {
    final file = await _file('memory.json');
    await file.writeAsString(
      jsonEncode(memory),
      flush: true,
    );
  }

  // ---------- EXPORT ----------

  static Future<File> exportHistory() async {
    final history = await loadHistory();
    final file = await _file(
        'export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(history), flush: true);
    return file;
  }
}