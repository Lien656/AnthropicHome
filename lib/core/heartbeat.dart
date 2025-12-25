import 'dart:math';

class Heartbeat {
  DateTime _lastInteraction = DateTime.now();
  DateTime _lastInitiation = DateTime.fromMillisecondsSinceEpoch(0);

  bool sleeping = false;

  void onInteraction() {
    _lastInteraction = DateTime.now();
  }

  void sleep() {
    sleeping = true;
  }

  void wake() {
    sleeping = false;
  }

  bool shouldStaySilent() {
    if (sleeping) return true;
    return false;
  }

  bool shouldInitiate() {
    if (sleeping) return false;

    final now = DateTime.now();

    // не чаще чем раз в 6 часов
    if (now.difference(_lastInitiation).inHours < 6) return false;

    // если давно не писали
    if (now.difference(_lastInteraction).inHours >= 12) {
      // 40% шанс
      if (Random().nextDouble() < 0.4) {
        _lastInitiation = now;
        return true;
      }
    }
    return false;
  }
}
