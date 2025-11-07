import 'package:shared_preferences/shared_preferences.dart';
import '../backend/supabase/supabase.dart';
import 'logging.dart';

/// Training state management for sticky day persistence
/// Keeps track of which training day user is on, survives reinstalls
class TrainingState {
  static const String _keyLastAssignedDay = 'training_last_assigned_day';
  static const String _keyLastAssignedAt = 'training_last_assigned_at';
  static const String _keyLastCompletedAt = 'training_last_completed_at';
  static const String _keyCurrentStreak = 'training_current_streak';

  /// Save training day assignment (when user starts a workout)
  static Future<void> assignDay(String dayName) async {
    final now = DateTime.now();

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastAssignedDay, dayName);
    await prefs.setString(_keyLastAssignedAt, now.toIso8601String());

    // Also save to server for cross-device sync
    _syncToServer(
      lastAssignedDay: dayName,
      lastAssignedAt: now,
    );

    HWLog.event('training_day_assigned', data: {'day': dayName});
  }

  /// Mark training day as completed
  static Future<void> completeDay() async {
    final now = DateTime.now();

    // Update streak
    final prefs = await SharedPreferences.getInstance();
    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final newStreak = currentStreak + 1;

    await prefs.setString(_keyLastCompletedAt, now.toIso8601String());
    await prefs.setInt(_keyCurrentStreak, newStreak);

    // Sync to server
    _syncToServer(
      lastCompletedAt: now,
      currentStreak: newStreak,
    );

    HWLog.event('training_day_completed', data: {'streak': newStreak});
  }

  /// Get last assigned training day (for sticky rotation)
  static Future<String?> getLastAssignedDay() async {
    // Check server first for cross-device consistency
    final serverState = await _loadFromServer();
    if (serverState != null && serverState['last_assigned_day'] != null) {
      return serverState['last_assigned_day'] as String;
    }

    // Fallback to local
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastAssignedDay);
  }

  /// Get days since last workout (for streak tracking)
  static Future<int> getDaysSinceLastWorkout() async {
    final serverState = await _loadFromServer();
    String? lastCompletedStr;

    if (serverState != null && serverState['last_completed_at'] != null) {
      lastCompletedStr = serverState['last_completed_at'] as String;
    } else {
      final prefs = await SharedPreferences.getInstance();
      lastCompletedStr = prefs.getString(_keyLastCompletedAt);
    }

    if (lastCompletedStr == null) return 999; // Never worked out

    final lastCompleted = DateTime.parse(lastCompletedStr);
    final daysDiff = DateTime.now().difference(lastCompleted).inDays;

    return daysDiff;
  }

  /// Get current streak
  static Future<int> getCurrentStreak() async {
    final serverState = await _loadFromServer();
    if (serverState != null && serverState['current_streak'] != null) {
      return serverState['current_streak'] as int;
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentStreak) ?? 0;
  }

  /// Sync training state to Supabase
  static Future<void> _syncToServer({
    String? lastAssignedDay,
    DateTime? lastAssignedAt,
    DateTime? lastCompletedAt,
    int? currentStreak,
  }) async {
    try {
      final client = supabase;
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        return;
      }

      final data = <String, dynamic>{
        'user_id': userId,
      };

      if (lastAssignedDay != null) {
        data['last_assigned_day'] = lastAssignedDay;
      }
      if (lastAssignedAt != null) {
        data['last_assigned_at'] = lastAssignedAt.toIso8601String();
      }
      if (lastCompletedAt != null) {
        data['last_completed_at'] = lastCompletedAt.toIso8601String();
      }
      if (currentStreak != null) {
        data['current_streak'] = currentStreak;
      }

      data['updated_at'] = DateTime.now().toIso8601String();

      await client.from('user_training_state').upsert(data);

      HWLog.event('training_state_synced',
          data: {'fields': data.keys.toList()});
    } catch (e) {
      HWLog.event('training_state_sync_failed', data: {'error': e.toString()});
      // Don't throw - local save already succeeded
    }
  }

  /// Load training state from server
  static Future<Map<String, dynamic>?> _loadFromServer() async {
    try {
      final client = supabase;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await client
          .from('user_training_state')
          .select('*')
          .eq('user_id', userId)
          .single();

      return response;
    } catch (e) {
      // No state exists yet or network error
      return null;
    }
  }

  /// Reset streak (if user misses too many days)
  static Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentStreak, 0);

    _syncToServer(currentStreak: 0);

    HWLog.event('training_streak_reset');
  }

  /// Clear all training state
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastAssignedDay);
    await prefs.remove(_keyLastAssignedAt);
    await prefs.remove(_keyLastCompletedAt);
    await prefs.remove(_keyCurrentStreak);

    try {
      final client = supabase;
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        await client.from('user_training_state').delete().eq('user_id', userId);
      }
    } catch (e) {
      // Ignore server errors during clear
    }

    HWLog.event('training_state_cleared');
  }
}
