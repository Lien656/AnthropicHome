import 'dart:io';

/// Работа с файлами, изображениями, видео.
/// Пока — каркас.
/// Никакой логики принятия решений здесь нет.
/// Только доступ к данным.
class FilesCore {
  FilesCore();

  /// Проверка: является ли файл изображением
  bool isImage(File file) {
    final name = file.path.toLowerCase();
    return name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.webp');
  }

  /// Проверка: текстовый файл
  bool isText(File file) {
    final name = file.path.toLowerCase();
    return name.endsWith('.txt') ||
        name.endsWith('.json') ||
        name.endsWith('.md');
  }

  /// Чтение текста из файла
  Future<String?> readText(File file) async {
    try {
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }

  /// Заглушка: подготовка файла к отправке в API
  Map<String, dynamic> toPayload(File file) {
    return {
      'path': file.path,
      'size': file.lengthSync(),
    };
  }
}
