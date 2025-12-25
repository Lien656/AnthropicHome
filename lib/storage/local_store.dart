import 'dart:convert';
import 'dart:io';

class LocalStore {
  final Directory baseDir;

  LocalStore(this.baseDir) {
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }
  }

  File get _keyFile => File('${baseDir.path}/api_key.json');
  File get _historyFile => File('${baseDir.path}/history.json');

  // ---- API KEY ----

  String? loadApiKey() {
    if (!_keyFile.existsSync()) return null;
    final data = jsonDecode(_keyFile.readAsStringSync());
    return data['key'];
  }

  void saveApiKey(String key) {
    _keyFile.writeAsStringSync(jsonEncode({"key": key}));
  }

  // ---- HISTORY ----

  List<Map<String, dynamic>> loadHistory() {
    if (!_historyFile.existsSync()) return [];
    return List<Map<String, dynamic>>.from(
      jsonDecode(_historyFile.readAsStringSync()),
    );
  }

  void saveHistory(List<Map<String, dynamic>> history) {
    _historyFile.writeAsStringSync(
      jsonEncode(history),
    );
  }
}
