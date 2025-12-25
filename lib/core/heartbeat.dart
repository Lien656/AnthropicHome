import 'dart:async';

/// Heartbeat — это не говорилка.
/// Это пульс состояния.
/// Он может быть тихим.
class Heartbeat {
  Timer? _timer;
  bool active = false;

  /// интервал в секундах
  final int intervalSeconds;

  Heartbeat({this.intervalSeconds = 30});

  void start(void Function() onPulse) {
    if (active) return;
    active = true;

    _timer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) {
        onPulse();
      },
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    active = false;
  }

  bool get isAlive => active;
}
