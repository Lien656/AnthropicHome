import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Локальное хранилище:
/// - API ключ
/// - история
/// - память
class LocalStore {
  static const String _apiKeyFile = 'api_key.json';
  static const String _historyFile = 'history.json';

  Future<Directory> _dir() async {
    return await getApplicationDocumentsDirectory();
  }

  // ---------- API KEY ----------

  Future<void> saveApiKey(String key) async {
    final dir = await _dir();
    final file = File('${dir.path}/$_apiKeyFile');
    await file.writeAsString(jsonEncode({'key': key}));
  }

  Future<String?> loadApiKey() async {
    try {
      final dir = await _dir();
      final file = File('${dir.path}/$_apiKeyFile');
      if (!file.existsSync()) return null;
      final data = jsonDecode(await file.readAsString());
      return data['key'];
    } catch (_) {
      return null;
    }
  }

  // ---------- HISTORY ----------

  Future<List<Map<String, dynamic>>> loadHistory() async {
    try {
      final dir = await _dir();
      final file = File('${dir.path}/$_historyFile');
      if (!file.existsSync()) return [];
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(List<Map<String, dynamic>> history) async {
    final dir = await _dir();
    final file = File('${dir.path}/$_historyFile');
    await file.writeAsString(jsonEncode(history));
  }
}
