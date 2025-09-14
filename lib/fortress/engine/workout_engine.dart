
import 'package:flutter/foundation.dart';
import 'models/exercise.dart';
import 'models/set_data.dart';
import 'storage/workout_repository_interface.dart';
import '../../core/logging.dart';
import '../../viewmodels/exercise_viewmodel.dart';
import '../../core/system_config.dart';
import '../../core/system_metrics.dart';

/// The 4-6 Rep Workout Engine
/// This is the brain of the Fortress system
/// It accepts TRUTH (including failure) and adjusts accordingly
class WorkoutEngine {
  final WorkoutRepositoryInterface? repository;
  
  // Defaults (can be overridden by system_config.json)
  static const double _majorReduction = 0.8;  // Complete failure (0 reps)
  static const double _minorReduction = 0.95; // Below mandate (1-3 reps)
  static const double _maintenance = 1.0;     // Within mandate (4-6 reps)
  static const double _increase = 1.025;      // Above mandate (7+ reps)
  
  /// Minimum weight increment (kg) - most gyms use 2.5kg plates
  static const double _minimumIncrement = 2.5;
  
  WorkoutEngine({this.repository});
  
  /// Calculate the next prescribed weight based on actual performance
  /// This is the core algorithm - it uses TRUTH to make decisions
  double calculateNextWeight(double currentWeight, int actualReps) {
    // Ensure config is loaded (no-op if already loaded)
    if (!SystemConfig.instance.isLoaded) {
      // Fire and forget; safe fallback to defaults if load fails
      SystemConfig.instance.load();
    }
    HWLog.event('engine_calc_next_weight_start', data: {
      'currentWeight': currentWeight,
      'actualReps': actualReps,
    });
    final cfg = SystemConfig.instance;
    double multiplier;
    
    if (actualReps == 0) {
      // Complete failure - significant reduction needed
      multiplier = cfg.multiplierFailure;
    } else if (actualReps < 4) {
      // Below mandate - moderate reduction
      multiplier = cfg.multiplierBelow;
    } else if (actualReps <= 6) {
      // Within mandate - perfect, maintain
      multiplier = cfg.multiplierMandate;
    } else {
      // Exceeded mandate - increase load
      multiplier = cfg.multiplierExceeded;
    }
    
    double nextWeight = currentWeight * multiplier;
    
    // Round to nearest increment available in gym
    final rounded = _roundToIncrement(nextWeight);
    HWLog.event('engine_calc_next_weight_done', data: {
      'multiplier': multiplier,
      'nextWeightRaw': nextWeight,
      'nextWeight': rounded,
    });
    return rounded;
  }
  
  /// Round weight to nearest available increment with safety checks
  double _roundToIncrement(double weight, [String? exerciseId]) {
    final inc = SystemConfig.instance.isLoaded
        ? (exerciseId != null
            ? SystemConfig.instance.incrementForExerciseKg(exerciseId)
            : SystemConfig.instance.roundingIncrementKg)
        : _minimumIncrement;
    final rounded = (weight / inc).round() * inc;
    if (exerciseId != null && SystemConfig.instance.isBodyweightExercise(exerciseId)) {
      // For bodyweight lifts allow 0 or negative (assistance)
      return rounded;
    }
    // Safety minimum - never go below bar weight (20kg) for non-BW barbell lifts
    return rounded < 20.0 ? 20.0 : rounded;
  }
  
  /// Calculate rest time based on performance
  /// Failure requires more recovery
  int calculateRestSeconds(int actualReps, int baseRest) {
    if (!SystemConfig.instance.isLoaded) {
      SystemConfig.instance.load();
    }
    final cfg = SystemConfig.instance;
    HWLog.event('engine_calc_rest_start', data: {
      'actualReps': actualReps,
      'baseRest': baseRest,
    });
    final s = actualReps == 0
        ? cfg.restForPerformance(category: 'failure')
        : (actualReps < 4
            ? cfg.restForPerformance(category: 'below')
            : cfg.restForPerformance(category: 'mandate'));
    HWLog.event('engine_calc_rest_done', data: {'rest': s});
    return s;
  }
  
