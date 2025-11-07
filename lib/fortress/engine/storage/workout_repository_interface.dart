import '../models/set_data.dart';
import '../models/workout_day.dart';

/// Abstract interface for workout data persistence
/// Implementations can use SharedPreferences, SQLite, Supabase, etc.
abstract class WorkoutRepositoryInterface {
  /// Save a completed set
  Future<void> saveSet(SetData set);

  /// Get all workout history
  Future<List<SetData>> getHistory();

  /// Get history for specific exercise
  Future<List<SetData>> getExerciseHistory(String exerciseId);

  /// Get most recent workout session
  Future<WorkoutSession?> getLastSession();

  /// Save calibration completion
  Future<void> markCalibrationComplete();

  /// Check if calibration is complete
  Future<bool> isCalibrationComplete();

  /// Save calibrated weights for exercises
  Future<void> saveExerciseWeights(Map<String, double> weights);

  /// Get calibrated weights
  Future<Map<String, double>> getExerciseWeights();

  /// Get last weight used for an exercise
  Future<double?> getLastWeight(String exerciseId);

  /// Clear all data (for testing or reset)
  Future<void> clearAll();

  /// Get performance statistics
  Future<PerformanceStats> getStats();

  /// Get the latest SetData for each exerciseId provided
  /// Returns a map of exerciseId -> most recent SetData
  Future<Map<String, SetData>> getLastForExercises(
          Set<String> exerciseIds) async =>
      {};

  /// Fetch workout days from database
  Future<List<WorkoutDay>> fetchWorkoutDays() async => [];

  /// Fetch complete workout day with exercises
  Future<WorkoutDay?> fetchCompleteWorkoutDay(int workoutDayId) async => null;

  /// Dispose resources and clean up
  void dispose() {} // Default empty implementation
}

/// Performance statistics
class PerformanceStats {
  final int totalSets;
  final int mandateSets;
  final int failureSets;
  final int exceededSets;
  final double totalVolume;
  final int workoutDays;
  final double mandateAdherence; // Percentage

  const PerformanceStats({
    required this.totalSets,
    required this.mandateSets,
    required this.failureSets,
    required this.exceededSets,
    required this.totalVolume,
    required this.workoutDays,
    required this.mandateAdherence,
  });

  factory PerformanceStats.empty() {
    return const PerformanceStats(
      totalSets: 0,
      mandateSets: 0,
      failureSets: 0,
      exceededSets: 0,
      totalVolume: 0,
      workoutDays: 0,
      mandateAdherence: 0,
    );
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'totalSets': totalSets,
      'mandateSets': mandateSets,
      'failureSets': failureSets,
      'exceededSets': exceededSets,
      'totalVolume': totalVolume,
      'workoutDays': workoutDays,
      'mandateAdherence': mandateAdherence,
    };
  }

  /// Create from JSON
  factory PerformanceStats.fromJson(Map<String, dynamic> json) {
    return PerformanceStats(
      totalSets: json['totalSets'] ?? 0,
      mandateSets: json['mandateSets'] ?? 0,
      failureSets: json['failureSets'] ?? 0,
      exceededSets: json['exceededSets'] ?? 0,
      totalVolume: (json['totalVolume'] ?? 0).toDouble(),
      workoutDays: json['workoutDays'] ?? 0,
      mandateAdherence: (json['mandateAdherence'] ?? 0).toDouble(),
    );
  }
}
