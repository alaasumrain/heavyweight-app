
import 'models/exercise.dart';
import 'models/set_data.dart';
import 'models/workout_day.dart';
import 'storage/workout_repository_interface.dart';

/// The 4-6 Rep Workout Engine
/// This is the brain of the Fortress system
/// It accepts TRUTH (including failure) and adjusts accordingly
class WorkoutEngine {
  final WorkoutRepositoryInterface? repository;
  
  static const double _majorReduction = 0.7;  // Complete failure (0 reps)
  static const double _minorReduction = 0.9;  // Below mandate (1-3 reps)
  static const double _maintenance = 1.0;     // Within mandate (4-6 reps)
  static const double _increase = 1.05;       // Above mandate (7+ reps)
  
  /// Minimum weight increment (kg) - most gyms use 2.5kg plates
  static const double _minimumIncrement = 2.5;
  
  WorkoutEngine({this.repository});
  
  /// Calculate the next prescribed weight based on actual performance
  /// This is the core algorithm - it uses TRUTH to make decisions
  double calculateNextWeight(double currentWeight, int actualReps) {
    double multiplier;
    
    if (actualReps == 0) {
      // Complete failure - significant reduction needed
      multiplier = _majorReduction;
    } else if (actualReps < 4) {
      // Below mandate - moderate reduction
      multiplier = _minorReduction;
    } else if (actualReps <= 6) {
      // Within mandate - perfect, maintain
      multiplier = _maintenance;
    } else {
      // Exceeded mandate - increase load
      multiplier = _increase;
    }
    
    double nextWeight = currentWeight * multiplier;
    
    // Round to nearest increment available in gym
    return _roundToIncrement(nextWeight);
  }
  
  /// Round weight to nearest available increment
  double _roundToIncrement(double weight) {
    return (weight / _minimumIncrement).round() * _minimumIncrement;
  }
  
  /// Calculate rest time based on performance
  /// Failure requires more recovery
  int calculateRestSeconds(int actualReps, int baseRest) {
    if (actualReps == 0) {
      // Complete failure - maximum rest
      return 300; // 5 minutes
    } else if (actualReps < 4) {
      // Below mandate - extra rest
      return 240; // 4 minutes
    } else {
      // Standard rest for mandate performance
      return baseRest; // Usually 3 minutes
    }
  }
  
