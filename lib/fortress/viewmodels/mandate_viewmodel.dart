import 'package:flutter/material.dart';
import '../engine/mandate_engine.dart';
import '../engine/models/set_data.dart';
import '../engine/storage/workout_repository_interface.dart';
import '../../backend/supabase/supabase.dart';


/// ViewModel for managing mandate screen state and business logic
/// Separates UI concerns from data and business logic
class MandateViewModel extends ChangeNotifier {
  final WorkoutRepositoryInterface repository;
  final MandateEngine engine;
  
  WorkoutMandate? _todaysMandate;
  bool _isLoading = true;
  bool _needsCalibration = false;
  String? _error;
  
  MandateViewModel({
    required this.repository,
    required this.engine,
  });
  
  // Getters
  WorkoutMandate? get todaysMandate => _todaysMandate;
  bool get isLoading => _isLoading;
  bool get needsCalibration => _needsCalibration;
  String? get error => _error;
  bool get hasMandate => _todaysMandate != null && !_todaysMandate!.isRestDay;
  
  /// Initialize the mandate system
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check authentication first
      if (supabase.auth.currentUser == null) {
        _setError('AUTHENTICATION_REQUIRED');
        return;
      }
      
      // Generate today's mandate (handles Day 1 automatically)
      final history = await repository.getHistory();
      final mandate = engine.generateMandate(history);
      
      _todaysMandate = mandate;
      _setLoading(false);
      
    } catch (e) {
      _setError('Failed to initialize mandate: $e');
      _setLoading(false);
    }
  }
  
  /// Refresh the mandate (called after workouts)
  Future<void> refresh() async {
    await initialize();
  }
  
  /// Begin today's protocol
  Future<List<SetData>?> beginProtocol() async {
    if (_todaysMandate == null) return null;
    
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