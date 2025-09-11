import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Lightweight structured logging helper for debug builds.
/// Prints single-line JSON to make logs easy to scan and share.
class HWLog {
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
    _print({
      'type': 'event',
      'name': name,
      'data': data,
      'ts': DateTime.now().toIso8601String(),
    });
  }

  static void screen(String name, {Map<String, Object?> data = const {}}) {
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