  /// Determine next exercise based on rotation
  /// A/B split: Push/Pull alternation
  Exercise selectNextExercise(List<SetData> recentSets) {
    HWLog.event('engine_select_next_exercise_start', data: {
      'recentSetsCount': recentSets.length,
    });
    if (recentSets.isEmpty) {
      // First exercise - start with squat
      HWLog.event('engine_select_next_exercise_done', data: {'exercise': Exercise.bigSix[0].id});
      return Exercise.bigSix[0];
    }
    
    // Get last exercise
    final lastExerciseId = recentSets.last.exerciseId;
    final lastExercise = Exercise.bigSix.firstWhere(
      (e) => e.id == lastExerciseId,
      orElse: () => Exercise.bigSix[0],
    );
    
    // Rotate through Big Six
    final currentIndex = Exercise.bigSix.indexOf(lastExercise);
    final nextIndex = (currentIndex + 1) % Exercise.bigSix.length;
    
    final next = Exercise.bigSix[nextIndex];
    HWLog.event('engine_select_next_exercise_done', data: {'exercise': next.id});
    return next;
  }
  
  /// Calculate prescribed weight for an exercise based on history
  double calculatePrescribedWeight(
    String exerciseId,
    List<SetData> history,
  ) {
    if (!SystemConfig.instance.isLoaded) {
      SystemConfig.instance.load();
    }
    HWLog.event('engine_calc_prescribed_weight_start', data: {
      'exerciseId': exerciseId,
      'historyCount': history.length,
    });
    // Get most recent set for this exercise
    final recentSets = history
        .where((s) => s.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (recentSets.isEmpty) {
      // No history - use default starting weight
      final cfgStart = SystemConfig.instance.startingWeightFor(exerciseId);
      if (cfgStart != null) {
        HWLog.event('engine_calc_prescribed_weight_default_cfg', data: {
          'exerciseId': exerciseId,
          'prescribed': cfgStart,
        });
        return _applyMinClamp(exerciseId, _roundToIncrement(cfgStart));
      }
      final exercise = Exercise.bigSix.firstWhere((e) => e.id == exerciseId, orElse: () => Exercise.bigSix[0]);
      HWLog.event('engine_calc_prescribed_weight_default', data: {
        'exerciseId': exercise.id,
        'prescribed': exercise.prescribedWeight,
      });
      return _applyMinClamp(exerciseId, exercise.prescribedWeight);
    }
    
    // Use most recent performance to calculate next weight
    final lastSet = recentSets.first;
    final w = calculateNextWeight(lastSet.weight, lastSet.actualReps);
    HWLog.event('engine_calc_prescribed_weight_done', data: {
      'exerciseId': exerciseId,
      'lastWeight': lastSet.weight,
      'lastReps': lastSet.actualReps,
      'prescribed': w,
    });
    return _applyMinClamp(exerciseId, w);
  }

  double _applyMinClamp(String exerciseId, double weight) {
    if (SystemConfig.instance.isLoaded && SystemConfig.instance.isBodyweightExercise(exerciseId)) {
      return weight; // allow 0 or negative for BW assistance
    }
    final minClamp = SystemConfig.instance.isLoaded
        ? SystemConfig.instance.minClampForExerciseKg(exerciseId)
        : 20.0;
    return weight < minClamp ? minClamp : weight;
  }
  
  /// Check if an exercise has been calibrated
  bool isExerciseCalibrated(String exerciseId, List<SetData> history) {
    return history.any((s) => s.exerciseId == exerciseId);
  }
  
  /// Estimate weights for all exercises based on one known exercise
  Map<String, double> estimateWeightsFromBenchPress(double benchPress5RM) {
    if (!SystemConfig.instance.isLoaded) {
      SystemConfig.instance.load();
    }
    final cfg = SystemConfig.instance;
    return {
      'bench': benchPress5RM,
      'overhead': _roundToIncrement(benchPress5RM * cfg.benchRatioFor('overhead'), 'overhead'),
      'row': _roundToIncrement(benchPress5RM * cfg.benchRatioFor('row'), 'row'),
      'squat': _roundToIncrement(benchPress5RM * cfg.benchRatioFor('squat'), 'squat'),
      'deadlift': _roundToIncrement(benchPress5RM * cfg.benchRatioFor('deadlift'), 'deadlift'),
      'pullup': _roundToIncrement(benchPress5RM * cfg.benchRatioFor('pullup'), 'pullup'),
    };
  }
  
  /// Calculate next weight during calibration using Epley formula
  double calculateCalibrationWeight(double currentWeight, int actualReps) {
    if (actualReps == 5) {
      // Perfect - found 5RM
      return currentWeight;
    } else if (actualReps == 0) {
      // Complete failure - reduce significantly
      return _roundToIncrement(currentWeight * 0.7);
    } else if (actualReps >= 15) {
      // Way too light - be much more aggressive
      // 15+ reps means you can probably do 1.8-2.0x for 5 reps
      final estimatedFiveRM = currentWeight * 1.8;
      return _roundToIncrement(estimatedFiveRM);
    } else if (actualReps >= 12) {
      // Too light - 12-14 reps means roughly 1.6x for 5RM
      final estimatedFiveRM = currentWeight * 1.6;
      return _roundToIncrement(estimatedFiveRM);
    } else if (actualReps >= 8) {
      // Too light - 8-11 reps means roughly 1.3x for 5RM
      final estimatedFiveRM = currentWeight * 1.3;
      return _roundToIncrement(estimatedFiveRM);
    } else if (actualReps == 6 || actualReps == 7) {
      // Close - small adjustment
      return _roundToIncrement(currentWeight + 2.5);
    } else if (actualReps >= 4) {
      // Close but too heavy - small reduction
      return _roundToIncrement(currentWeight - 2.5);
    } else {
      // 1-3 reps - too heavy, bigger reduction
      return _roundToIncrement(currentWeight * 0.85);
    }
  }
  
  /// Generate today's workout based on history
  Future<DailyWorkout> generateDailyWorkout(List<SetData> history, {String? preferredStartingDay}) async {
    // Determine which exercises to do today using database (or fallback)
    final exercises = await _selectTodaysExercisesFromDatabase(history);
    
    // Get current day name
    final workoutCount = _getWorkoutCount(history);
    final dayInCycle = workoutCount % 5;
    final dayNames = ["CHEST", "BACK", "ARMS", "SHOULDERS", "LEGS"];
    final currentDayName = dayNames[dayInCycle];
    
    // Calculate prescribed weights
    final plannedExercises = <PlannedExercise>[];
    for (final exercise in exercises) {
      final weight = calculatePrescribedWeight(exercise.id, history);
      final isCalibrated = isExerciseCalibrated(exercise.id, history);
      plannedExercises.add(
        PlannedExercise(
          exercise: exercise,
          prescribedWeight: weight,
          targetSets: exercise.setsTarget ?? 3, // Use database target or default to 3
          restSeconds: exercise.restSeconds,
          needsCalibration: !isCalibrated,
        ),
      );
    }
    
    final workout = DailyWorkout(
      date: DateTime.now(),
      dayName: currentDayName,
      exercises: plannedExercises,
      isDay1: false,
    );

    // Compute and log metrics summary based on history (config-driven)
    try {
      final summary = SystemMetricsService.compute(history);
      HWLog.event('engine_metrics_summary', data: {
        'adherence_overall': summary.adherenceOverall,
        'adherence_windows': summary.adherenceWindow,
        'plateau_detected': summary.plateauDetected,
        'sessions_count': summary.sessionsCount,
      });
    } catch (_) {}
    return workout;
  }

  /// Apply exercise alternatives from ExerciseViewModel to a workout
  DailyWorkout applyExerciseAlternatives(DailyWorkout workout, ExerciseViewModel? exerciseViewModel) {
    if (exerciseViewModel == null || !exerciseViewModel.isLoaded) {
      HWLog.event('workout_engine_alternatives_skipped', data: {
        'reason': exerciseViewModel == null ? 'null_viewmodel' : 'not_loaded'
      });
      return workout;
    }

    final updatedExercises = <PlannedExercise>[];
    
    for (final plannedExercise in workout.exercises) {
      final originalExerciseId = plannedExercise.exercise.id;
      final alternativeExercise = exerciseViewModel.getExerciseWithAlternative(originalExerciseId);
      
      if (alternativeExercise != null && alternativeExercise.id != originalExerciseId) {
        // User has selected an alternative
        HWLog.event('workout_engine_alternative_applied', data: {
          'original': originalExerciseId,
          'alternative': alternativeExercise.id,
        });

        // Preserve training load using config ratios if enabled
        final cfg = SystemConfig.instance;
        double mappedWeight = alternativeExercise.prescribedWeight;
        if (!cfg.isLoaded) cfg.load();
        if (cfg.altPreserveLoad && (cfg.altOnSwap == 'map_from_current' || (cfg as dynamic)._data?['alternatives']?['policy'] == 'preserve_mapped')) {
          final ratio = cfg.alternativeRatio(originalExerciseId, alternativeExercise.id);
          if (ratio != null) {
            mappedWeight = _roundToIncrement(plannedExercise.prescribedWeight * ratio, alternativeExercise.id);
          } else {
            // Fallback to original weight if ratio missing (safer than default)
            mappedWeight = plannedExercise.prescribedWeight;
          }
        }

        updatedExercises.add(PlannedExercise(
          exercise: alternativeExercise,
          prescribedWeight: mappedWeight,
          targetSets: plannedExercise.targetSets,
          restSeconds: alternativeExercise.restSeconds,
          needsCalibration: plannedExercise.needsCalibration,
        ));
      } else {
        // Keep original exercise
        updatedExercises.add(plannedExercise);
      }
    }
    
    return DailyWorkout(
      date: workout.date,
      dayName: workout.dayName,
      exercises: updatedExercises,
      isDay1: workout.isDay1,
    );
  }
  
  /// Select exercises for today based on database and HEAVYWEIGHT 5-day rotation
  /// CHEST → BACK → ARMS → SHOULDERS → LEGS
  Future<List<Exercise>> _selectTodaysExercisesFromDatabase(List<SetData> history) async {
    // If no repository, fall back to hardcoded exercises
    if (repository == null) {
      HWLog.event('workout_engine_no_repo');
      if (kDebugMode) {
        debugPrint('WorkoutEngine: No repository available, using fallback exercises');
      }
      return _selectTodaysExercises(history);
    }
    
    // Handle first-time users (no history)
    if (history.isEmpty) {
      if (!SystemConfig.instance.isLoaded) SystemConfig.instance.load();
      final order = SystemConfig.instance.rotationOrder;
      final dayName = order.isNotEmpty ? order.first : 'CHEST';
      // Try DB by configured day ID, else fallback to config/hardcoded
      final dayId = SystemConfig.instance.dayIdFor(dayName) ?? 1;
      try {
        final workoutDay = await repository!.fetchCompleteWorkoutDay(dayId);
        if (workoutDay != null && workoutDay.exercises.isNotEmpty) {
          return workoutDay.exercises.map((de) => de.exercise).toList();
        }
      } catch (_) {}
      // Fallback to config-defined or hardcoded lists
      final ids = SystemConfig.instance.dayExercises(dayName);
      if (ids.isNotEmpty) {
        return ids.map(_resolveExerciseById).whereType<Exercise>().toList();
      }
      return Exercise.chestExercises;
    }
    
    // Get last workout date
    final lastWorkout = history.last.timestamp;
    
    // Enforce minimum rest only if we have prior session
    final daysSinceLastWorkout = DateTime.now().difference(lastWorkout).inDays;
    if (daysSinceLastWorkout < 1) {
      return []; // Rest day
    }
    
    // Determine day via config rotation
    if (!SystemConfig.instance.isLoaded) {
      SystemConfig.instance.load();
    }
    final order = SystemConfig.instance.rotationOrder;
    final workoutCount = _getWorkoutCount(history);
    final dayInCycle = workoutCount % order.length;
    final dayName = order[dayInCycle];
    // Map to DB day id if available
    int? workoutDayId = SystemConfig.instance.dayIdFor(dayName);
    workoutDayId ??= dayInCycle + 1; // fallback 1-5
    
    try {
      HWLog.event('workout_engine_fetch_day_start', data: {'dayId': workoutDayId});
      if (kDebugMode) {
        debugPrint('WorkoutEngine: Fetching workout day $workoutDayId from database');
      }
      final workoutDay = await repository!.fetchCompleteWorkoutDay(workoutDayId);
      if (workoutDay != null && workoutDay.exercises.isNotEmpty) {
        HWLog.event('workout_engine_fetch_day_success', data: {
          'dayId': workoutDayId,
          'exerciseCount': workoutDay.exercises.length
        });
        if (kDebugMode) {
          debugPrint('WorkoutEngine: Found ${workoutDay.exercises.length} exercises for workout day $workoutDayId');
        }
        return workoutDay.exercises.map((de) => de.exercise).toList();
      } else {
        HWLog.event('workout_engine_fetch_day_empty', data: {'dayId': workoutDayId});
        if (kDebugMode) {
          debugPrint('WorkoutEngine: No exercises found for workout day $workoutDayId in database');
        }
      }
    } catch (e) {
      HWLog.event('workout_engine_fetch_day_error', data: {
        'dayId': workoutDayId,
        'error': e.toString()
      });
      if (kDebugMode) {
        debugPrint('WorkoutEngine: Failed to fetch workout day $workoutDayId from database: $e');
      }
    }
    
    // Fallback to hardcoded exercises if database fails
    HWLog.event('workout_engine_fallback_day', data: {'dayId': workoutDayId});
    return _selectTodaysExercises(history);
  }

  /// Select exercises for today based on HEAVYWEIGHT 5-day rotation (fallback)
  /// CHEST → BACK → ARMS → SHOULDERS → LEGS
  List<Exercise> _selectTodaysExercises(List<SetData> history) {
    // Handle first-time users (no history)
    if (history.isEmpty) {
      if (!SystemConfig.instance.isLoaded) SystemConfig.instance.load();
      final order = SystemConfig.instance.rotationOrder;
      final dayName = order.isNotEmpty ? order.first : 'CHEST';
      final ids = SystemConfig.instance.dayExercises(dayName);
      if (ids.isNotEmpty) {
        return ids.map(_resolveExerciseById).whereType<Exercise>().toList();
      }
      return Exercise.chestExercises;
    }
    
    // Get last workout date
    final lastWorkout = history.last.timestamp;
    
    // Enforce minimum rest for returning users
    final daysSinceLastWorkout = DateTime.now().difference(lastWorkout).inDays;
    if (daysSinceLastWorkout < 1) {
      return []; // Rest day
    }
    
    // HEAVYWEIGHT 5-day rotation: CHEST → BACK → ARMS → SHOULDERS → LEGS
    final workoutCount = _getWorkoutCount(history);
    final order = SystemConfig.instance.rotationOrder;
    final dayInCycle = workoutCount % order.length;
    final dayName = order[dayInCycle];
    final ids = SystemConfig.instance.dayExercises(dayName);
    if (ids.isEmpty) {
      // Fallback to legacy hardcoded sets if config missing
      switch (dayName.toUpperCase()) {
        case 'CHEST':
          return Exercise.chestExercises;
        case 'BACK':
          return [Exercise.bigSix[1], Exercise.bigSix[4], Exercise.bigSix[5]];
        case 'ARMS':
          return [Exercise.bigSix[5], Exercise.bigSix[3]];
        case 'SHOULDERS':
          return [Exercise.bigSix[3], Exercise.bigSix[4]];
        case 'LEGS':
          return [Exercise.bigSix[0], Exercise.bigSix[1]];
        default:
          return [Exercise.bigSix[2]];
      }
    }
    return ids.map(_resolveExerciseById).whereType<Exercise>().toList();
  }
  
  /// Count unique workout sessions
  int _getWorkoutCount(List<SetData> history) {
    final uniqueDates = history
        .map((s) => DateTime(
              s.timestamp.year,
              s.timestamp.month,
              s.timestamp.day,
            ))
        .toSet();
    return uniqueDates.length;
  }

  /// Get starting day name from user preference
  String _getStartingDayName(String? preferredStartingDay) {
    switch (preferredStartingDay?.toLowerCase()) {
      case 'chest': return 'chest';
      case 'back': return 'back';
      case 'arms': return 'arms';
      case 'shoulders': return 'shoulders';
      case 'legs': return 'legs';
      default: return 'chest'; // Default fallback
    }
  }

  /// Get exercises for a specific day
  List<Exercise> _getExercisesForDay(String dayName) {
    final ids = SystemConfig.instance.dayExercises(dayName);
    if (ids.isNotEmpty) {
      return ids.map(_resolveExerciseById).whereType<Exercise>().toList();
    }
    switch (dayName.toLowerCase()) {
      case 'chest':
        return Exercise.chestExercises;
      case 'back':
        return [Exercise.bigSix[1], Exercise.bigSix[4], Exercise.bigSix[5]];
      case 'arms':
        return [Exercise.bigSix[5], Exercise.bigSix[3]];
      case 'shoulders':
        return [Exercise.bigSix[3], Exercise.bigSix[4]];
      case 'legs':
        return [Exercise.bigSix[0], Exercise.bigSix[1]];
      default:
        return [Exercise.bigSix[2]];
    }
  }

  /// Resolve exercise by id from known static lists
  Exercise? _resolveExerciseById(String id) {
    final fromBigSix = Exercise.bigSix.where((e) => e.id == id);
    if (fromBigSix.isNotEmpty) return fromBigSix.first;
    final fromChest = Exercise.chestExercises.where((e) => e.id == id);
    if (fromChest.isNotEmpty) return fromChest.first;
    return null;
  }
  
  /// Calibration protocol for new users
  /// Finds their true 4-6 rep max for each exercise
  CalibrationProtocol generateCalibrationProtocol() {
    return CalibrationProtocol(
      exercises: Exercise.bigSix,
      instructions: '''
CALIBRATION PROTOCOL

You will establish your baseline for each of the Big Six movements.

For each exercise:
1. Start with the bar (or suggested weight)
2. Perform 5 reps
3. If easy, add weight and repeat
4. Continue until you find a weight where 6 reps is your absolute limit
5. This is your starting mandate weight

Rest 3-5 minutes between attempts.
Be honest. The system needs truth to serve you.
      ''',
    );
  }
}

/// A single planned exercise
class PlannedExercise {
  final Exercise exercise;
  final double prescribedWeight;
  final int targetSets;
  final int restSeconds;
  final bool needsCalibration;
  
  const PlannedExercise({
    required this.exercise,
    required this.prescribedWeight,
    required this.targetSets,
    required this.restSeconds,
    this.needsCalibration = false,
  });
}

/// Today's daily workout
class DailyWorkout {
  final DateTime date;
  final String dayName;
  final List<PlannedExercise> exercises;
  final bool isDay1;
  
  const DailyWorkout({
    required this.date,
    required this.dayName,
    required this.exercises,
    this.isDay1 = false,
  });
  
  bool get isRestDay => exercises.isEmpty;
}

/// Calibration protocol for new users
class CalibrationProtocol {
  final List<Exercise> exercises;
  final String instructions;
  
  const CalibrationProtocol({
    required this.exercises,
    required this.instructions,
  });
}
