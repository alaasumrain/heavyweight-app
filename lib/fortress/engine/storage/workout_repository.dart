import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/set_data.dart';
import '../models/workout_day.dart';
import 'workout_repository_interface.dart';

/// Repository for persisting workout data
/// Uses SharedPreferences for simplicity - can be upgraded to SQLite later
class WorkoutRepository implements WorkoutRepositoryInterface {
  static const String _historyKey = 'fortress_workout_history';
  static const String _calibrationKey = 'fortress_calibration_complete';
  static const String _exerciseWeightsKey = 'fortress_exercise_weights';
  
  final SharedPreferences _prefs;
  
  WorkoutRepository(this._prefs);
  
  /// Factory constructor to create repository
  static Future<WorkoutRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return WorkoutRepository(prefs);
  }
  
  /// Save a completed set
  Future<void> saveSet(SetData set) async {
    final history = await getHistory();
    history.add(set);
    
    final jsonList = history.map((s) => s.toJson()).toList();
    await _prefs.setString(_historyKey, jsonEncode(jsonList));
  }
  
  /// Get all workout history
  Future<List<SetData>> getHistory() async {
    final jsonString = _prefs.getString(_historyKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => SetData.fromJson(json)).toList();
  }
  
  /// Get history for specific exercise
  Future<List<SetData>> getExerciseHistory(String exerciseId) async {
    final history = await getHistory();
    return history.where((s) => s.exerciseId == exerciseId).toList();
  }
  
  /// Get most recent workout session
  Future<WorkoutSession?> getLastSession() async {
    final history = await getHistory();
    if (history.isEmpty) return null;
    
    // Group sets by date
    final sessionMap = <DateTime, List<SetData>>{};
    for (final set in history) {
      final date = DateTime(
        set.timestamp.year,
        set.timestamp.month,
        set.timestamp.day,
      );
      sessionMap[date] ??= [];
      sessionMap[date]!.add(set);
    }
    
    // Get most recent date
    final dates = sessionMap.keys.toList()..sort();
    if (dates.isEmpty) return null;
    
    final lastDate = dates.last;
    final lastSets = sessionMap[lastDate]!;
    
    return WorkoutSession(
      id: 'session_${lastDate.millisecondsSinceEpoch}',
      date: lastDate,
      sets: lastSets,
      completed: true,
    );
  }
  
  /// Save calibration completion
  Future<void> markCalibrationComplete() async {
    await _prefs.setBool(_calibrationKey, true);
  }
  
  /// Check if calibration is complete
  Future<bool> isCalibrationComplete() async {
    return _prefs.getBool(_calibrationKey) ?? false;
  }
  
  /// Save calibrated weights for exercises
  Future<void> saveExerciseWeights(Map<String, double> weights) async {
    await _prefs.setString(_exerciseWeightsKey, jsonEncode(weights));
  }
  
  /// Get calibrated weights
  Future<Map<String, double>> getExerciseWeights() async {
    final jsonString = _prefs.getString(_exerciseWeightsKey);
    if (jsonString == null) return {};
    
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return json.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }
  
  /// Get last weight used for an exercise
  Future<double?> getLastWeight(String exerciseId) async {
    final history = await getExerciseHistory(exerciseId);
    if (history.isEmpty) return null;
    
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history.first.weight;
  }
  
  /// Clear all data (for testing or reset)
  Future<void> clearAll() async {
    await _prefs.remove(_historyKey);
    await _prefs.remove(_calibrationKey);
    await _prefs.remove(_exerciseWeightsKey);
  }
  
  /// Get performance statistics
  Future<PerformanceStats> getStats() async {
    final history = await getHistory();
    if (history.isEmpty) {
      return PerformanceStats.empty();
    }
    
    int totalSets = history.length;
    int mandateSets = history.where((s) => s.metMandate).length;
    int failureSets = history.where((s) => s.isFailure).length;
    int exceededSets = history.where((s) => s.exceededMandate).length;
    
    // Calculate total volume (weight × reps)
    double totalVolume = 0;
    for (final set in history) {
      totalVolume += set.weight * set.actualReps;
    }
    
    // Get unique workout days
    final uniqueDays = history
        .map((s) => DateTime(
              s.timestamp.year,
              s.timestamp.month,
              s.timestamp.day,
            ))
        .toSet()
        .length;
    
    return PerformanceStats(
      totalSets: totalSets,
      mandateSets: mandateSets,
      failureSets: failureSets,
      exceededSets: exceededSets,
      totalVolume: totalVolume,
      workoutDays: uniqueDays,
      mandateAdherence: (mandateSets / totalSets) * 100,
    );
  }
  
  /// Fetch workout days from database (SharedPreferences implementation returns empty)
  @override
  Future<List<WorkoutDay>> fetchWorkoutDays() async {
    // SharedPreferences doesn't support database-driven exercises
    return [];
  }
  
  /// Fetch complete workout day with exercises (SharedPreferences implementation returns null)
  @override
  Future<WorkoutDay?> fetchCompleteWorkoutDay(int workoutDayId) async {
    // SharedPreferences doesn't support database-driven exercises
    return null;
  }

  @override
  void dispose() {
    // No resources to dispose for SharedPreferences implementation
  }
}

