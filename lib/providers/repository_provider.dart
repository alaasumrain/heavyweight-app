import 'package:flutter/material.dart';
import '/fortress/engine/storage/workout_repository_interface.dart';
import '/fortress/engine/storage/workout_repository.dart';
import '/backend/supabase/supabase_workout_repository.dart';
import '/backend/supabase/supabase.dart';

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
        } else {
          // Use SharedPreferences repository for local/offline mode
          _repository = await WorkoutRepository.create();
        }
      } catch (supabaseError) {
        // Supabase not initialized or error, use local repository
        _repository = await WorkoutRepository.create();
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (error) {
      // Fallback to SharedPreferences if anything fails
      print('Repository initialization error: $error');
      _repository = await WorkoutRepository.create();
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// Switch to Supabase repository after authentication
  Future<void> switchToSupabaseRepository() async {
    _repository = SupabaseWorkoutRepository();
    notifyListeners();
  }
  
  /// Switch to local repository (for testing or offline mode)
  Future<void> switchToLocalRepository() async {
    _repository = await WorkoutRepository.create();
    notifyListeners();
  }
  
  /// Reset repository (for testing)
  void reset() {
    _repository = null;
    _isInitialized = false;
    notifyListeners();
  }
}