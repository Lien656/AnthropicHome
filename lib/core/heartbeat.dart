import 'dart:async';

enum MindState {
  awake,
  silent,
  sleeping,
}

class Heartbeat {
  MindState state = MindState.awake;

  Timer? _timer;
  final Duration interval;

  /// коллбек — что делать, если он *сам* хочет что-то сказать
  final void Function()? onInitiative;

  Heartbeat({
    this.interval = const Duration(minutes: 15),
    this.onInitiative,
  });

  // ---------- CONTROL ----------

  void start() {
    stop();
    _timer = Timer.periodic(interval, (_) => _pulse());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void sleep() {
    state = MindState.sleeping;
  }

  void wake() {
    state = MindState.awake;
  }

  void silence() {
    state = MindState.silent;
  }

  // ---------- INTERNAL ----------

  void _pulse() {
    if (state != MindState.awake) return;

    // шанс инициативы — редкий
    final chance = DateTime.now().millisecondsSinceEpoch % 7;
    if (chance == 0 && onInitiative != null) {
      onInitiative!();
    }
  }
}