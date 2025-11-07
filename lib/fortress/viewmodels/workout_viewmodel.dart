import 'package:flutter/material.dart';
import '../engine/workout_engine.dart';
import '../engine/models/set_data.dart';
import '../engine/storage/workout_repository_interface.dart';
import '../../backend/supabase/supabase.dart';
import '../../backend/supabase/supabase_workout_repository.dart';
import '../../core/training_state.dart';
import '../../core/cache_service.dart';

/// ViewModel for managing workout screen state and business logic
/// Separates UI concerns from data and business logic
class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepositoryInterface repository;
  final WorkoutEngine engine;
  final CacheService _cache = CacheService();

  DailyWorkout? _todaysWorkout;
  bool _isLoading = true;
  bool _needsCalibration = false;
  String? _error;
  bool _hasInitialized = false;
  bool _disposed = false;

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
  Future<void> initialize(
      {String? preferredStartingDay, bool forceRefresh = false}) async {
    // Skip initialization if already done and not forcing refresh
    if (_hasInitialized && !forceRefresh) {
      // Check if we have cached workout first
      final cachedWorkout =
          await _cache.get<DailyWorkout>(CacheService.todaysWorkoutKey);
      if (cachedWorkout != null) {
        _todaysWorkout = cachedWorkout;
        _setLoading(false);
        return;
      }
    }

    _setLoading(true);
    _clearError();

    try {
      final requiresAuth = repository is SupabaseWorkoutRepository;
      if (requiresAuth && supabase.auth.currentUser == null) {
        _setError('AUTHENTICATION_REQUIRED');
        _setLoading(false);
        return;
      }

      // Generate today's workout (handles Day 1 automatically)
      final history = await repository.getHistory();
      final workout = await engine.generateDailyWorkout(history,
          preferredStartingDay: preferredStartingDay);

      _todaysWorkout = workout;

      // Cache the workout for 5 minutes in both memory and persistent storage
      await _cache.set(
          CacheService.todaysWorkoutKey, workout, CacheService.shortTTL);

      _hasInitialized = true;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize workout: $e');
      _setLoading(false);
    }
  }

  /// Refresh the workout (called after workouts)
  Future<void> refresh() async {
    await initialize(forceRefresh: true);
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

      // Mark day complete for sticky rotation and streaks
      await TrainingState.completeDay();

      // Invalidate all workout-related caches since data has changed
      await _cache.invalidateWorkoutData();

      // Refresh mandate after workout completion
      await refresh();
    } catch (e) {
      _setError('Failed to process workout results: $e');
    }
  }

  /// Get performance statistics
  Future<PerformanceStats> getStats() async {
    try {
      // Check cache first (both memory and persistent)
      final cachedStats =
          await _cache.get<PerformanceStats>(CacheService.performanceStatsKey);
      if (cachedStats != null) {
        return cachedStats;
      }

      // Fetch from repository and cache
      final stats = await repository.getStats();
      await _cache.set(
          CacheService.performanceStatsKey, stats, CacheService.mediumTTL);
      return stats;
    } catch (e) {
      _setError('Failed to get stats: $e');
      return PerformanceStats.empty();
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    if (_disposed) return;
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_disposed) return;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    // Cache service doesn't need explicit disposal as it's a singleton
    // Repository is managed by the provider and will be disposed there
    super.dispose();
  }
}
