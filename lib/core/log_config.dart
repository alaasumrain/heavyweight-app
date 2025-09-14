import 'dart:math';

class LogConfig {
  static final Set<String> _mutes = <String>{};
  static final Map<String, int> _cooldownsMs = <String, int>{};
  static final Map<String, double> _sampling = <String, double>{};
  static final Random _rng = Random();

  static void update({
    Iterable<String>? mutes,
    Map<String, int>? cooldownsMs,
    Map<String, double>? sampling,
  }) {
    _mutes
      ..clear()
      ..addAll(mutes ?? const <String>[]);
    _cooldownsMs
      ..clear()
      ..addAll(cooldownsMs ?? const <String, int>{});
    _sampling
      ..clear()
      ..addAll(sampling ?? const <String, double>{});
  }

  static bool isMuted(String key) => _mutes.contains(key);

  // Read-only snapshots for Dev UI
  static List<String> mutes() => List.unmodifiable(_mutes);
  static Map<String, int> cooldownsMs() => Map.unmodifiable(_cooldownsMs);
  static Map<String, double> sampling() => Map.unmodifiable(_sampling);

  static Duration? cooldownFor(String key) {
    final ms = _cooldownsMs[key];
    if (ms == null) return null;
    return Duration(milliseconds: ms);
  }

  static bool allowSample(String key) {
    final p = _sampling[key];
    if (p == null) return true;
    if (p <= 0) return false;
    if (p >= 1) return true;
    return _rng.nextDouble() <= p;
  }
}
