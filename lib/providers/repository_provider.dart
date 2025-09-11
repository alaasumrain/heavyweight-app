import 'package:flutter/material.dart';
import '/fortress/engine/storage/workout_repository_interface.dart';
import '/fortress/engine/storage/workout_repository.dart';
import '/backend/supabase/supabase_workout_repository.dart';
import '/backend/supabase/supabase.dart';
import '/core/logging.dart';

/// Provider that manages workout repository dependency injection
/// Chooses between SharedPreferences and Supabase based on authentication state
class RepositoryProvider extends ChangeNotifier {
  WorkoutRepositoryInterface? _repository;
  bool _isInitialized = false;
  
  /// Get the current repository instance
  WorkoutRepositoryInterface? get repository => _repository;
  
  /// Check if repository is initialized
  bool get isInitialized => _isInitialized;
  
  /// Initialize the appropriate repository based on auth state
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check if Supabase is initialized and user is authenticated
      try {
        final user = supabase.auth.currentUser;
        
        if (user != null) {
          // Use Supabase repository for authenticated users
          _repository = SupabaseWorkoutRepository();
          HWLog.event('repo_init', data: {'type': 'supabase'});
        } else {
          // Use SharedPreferences repository for local/offline mode
          _repository = await WorkoutRepository.create();
          HWLog.event('repo_init', data: {'type': 'local'});
        }
      } catch (supabaseError) {
        // Supabase not initialized or error, use local repository
        _repository = await WorkoutRepository.create();
        HWLog.event('repo_init', data: {'type': 'local_fallback', 'error': supabaseError.toString()});
      }
      
      _isInitialized = true;
      HWLog.event('repo_init_complete', data: {'initialized': _isInitialized});
      notifyListeners();
    } catch (error) {
      // Fallback to SharedPreferences if anything fails
      print('Repository initialization error: $error');
      HWLog.event('repo_init_error', data: {'error': error.toString()});
      _repository = await WorkoutRepository.create();
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// Switch to Supabase repository after authentication
  Future<void> switchToSupabaseRepository() async {
    _repository = SupabaseWorkoutRepository();
    HWLog.event('repo_switch', data: {'to': 'supabase'});
    notifyListeners();
  }
  
  /// Switch to local repository (for testing or offline mode)
  Future<void> switchToLocalRepository() async {
    _repository = await WorkoutRepository.create();
    HWLog.event('repo_switch', data: {'to': 'local'});
    notifyListeners();
  }
  
  /// Reset repository (for testing)
  void reset() {
    _repository = null;
    _isInitialized = false;
    HWLog.event('repo_reset');
    notifyListeners();
  }
}
