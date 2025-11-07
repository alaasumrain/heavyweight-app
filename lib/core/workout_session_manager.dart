import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../fortress/engine/models/set_data.dart';
import '../fortress/engine/workout_engine.dart';
import 'logging.dart';

/// Manages workout session persistence to survive app crashes/kills
class WorkoutSessionManager {
  static const String _sessionKey = 'hw_active_workout_session';
  static const String _sessionSetsKey = 'hw_session_sets';
  static const String _sessionStateKey = 'hw_session_state';

  /// Save active workout session
  static Future<void> saveActiveSession({
    required DailyWorkout workout,
    required int currentExerciseIndex,
    required int currentSet,
    required List<SetData> sessionSets,
    required bool isResting,
    int? restTimeRemaining,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save workout data
      await prefs.setString(
          _sessionKey,
          jsonEncode({
            'workout': workout.toJson(),
            'timestamp': DateTime.now().toIso8601String(),
            'version': '1.0',
          }));

      // Save current state
      await prefs.setString(
          _sessionStateKey,
          jsonEncode({
            'currentExerciseIndex': currentExerciseIndex,
            'currentSet': currentSet,
            'isResting': isResting,
            'restTimeRemaining': restTimeRemaining,
          }));

      // Save completed sets
      await prefs.setString(
          _sessionSetsKey,
          jsonEncode(
            sessionSets.map((set) => set.toJson()).toList(),
          ));

      HWLog.event('workout_session_saved', data: {
        'exerciseIndex': currentExerciseIndex,
        'set': currentSet,
        'completedSets': sessionSets.length,
      });
    } catch (e) {
      HWLog.event('workout_session_save_error', data: {'error': e.toString()});
    }
  }

  /// Load active workout session (if exists)
  static Future<WorkoutSessionRestore?> loadActiveSession() async {
    try {
      HWLog.event('workout_session_load_attempt');
      final prefs = await SharedPreferences.getInstance();

      final sessionData = prefs.getString(_sessionKey);
      final stateData = prefs.getString(_sessionStateKey);
      final setsData = prefs.getString(_sessionSetsKey);

      HWLog.event('workout_session_data_check', data: {
        'hasSessionData': sessionData != null,
        'hasStateData': stateData != null,
        'hasSetsData': setsData != null,
      });

      if (sessionData == null || stateData == null) {
        HWLog.event('workout_session_not_found');
        return null;
      }

      final sessionJson = jsonDecode(sessionData);
      final stateJson = jsonDecode(stateData);

      // Check if session is not too old (max 4 hours)
      final timestamp = DateTime.parse(sessionJson['timestamp']);
      final sessionAge = DateTime.now().difference(timestamp);
      HWLog.event('workout_session_age_check', data: {
        'sessionAgeMinutes': sessionAge.inMinutes,
        'sessionAgeHours': sessionAge.inHours,
        'isExpired': sessionAge.inHours > 4,
      });

      if (sessionAge.inHours > 4) {
        HWLog.event('workout_session_expired', data: {
          'sessionAgeHours': sessionAge.inHours,
        });
        await clearActiveSession();
        return null;
      }

      final workout = DailyWorkout.fromJson(sessionJson['workout']);
      final sessionSets = setsData != null
          ? (jsonDecode(setsData) as List)
              .map((json) => SetData.fromJson(json))
              .toList()
          : <SetData>[];

      HWLog.event('workout_session_restored', data: {
        'exerciseIndex': stateJson['currentExerciseIndex'],
        'set': stateJson['currentSet'],
        'completedSets': sessionSets.length,
      });

      return WorkoutSessionRestore(
        workout: workout,
        currentExerciseIndex: stateJson['currentExerciseIndex'],
        currentSet: stateJson['currentSet'],
        sessionSets: sessionSets,
        isResting: stateJson['isResting'] ?? false,
        restTimeRemaining: stateJson['restTimeRemaining'],
      );
    } catch (e) {
      HWLog.event('workout_session_load_error', data: {'error': e.toString()});
      await clearActiveSession();
      return null;
    }
  }

  /// Clear active session (when workout completes or is abandoned)
  static Future<void> clearActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Log what we're clearing before we clear it
      final hasSession = prefs.getString(_sessionKey) != null;
      final hasState = prefs.getString(_sessionStateKey) != null;
      final hasSets = prefs.getString(_sessionSetsKey) != null;

      HWLog.event('workout_session_clear_attempt', data: {
        'hadSession': hasSession,
        'hadState': hasState,
        'hadSets': hasSets,
      });

      await prefs.remove(_sessionKey);
      await prefs.remove(_sessionStateKey);
      await prefs.remove(_sessionSetsKey);

      HWLog.event('workout_session_cleared');
    } catch (e) {
      HWLog.event('workout_session_clear_error', data: {'error': e.toString()});
    }
  }

  /// Check if there's an active session
  static Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_sessionKey);
  }
}

/// Data class for restored workout sessions
class WorkoutSessionRestore {
  final DailyWorkout workout;
  final int currentExerciseIndex;
  final int currentSet;
  final List<SetData> sessionSets;
  final bool isResting;
  final int? restTimeRemaining;

  const WorkoutSessionRestore({
    required this.workout,
    required this.currentExerciseIndex,
    required this.currentSet,
    required this.sessionSets,
    required this.isResting,
    this.restTimeRemaining,
  });
}
