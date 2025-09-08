import 'package:flutter/material.dart';
import '../engine/workout_engine.dart';
import '../engine/models/set_data.dart';
import '../engine/storage/workout_repository_interface.dart';
import '../../backend/supabase/supabase.dart';


/// ViewModel for managing workout screen state and business logic
/// Separates UI concerns from data and business logic
class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepositoryInterface repository;
  final WorkoutEngine engine;
  
  DailyWorkout? _todaysWorkout;
  bool _isLoading = true;
  bool _needsCalibration = false;
  String? _error;
  
  WorkoutViewModel({
    required this.repository,
    required this.engine,
  });
  
  // Getters
  DailyWorkout? get todaysWorkout => _todaysWorkout;
  bool get isLoading => _isLoading;
  bool get needsCalibration => _needsCalibration;
  String? get error => _error;
  bool get hasWorkout => _todaysWorkout != null && !_todaysWorkout!.isRestDay;
  
  /// Initialize the workout system
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check authentication first
      if (supabase.auth.currentUser == null) {
        _setError('AUTHENTICATION_REQUIRED');
        return;
      }
      
      // Generate today's workout (handles Day 1 automatically)
      final history = await repository.getHistory();
      final workout = await engine.generateDailyWorkout(history);
      
      _todaysWorkout = workout;
      _setLoading(false);
      
    } catch (e) {
      _setError('Failed to initialize workout: $e');
      _setLoading(false);
    }
  }
  
  /// Refresh the workout (called after workouts)
  Future<void> refresh() async {
    await initialize();
  }
  
  /// Begin today's protocol
  Future<List<SetData>?> beginProtocol() async {
    if (_todaysWorkout == null) return null;
    
    try {
      // This would typically navigate to protocol screen
      // For now, return null to indicate navigation should happen
      return null;
    } catch (e) {
      _setError('Failed to begin protocol: $e');
      return null;
    }
  }
  
  /// Begin calibration process
  Future<bool> beginCalibration() async {
    try {
      // This would typically navigate to calibration screen
      // For now, return false to indicate navigation should happen
      return false;
    } catch (e) {
      _setError('Failed to begin calibration: $e');
      return false;
    }
  }
  
  /// Mark calibration as complete
  Future<void> markCalibrationComplete() async {
    try {
      await repository.markCalibrationComplete();
      _needsCalibration = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to mark calibration complete: $e');
    }
  }
  
  /// Check if calibration is needed
  Future<void> checkCalibrationStatus() async {
    try {
      final isComplete = await repository.isCalibrationComplete();
      _needsCalibration = !isComplete;
      notifyListeners();
    } catch (e) {
      _setError('Failed to check calibration status: $e');
    }
  }
  
  /// Process completed workout results
  Future<void> processWorkoutResults(List<SetData> results) async {
    if (results.isEmpty) return;
    
    try {
      // Save all sets
      for (final set in results) {
        await repository.saveSet(set);
      }
      
      // Refresh mandate after workout completion
      await refresh();
      
    } catch (e) {
      _setError('Failed to process workout results: $e');
    }
  }
  
  /// Get performance statistics
  Future<PerformanceStats> getStats() async {
    try {
      return await repository.getStats();
    } catch (e) {
      _setError('Failed to get stats: $e');
      return PerformanceStats.empty();
    }
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