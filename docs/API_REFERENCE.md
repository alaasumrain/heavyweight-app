# HEAVYWEIGHT API Reference

## Table of Contents
1. [Workout Engine API](#workout-engine-api)
2. [Repository Interface](#repository-interface)
3. [ViewModels](#viewmodels)
4. [Training State API](#training-state-api)
5. [Calibration System](#calibration-system)
6. [Database Operations](#database-operations)

---

## Workout Engine API

### WorkoutEngine Class
Core business logic for workout management and weight calculations.

#### Constructor
```dart
WorkoutEngine({WorkoutRepositoryInterface? repository})
```

#### Key Methods

##### `calculateNextWeight`
Calculates the next prescribed weight based on performance.
```dart
double calculateNextWeight(double currentWeight, int actualReps)

// Example
final nextWeight = engine.calculateNextWeight(80.0, 5); // Returns 80.0 (maintained)
final nextWeight = engine.calculateNextWeight(80.0, 8); // Returns 82.0 (increase)
final nextWeight = engine.calculateNextWeight(80.0, 2); // Returns 76.0 (decrease)
```

##### `generateDailyWorkout`
Generates today's workout based on history and rotation.
```dart
Future<DailyWorkout> generateDailyWorkout(
  List<SetData> history, 
  {String? preferredStartingDay}
)

// Example
final workout = await engine.generateDailyWorkout(history);
print(workout.dayName); // "CHEST"
print(workout.exercises.length); // 3
```

##### `calculateCalibrationWeight`
Determines next weight during calibration to find 5RM.
```dart
double calculateCalibrationWeight(double currentWeight, int actualReps)

// Calibration logic:
// 14+ reps: Multiply by 1.55
// 8-13 reps: Multiply by 1.25
// 5 reps: Perfect, return same
// <5 reps: Reduce appropriately
```

---

## Repository Interface

### WorkoutRepositoryInterface
Abstract interface for data persistence.

```dart
abstract class WorkoutRepositoryInterface {
  // Session Operations
  Future<void> saveSet(SetData set);
  Future<List<SetData>> getLastSession();
  Future<List<SetData>> getHistory();
  
  // Exercise Lookup
  Future<Map<String, SetData>> getLastForExercises(Set<String> exerciseIds);
  
  // Workout Days
  Future<WorkoutDay?> fetchCompleteWorkoutDay(int dayId);
  
  // Performance Stats
  Future<PerformanceStats> getStats();
  
  // Calibration
  Future<bool> isCalibrationComplete();
  Future<void> markCalibrationComplete();
}
```

### SupabaseWorkoutRepository
Production implementation with performance optimizations.

#### Performance Features
```dart
// 1. Exercise ID Cache
Map<String, int> _exerciseIdCache = {};

// 2. Batch RPC Operations
Future<Map<String, SetData>> getLastForExercises(Set<String> exerciseIds) async {
  // Try slug-based RPC first (fastest)
  try {
    return await _supabase.rpc('hw_last_for_exercises_by_slug', 
      params: {'slugs': exerciseIds.toList()});
  } catch (_) {
    // Fallback to ID-based RPC
    // Then fallback to individual queries
  }
}
```

---

## ViewModels

### WorkoutViewModel
Manages workout screen state and business logic.

```dart
class WorkoutViewModel extends ChangeNotifier {
  // Properties
  DailyWorkout? get todaysWorkout;
  bool get isLoading;
  bool get needsCalibration;
  String? get error;
  
  // Methods
  Future<void> initialize({String? preferredStartingDay});
  Future<void> processWorkoutResults(List<SetData> results);
  Future<void> refresh();
  Future<PerformanceStats> getStats();
}
```

#### Usage Example
```dart
// In widget
final viewModel = context.watch<WorkoutViewModel>();

if (viewModel.isLoading) {
  return CircularProgressIndicator();
}

if (viewModel.needsCalibration) {
  return CalibrationScreen();
}

return WorkoutScreen(workout: viewModel.todaysWorkout!);
```

---

## Training State API

### TrainingState Class
Static class for managing cross-device training persistence.

#### Key Methods

##### `assignDay`
Persists the current training day assignment.
```dart
static Future<void> assignDay(String dayName)

// Called automatically in WorkoutEngine.generateDailyWorkout()
await TrainingState.assignDay("CHEST");
```

##### `completeDay`
Marks the current day as complete and updates streaks.
```dart
static Future<void> completeDay()

// Called automatically in WorkoutViewModel.processWorkoutResults()
await TrainingState.completeDay();
```

##### `getCurrentStreak`
Gets the current training streak count.
```dart
static Future<int> getCurrentStreak()

// Example
final streak = await TrainingState.getCurrentStreak(); // Returns 5
```

##### `getLastAssignedDay`
Retrieves the last assigned training day.
```dart
static Future<String?> getLastAssignedDay()

// Example
final lastDay = await TrainingState.getLastAssignedDay(); // Returns "LEGS"
```

---

## Calibration System

### CalibrationResumeStore
Manages calibration state persistence across sessions and devices.

#### Save Calibration Attempt
```dart
static Future<void> saveAttempt({
  required String exerciseId,
  required int attemptIdx,
  required double signedLoadKg,
  required double effectiveLoadKg,
  required int reps,
  required double est1RmKg,
  required double nextSignedKg,
})

// Example
await CalibrationResumeStore.saveAttempt(
  exerciseId: 'bench',
  attemptIdx: 2,
  signedLoadKg: 80.0,
  effectiveLoadKg: 80.0,
  reps: 8,
  est1RmKg: 100.0,
  nextSignedKg: 100.0,
);
```

#### Load Pending Calibration
```dart
static Future<CalibrationAttemptRecord?> loadPending()

// Returns newest from local or server
final pending = await CalibrationResumeStore.loadPending();
if (pending != null) {
  // Resume from pending.nextSignedKg
}
```

### CalibrationService
Loads and applies calibration configuration.

```dart
class CalibrationService {
  // Load configuration from JSON
  Future<void> loadConfig();
  
  // Calculate next weight based on reps
  double calculateNextWeight(double currentWeight, int actualReps);
  
  // Get multiplier for specific rep count
  double getMultiplierForReps(int reps);
}
```

---

## Database Operations

### RPC Functions

#### `hw_last_for_exercises_by_slug`
Fetches last set for multiple exercises using slugs (fastest).
```sql
-- Input: text[] of exercise slugs
-- Output: Table of latest sets
CREATE FUNCTION hw_last_for_exercises_by_slug(slugs text[])
RETURNS TABLE (
  exercise_slug text,
  weight numeric,
  actual_reps smallint,
  set_number int,
  rest_taken int,
  created_at timestamptz
)
```

#### `hw_last_for_exercises`
Fetches last set for multiple exercises using IDs (fallback).
```sql
-- Input: int[] of exercise IDs
-- Output: Table of latest sets
CREATE FUNCTION hw_last_for_exercises(exercise_ids int[])
RETURNS TABLE (
  exercise_id int,
  weight numeric,
  actual_reps smallint,
  set_number int,
  rest_taken int,
  created_at timestamptz
)
```

### Direct Queries

#### Save Set
```dart
await supabase.from('sets').insert({
  'workout_id': workoutId,
  'exercise_id': exerciseId,
  'weight': weight,
  'actual_reps': actualReps,
  'set_number': setNumber,
  'rest_taken': restTaken,
});
```

#### Get User's Last Workout
```dart
final response = await supabase
  .from('workouts')
  .select('*, sets(*)')
  .eq('user_id', userId)
  .order('created_at', ascending: false)
  .limit(1);
```

### Error Handling Pattern
```dart
try {
  // Primary operation
  return await primaryMethod();
} catch (e) {
  HWLog.event('operation_failed', data: {'error': e.toString()});
  
  // Try fallback
  try {
    return await fallbackMethod();
  } catch (_) {
    // Return safe default
    return defaultValue;
  }
}
```

---

## Models

### SetData
Represents a completed exercise set.
```dart
class SetData {
  final String exerciseId;
  final double weight;
  final int actualReps;
  final DateTime timestamp;
  final int? setNumber;
  final int? restTaken;
  
  // Computed properties
  bool get metMandate => actualReps >= 4 && actualReps <= 6;
  bool get isFailure => actualReps == 0;
  bool get exceededMandate => actualReps > 6;
}
```

### DailyWorkout
Represents a complete workout plan.
```dart
class DailyWorkout {
  final DateTime date;
  final String dayName; // "CHEST", "BACK", etc.
  final List<PlannedExercise> exercises;
  final bool isDay1;
  
  bool get isRestDay => exercises.isEmpty;
}
```

### PlannedExercise
Single exercise within a workout.
```dart
class PlannedExercise {
  final Exercise exercise;
  final double prescribedWeight;
  final int targetSets;
  final int restSeconds;
  final bool needsCalibration;
}
```

---

## Usage Examples

### Complete Workout Flow
```dart
// 1. Initialize ViewModel
final viewModel = WorkoutViewModel(
  repository: SupabaseWorkoutRepository(),
  engine: WorkoutEngine(),
);
await viewModel.initialize();

// 2. Start workout (assigns day automatically)
final workout = viewModel.todaysWorkout!;

// 3. Execute sets
final results = <SetData>[];
for (final exercise in workout.exercises) {
  for (int set = 1; set <= exercise.targetSets; set++) {
    // User performs set...
    results.add(SetData(
      exerciseId: exercise.exercise.id,
      weight: exercise.prescribedWeight,
      actualReps: userReps,
      timestamp: DateTime.now(),
      setNumber: set,
      restTaken: 180,
    ));
  }
}

// 4. Process results (completes day automatically)
await viewModel.processWorkoutResults(results);
```

### Calibration Flow
```dart
// 1. Check for pending calibration
final pending = await CalibrationResumeStore.loadPending();
if (pending != null) {
  // Resume from pending.nextSignedKg
  startWeight = pending.nextSignedKg;
}

// 2. Perform calibration attempt
final reps = await userPerformsSet(startWeight);

// 3. Save attempt
await CalibrationResumeStore.saveAttempt(
  exerciseId: 'bench',
  attemptIdx: attemptNumber,
  signedLoadKg: startWeight,
  effectiveLoadKg: startWeight,
  reps: reps,
  est1RmKg: calculateEpley(startWeight, reps),
  nextSignedKg: calibrationService.calculateNextWeight(startWeight, reps),
);

// 4. Check if complete
if (reps == 5) {
  // Found 5RM!
  await repository.markCalibrationComplete();
}
```

---

*Generated: 2025-09-15*
*Version: 1.0.0*