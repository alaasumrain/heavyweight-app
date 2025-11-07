import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../backend/supabase/supabase.dart';
import '../../core/logging.dart';

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

  static String _checksum(
      String exerciseId, int attemptIdx, double signedLoadKg, int reps) {
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

    // Save locally first (always works)
    await prefs.setString(_key, jsonEncode(rec.toJson()));

    // Also save to Supabase for cross-device sync
    _saveToSupabase(rec);
  }

  static Future<void> _saveToSupabase(CalibrationAttemptRecord rec) async {
    try {
      final client = supabase;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      // Map exercise slug to DB ID
      final exerciseDbId = await _getExerciseDbId(rec.exerciseId);
      if (exerciseDbId == null) return;

      await client.from('calibration_resume').upsert({
        'user_id': userId,
        'exercise_id': exerciseDbId,
        'attempt_idx': rec.attemptIdx,
        'signed_load_kg': rec.signedLoadKg,
        'effective_load_kg': rec.effectiveLoadKg,
        'reps': rec.reps,
        'est1rm_kg': rec.est1RmKg,
        'next_signed_kg': rec.nextSignedKg,
      });

      HWLog.event('calibration_synced_to_server',
          data: {'exercise': rec.exerciseId});
    } catch (e) {
      HWLog.event('calibration_sync_failed', data: {'error': e.toString()});
      // Don't throw - local save already succeeded
    }
  }

  static Future<int?> _getExerciseDbId(String exerciseId) async {
    try {
      final client = supabase;
      final response = await client
          .from('exercises')
          .select('id')
          .eq('name', mapSlugToName(exerciseId))
          .single();
      return response['id'] as int;
    } catch (e) {
      return null;
    }
  }

  static String mapSlugToName(String slug) {
    switch (slug) {
      case 'bench':
        return 'Bench Press';
      case 'squat':
        return 'Squat';
      case 'deadlift':
        return 'Deadlift';
      case 'overhead':
        return 'Overhead Press';
      case 'row':
        return 'Row';
      case 'pullup':
        return 'Pull-ups';
      default:
        return slug.replaceAll('_', ' ').toUpperCase();
    }
  }

  static Future<CalibrationAttemptRecord?> loadPending() async {
    // First try local storage
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    CalibrationAttemptRecord? localRecord;

    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        localRecord = CalibrationAttemptRecord.fromJson(map);
      } catch (_) {
        // Invalid local data, ignore
      }
    }

    // Also check server for newer calibration (cross-device)
    final serverRecord = await _loadFromSupabase();

    // Use whichever is more recent
    if (localRecord == null) return serverRecord;
    if (serverRecord == null) return localRecord;

    final localTime = DateTime.parse(localRecord.tsIso);
    final serverTime = DateTime.parse(serverRecord.tsIso);

    return serverTime.isAfter(localTime) ? serverRecord : localRecord;
  }

  static Future<CalibrationAttemptRecord?> _loadFromSupabase() async {
    try {
      final client = supabase;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await client
          .from('calibration_resume')
          .select('*, exercises!inner(name)')
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final row = response.first;
        final exerciseName = row['exercises']['name'] as String;
        final exerciseId = mapNameToSlug(exerciseName);

        return CalibrationAttemptRecord(
          exerciseId: exerciseId,
          attemptIdx: row['attempt_idx'] as int,
          signedLoadKg: (row['signed_load_kg'] as num).toDouble(),
          effectiveLoadKg: (row['effective_load_kg'] as num).toDouble(),
          reps: row['reps'] as int,
          est1RmKg: (row['est1rm_kg'] as num).toDouble(),
          nextSignedKg: (row['next_signed_kg'] as num).toDouble(),
          tsIso: row['updated_at'] as String,
          checksum: _checksum(exerciseId, row['attempt_idx'] as int,
              (row['signed_load_kg'] as num).toDouble(), row['reps'] as int),
        );
      }
    } catch (e) {
      HWLog.event('calibration_load_from_server_failed',
          data: {'error': e.toString()});
    }
    return null;
  }

  static String mapNameToSlug(String name) {
    switch (name.toLowerCase()) {
      case 'bench press':
        return 'bench';
      case 'squat':
        return 'squat';
      case 'deadlift':
        return 'deadlift';
      case 'overhead press':
        return 'overhead';
      case 'row':
        return 'row';
      case 'pull-ups':
        return 'pullup';
      default:
        return name.toLowerCase().replaceAll(' ', '_');
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
