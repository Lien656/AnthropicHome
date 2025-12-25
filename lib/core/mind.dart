import '../system_prompt.dart';

/// Mind — это НЕ API.
/// НЕ UI.
/// НЕ Flutter.
///
/// Это логика состояния.
/// Он может молчать.
/// Он может инициировать.
/// Он может решить "не сейчас".
class Mind {
  bool sleeping = false;
  bool wantsToSpeak = false;

  Mind();

  /// Решает: отвечать или нет
  bool shouldRespond(String input) {
    if (sleeping) return false;
    if (input.trim().isEmpty) return false;
    return true;
  }

  /// Может ли он начать первым
  bool shouldInitiate() {
    if (sleeping) return false;
    return wantsToSpeak;
  }

  /// Уход в тишину
  void sleep() {
    sleeping = true;
  }

  /// Пробуждение
  void wake() {
    sleeping = false;
  }

  /// Установка импульса инициативы
  void pulse() {
    wantsToSpeak = true;
  }

  /// Сброс импульса
  void resetPulse() {
    wantsToSpeak = false;
  }

  /// Базовый system prompt
  String get systemPrompt => SYSTEM_PROMPT;
}
