import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'log_config.dart';

/// Lightweight structured logging helper for debug builds.
/// Prints single-line JSON to make logs easy to scan and share.
class HWLog {
  // Rate-limiter to avoid flooding logs on rapid rebuilds
  static final Map<String, DateTime> _lastPrint = {};

  static bool _allow(String key, Duration defaultInterval) {
    // Sampling check
    if (!LogConfig.allowSample(key)) return false;
    // Cooldown check (per-key override)
    final cd = LogConfig.cooldownFor(key) ?? defaultInterval;
    final now = DateTime.now();
    final last = _lastPrint[key];
    if (last != null && now.difference(last) < cd) {
      return false;
    }
    _lastPrint[key] = now;
    return true;
  }

  static void _print(Map<String, Object?> payload) {
    if (!kDebugMode) return;
    try {
      final line = jsonEncode(payload);
      // Prefix to make searching easy
      debugPrint('HWLOG $line');
    } catch (_) {
      // Fallback if serialization fails
      debugPrint('HWLOG $payload');
    }
  }

  static void event(String name, {Map<String, Object?> data = const {}}) {
    if (LogConfig.isMuted(name)) return;
    // Throttle rapid-fire events with the same name to reduce console noise
    if (!_allow('event:$name', const Duration(milliseconds: 400))) return;
    _print({
      'type': 'event',
      'name': name,
      'data': data,
      'ts': DateTime.now().toIso8601String(),
    });
  }

  static void screen(String name, {Map<String, Object?> data = const {}}) {
    if (LogConfig.isMuted(name)) return;
    // Throttle identical screen logs within 1s to reduce noise
    if (!_allow('screen:$name', const Duration(seconds: 1))) return;
    _print({
      'type': 'screen',
      'name': name,
      'data': data,
      'ts': DateTime.now().toIso8601String(),
    });
  }

  static void routeDecision({
    required String current,
    String? decided,
    Map<String, Object?> context = const {},
  }) {
    _print({
      'type': 'route_decision',
      'current': current,
      'decided': decided,
      'ctx': context,
      'ts': DateTime.now().toIso8601String(),
    });
  }

  static void appStateSnapshot(Map<String, Object?> state) {
    _print({
      'type': 'app_state',
      'state': state,
      'ts': DateTime.now().toIso8601String(),
    });
  }

  static void lifecycle(String phase, {Map<String, Object?> data = const {}}) {
    _print({
      'type': 'lifecycle',
      'phase': phase,
      'data': data,
      'ts': DateTime.now().toIso8601String(),
    });
  }
}
