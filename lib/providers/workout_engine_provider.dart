import 'package:flutter/material.dart';
import '/fortress/engine/workout_engine.dart';
import '/fortress/engine/storage/workout_repository_interface.dart';
import '/core/logging.dart';

/// Provider for the WorkoutEngine singleton
/// Ensures single instance across the app
class WorkoutEngineProvider extends ChangeNotifier {
  WorkoutEngine? _engine;
  
  /// Initialize with repository (must be called before using engine)
  void initialize(WorkoutRepositoryInterface repository) {
    _engine = WorkoutEngine(repository: repository);
    HWLog.event('engine_init', data: {
      'hasRepository': true,
      'engine': identityHashCode(_engine!).toString(),
    });
  }
  
  /// Get the workout engine instance
  WorkoutEngine get engine {
    if (_engine == null) {
      // Fallback to engine without repository if not initialized
      _engine = WorkoutEngine();
      HWLog.event('engine_lazy_init', data: {
        'hasRepository': false,
        'engine': identityHashCode(_engine!).toString(),
      });
    }
    return _engine!;
  }
  
  /// Check if engine is initialized with repository
  bool get isInitialized => _engine != null;
}
