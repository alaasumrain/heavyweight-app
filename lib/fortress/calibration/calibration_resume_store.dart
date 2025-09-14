import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalibrationAttemptRecord {
  final String exerciseId;
  final int attemptIdx; // 1-based
  final double signedLoadKg;
  final double effectiveLoadKg;
  final int reps;
  final double est1RmKg;
  final double nextSignedKg;
  final String tsIso;
  final String checksum;

  CalibrationAttemptRecord({
    required this.exerciseId,
    required this.attemptIdx,
    required this.signedLoadKg,
    required this.effectiveLoadKg,
    required this.reps,
    required this.est1RmKg,
    required this.nextSignedKg,
    required this.tsIso,
    required this.checksum,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'attemptIdx': attemptIdx,
        'signedLoadKg': signedLoadKg,
        'effectiveLoadKg': effectiveLoadKg,
        'reps': reps,
        'est1RmKg': est1RmKg,
        'nextSignedKg': nextSignedKg,
        'ts': tsIso,
        'checksum': checksum,
      };

  static CalibrationAttemptRecord fromJson(Map<String, dynamic> json) {
    return CalibrationAttemptRecord(
      exerciseId: json['exerciseId'],
      attemptIdx: json['attemptIdx'],
      signedLoadKg: (json['signedLoadKg'] as num).toDouble(),
      effectiveLoadKg: (json['effectiveLoadKg'] as num).toDouble(),
      reps: json['reps'],
      est1RmKg: (json['est1RmKg'] as num).toDouble(),
      nextSignedKg: (json['nextSignedKg'] as num).toDouble(),
      tsIso: json['ts'],
      checksum: json['checksum'],
    );
  }
}

class CalibrationResumeStore {
  static const _key = 'hw_calibration_resume_state';

  static String _checksum(String exerciseId, int attemptIdx, double signedLoadKg, int reps) {
    // Simple checksum to detect tampering/dup; not cryptographic
    final base = '$exerciseId|$attemptIdx|$signedLoadKg|$reps';
    return base.hashCode.toString();
  }

  static Future<void> saveAttempt({
    required String exerciseId,
    required int attemptIdx,
    required double signedLoadKg,
    required double effectiveLoadKg,
    required int reps,
    required double est1RmKg,
    required double nextSignedKg,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rec = CalibrationAttemptRecord(
      exerciseId: exerciseId,
      attemptIdx: attemptIdx,
      signedLoadKg: signedLoadKg,
      effectiveLoadKg: effectiveLoadKg,
      reps: reps,
      est1RmKg: est1RmKg,
      nextSignedKg: nextSignedKg,
      tsIso: DateTime.now().toIso8601String(),
      checksum: _checksum(exerciseId, attemptIdx, signedLoadKg, reps),
    );
    await prefs.setString(_key, jsonEncode(rec.toJson()));
  }

  static Future<CalibrationAttemptRecord?> loadPending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CalibrationAttemptRecord.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