  /// Determine next exercise based on rotation
  /// A/B split: Push/Pull alternation
  Exercise selectNextExercise(List<SetData> recentSets) {
    if (recentSets.isEmpty) {
      // First exercise - start with squat
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
    
    return Exercise.bigSix[nextIndex];
  }
  
  /// Calculate prescribed weight for an exercise based on history
  double calculatePrescribedWeight(
    String exerciseId,
    List<SetData> history,
  ) {
    // Get most recent set for this exercise
    final recentSets = history
        .where((s) => s.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (recentSets.isEmpty) {
      // No history - use default starting weight
      final exercise = Exercise.bigSix.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => Exercise.bigSix[0],
      );
      return exercise.prescribedWeight;
    }
    
    // Use most recent performance to calculate next weight
    final lastSet = recentSets.first;
    return calculateNextWeight(lastSet.weight, lastSet.actualReps);
  }
  
  /// Check if an exercise has been calibrated
  bool isExerciseCalibrated(String exerciseId, List<SetData> history) {
    return history.any((s) => s.exerciseId == exerciseId);
  }
  
  /// Estimate weights for all exercises based on one known exercise
  Map<String, double> estimateWeightsFromBenchPress(double benchPress5RM) {
    return {
      'bench': benchPress5RM,
      'overhead': _roundToIncrement(benchPress5RM * 0.66),
      'row': _roundToIncrement(benchPress5RM * 0.80),
      'squat': _roundToIncrement(benchPress5RM * 1.20),
      'deadlift': _roundToIncrement(benchPress5RM * 1.50),
      'pullup': 0.0, // Start with bodyweight
    };
  }
  
  /// Calculate next weight during calibration
  double calculateCalibrationWeight(double currentWeight, int actualReps) {
    if (actualReps >= 20) {
      // Way too light
      return _roundToIncrement(currentWeight + 20);
    } else if (actualReps >= 10) {
      // Too light
      return _roundToIncrement(currentWeight + 10);
    } else if (actualReps >= 7) {
      // Getting closer
      return _roundToIncrement(currentWeight + 5);
    } else if (actualReps == 5) {
      // Perfect - found 5RM
      return currentWeight;
    } else if (actualReps < 5 && actualReps > 0) {
      // Too heavy
      return _roundToIncrement(currentWeight - 2.5);
    } else {
      // Complete failure
      return _roundToIncrement(currentWeight - 5);
    }
  }
  
  /// Generate today's workout based on history
  Future<DailyWorkout> generateDailyWorkout(List<SetData> history) async {
    // Check if this is Day 1 (no history)
    if (history.isEmpty) {
      // Day 1: CHEST DAY with calibration
      return DailyWorkout(
        date: DateTime.now(),
        dayName: "CHEST",
        exercises: [
          PlannedExercise(
            exercise: Exercise.bigSix[2], // Bench Press
            prescribedWeight: 20.0, // Start with empty bar
            targetSets: 1, // Finding 5RM is one "set"
            restSeconds: 180,
            needsCalibration: true,
          ),
          PlannedExercise(
            exercise: Exercise.bigSix[3], // Overhead Press
            prescribedWeight: 20.0, // Will be estimated after bench
            targetSets: 3,
            restSeconds: 180,
            needsCalibration: true,
          ),
        ],
        isDay1: true,
      );
    }
    
    // Determine which exercises to do today using database
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
    
    return DailyWorkout(
      date: DateTime.now(),
      dayName: currentDayName,
      exercises: plannedExercises,
      isDay1: false,
    );
  }
  
  /// Select exercises for today based on database and HEAVYWEIGHT 5-day rotation
  /// CHEST → BACK → ARMS → SHOULDERS → LEGS
  Future<List<Exercise>> _selectTodaysExercisesFromDatabase(List<SetData> history) async {
    // If no repository, fall back to hardcoded exercises
    if (repository == null) {
      print('WorkoutEngine: No repository available, using fallback exercises');
      return _selectTodaysExercises(history);
    }
    
    if (history.isEmpty) {
      // Day 1: CHEST - get from database
      try {
        print('WorkoutEngine: Fetching CHEST day from database (ID: 1)');
        final chestDay = await repository!.fetchCompleteWorkoutDay(1); // Assuming CHEST is ID 1
        if (chestDay != null && chestDay.exercises.isNotEmpty) {
          print('WorkoutEngine: Found ${chestDay.exercises.length} exercises for CHEST day');
          return chestDay.exercises.map((de) => de.exercise).toList();
        } else {
          print('WorkoutEngine: No exercises found for CHEST day in database');
        }
      } catch (e) {
        print('WorkoutEngine: Failed to fetch chest day from database: $e');
      }
      // Fallback to hardcoded
      print('WorkoutEngine: Using fallback exercises for CHEST day');
      return _selectTodaysExercises(history);
    }
    
    // Get last workout date
    final lastWorkout = history.last.timestamp;
    
    // Enforce minimum rest - THE MANDATE demands recovery
    final daysSinceLastWorkout = DateTime.now().difference(lastWorkout).inDays;
    if (daysSinceLastWorkout < 1) {
      return []; // Rest day MANDATED - no exceptions
    }
    
    // HEAVYWEIGHT 5-day rotation: CHEST → BACK → ARMS → SHOULDERS → LEGS
    final workoutCount = _getWorkoutCount(history);
    final dayInCycle = workoutCount % 5;
    
    // Map day in cycle to database workout day ID
    final workoutDayId = dayInCycle + 1; // Assuming IDs are 1-5
    
    try {
      print('WorkoutEngine: Fetching workout day $workoutDayId from database');
      final workoutDay = await repository!.fetchCompleteWorkoutDay(workoutDayId);
      if (workoutDay != null && workoutDay.exercises.isNotEmpty) {
        print('WorkoutEngine: Found ${workoutDay.exercises.length} exercises for workout day $workoutDayId');
        return workoutDay.exercises.map((de) => de.exercise).toList();
      } else {
        print('WorkoutEngine: No exercises found for workout day $workoutDayId in database');
      }
    } catch (e) {
      print('WorkoutEngine: Failed to fetch workout day $workoutDayId from database: $e');
    }
    
    // Fallback to hardcoded exercises if database fails
    return _selectTodaysExercises(history);
  }

  /// Select exercises for today based on HEAVYWEIGHT 5-day rotation (fallback)
  /// CHEST → BACK → ARMS → SHOULDERS → LEGS
  List<Exercise> _selectTodaysExercises(List<SetData> history) {
    if (history.isEmpty) {
      // Day 1: CHEST
      return [
        Exercise.bigSix[2], // Bench Press
        Exercise.bigSix[3], // Overhead Press (secondary chest)
      ];
    }
    
    // Get last workout date
    final lastWorkout = history.last.timestamp;
    
    // Enforce minimum rest - THE MANDATE demands recovery
    final daysSinceLastWorkout = DateTime.now().difference(lastWorkout).inDays;
    if (daysSinceLastWorkout < 1) {
      return []; // Rest day MANDATED - no exceptions
    }
    
    // HEAVYWEIGHT 5-day rotation: CHEST → BACK → ARMS → SHOULDERS → LEGS
    final workoutCount = _getWorkoutCount(history);
    final dayInCycle = workoutCount % 5;
    
    switch (dayInCycle) {
      case 0: // CHEST DAY
        return [
          Exercise.bigSix[2], // Bench Press
          Exercise.bigSix[3], // Overhead Press (secondary)
        ];
      case 1: // BACK DAY
        return [
          Exercise.bigSix[1], // Deadlift
          Exercise.bigSix[4], // Row
          Exercise.bigSix[5], // Pull-up
        ];
      case 2: // ARMS DAY
        return [
          Exercise.bigSix[5], // Pull-up (biceps)
          Exercise.bigSix[3], // Overhead Press (triceps)
        ];
      case 3: // SHOULDERS DAY
        return [
          Exercise.bigSix[3], // Overhead Press
          Exercise.bigSix[4], // Row (rear delts)
        ];
      case 4: // LEGS DAY
        return [
          Exercise.bigSix[0], // Squat
          Exercise.bigSix[1], // Deadlift (posterior chain)
        ];
      default:
        return [Exercise.bigSix[2]]; // Default to bench
    }
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