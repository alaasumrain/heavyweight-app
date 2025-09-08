import 'package:flutter/material.dart';
import '../engine/models/set_data.dart';
import '../engine/storage/workout_repository_interface.dart';
import '../engine/models/exercise.dart';

/// ViewModel for the logbook screen
/// Handles fetching and organizing workout session history
class LogbookViewModel extends ChangeNotifier {
  final WorkoutRepositoryInterface repository;
  
  List<WorkoutSession> _sessions = [];
  bool _isLoading = true;
  String? _error;
  PerformanceStats _stats = PerformanceStats.empty();
  
  LogbookViewModel({
    required this.repository,
  });
  
  // Getters
  List<WorkoutSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PerformanceStats get stats => _stats;
  bool get hasSessions => _sessions.isNotEmpty;
  
  /// Initialize the logbook
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Get all workout history
      final history = await repository.getHistory();
      
      // Get performance stats
      final stats = await repository.getStats();
      
      // Group sets by date to create sessions
      final sessionMap = <String, List<SetData>>{};
      
      for (final set in history) {
        final dateKey = _formatDateKey(set.timestamp);
        sessionMap[dateKey] = (sessionMap[dateKey] ?? [])..add(set);
      }
      
      // Convert to WorkoutSession objects, sorted by date (newest first)
      final sessions = sessionMap.entries
          .map((entry) => _createSessionFromSets(entry.key, entry.value))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      
      _sessions = sessions.take(25).toList(); // Limit to 25 most recent
      _stats = stats;
      _setLoading(false);
      
    } catch (e) {
      _setError('Failed to load workout history: $e');
      _setLoading(false);
    }
  }
  
  /// Create a WorkoutSession from grouped SetData
  WorkoutSession _createSessionFromSets(String dateKey, List<SetData> sets) {
    // Sort sets by set number and timestamp
    sets.sort((a, b) {
      final exerciseCompare = a.exerciseId.compareTo(b.exerciseId);
      if (exerciseCompare != 0) return exerciseCompare;
      return a.setNumber.compareTo(b.setNumber);
    });
    
    final date = sets.first.timestamp;
    final sessionId = dateKey;
    
    return WorkoutSession(
      id: sessionId,
      date: date,
      sets: sets,
      completed: true,
    );
  }
  
  /// Format date as YYYY-MM-DD for grouping
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Get display name for workout day
  String getWorkoutDayName(WorkoutSession session) {
    // Get unique exercises in this session
    final uniqueExercises = session.sets
        .map((s) => s.exerciseId)
        .toSet()
        .toList();
    
    // Determine day type based on exercises
    if (uniqueExercises.contains('bench') || uniqueExercises.contains('overhead')) {
      return 'CHEST';
    } else if (uniqueExercises.contains('deadlift') || uniqueExercises.contains('row')) {
      return 'BACK';
    } else if (uniqueExercises.contains('squat')) {
      return 'LEGS';
    } else {
      return 'MIXED';
    }
  }
  
  /// Get session duration estimate
  String getSessionDuration(WorkoutSession session) {
    if (session.sets.isEmpty) return '0 MIN';
    
    // Estimate: 3 minutes rest between sets + 1 minute per set
    final estimatedMinutes = (session.sets.length * 4).clamp(15, 90);
    return '$estimatedMinutes MIN';
  }
  
  /// Get total volume for a session
  double getSessionVolume(WorkoutSession session) {
    return session.sets.fold(0.0, (sum, set) => sum + (set.weight * set.actualReps));
  }
  
  /// Get exercise summary for session (e.g., "BENCH: 3x5 @ 100kg")
  List<String> getExerciseSummary(WorkoutSession session) {
    final exerciseGroups = <String, List<SetData>>{};
    
    // Group sets by exercise
    for (final set in session.sets) {
      exerciseGroups[set.exerciseId] = (exerciseGroups[set.exerciseId] ?? [])..add(set);
    }
    
    // Create summaries
    final summaries = <String>[];
    for (final entry in exerciseGroups.entries) {
      final exerciseId = entry.key;
      final exerciseSets = entry.value;
      
      // Get exercise name
      final exercise = Exercise.bigSix.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => Exercise(id: exerciseId, name: exerciseId.toUpperCase(), muscleGroup: 'Unknown', prescribedWeight: 0, restSeconds: 180),
      );
      
      // Format as "EXERCISE: 3x5 @ 100kg"
      final setCount = exerciseSets.length;
      final weight = exerciseSets.first.weight;
      final avgReps = (exerciseSets.fold(0, (sum, s) => sum + s.actualReps) / setCount).round();
      
      summaries.add('${exercise.name.toUpperCase()}: ${setCount}x$avgReps @ ${weight}kg');
    }
    
    return summaries;
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}