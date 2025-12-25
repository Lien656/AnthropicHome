class Memory {
  final List<Map<String, String>> _core = [];
  final List<Map<String, String>> _episodic = [];
  final List<String> _diary = [];

  void addUser(String text) {
    _episodic.add({"role": "user", "content": text});
    _trim();
  }

  void addAi(String text) {
    _episodic.add({"role": "assistant", "content": text});
    _trim();
  }

  void addCore(String text) {
    _core.add({"role": "system", "content": text});
  }

  void addDiary(String text) {
    _diary.add(text);
  }

  List<Map<String, String>> buildContext({int limit = 30}) {
    final ctx = <Map<String, String>>[];
    ctx.addAll(_core);
    ctx.addAll(_episodic.takeLast(limit));
    return ctx;
  }

  void _trim() {
    if (_episodic.length > 200) {
      _episodic.removeRange(0, _episodic.length - 200);
    }
  }
}

extension TakeLast<E> on List<E> {
  Iterable<E> takeLast(int n) =>
      length <= n ? this : sublist(length - n);
}
