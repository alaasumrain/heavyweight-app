import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:heavyweight_app/core/cache_service.dart';
import 'package:heavyweight_app/fortress/engine/models/set_data.dart';
import 'package:heavyweight_app/fortress/engine/workout_engine.dart';
import 'package:heavyweight_app/fortress/engine/models/exercise.dart';
import 'package:heavyweight_app/fortress/engine/storage/workout_repository_interface.dart'
    show PerformanceStats;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheService().clear();
  });

  test('CacheService round-trips DailyWorkout objects', () async {
    final cache = CacheService();
    final workout = DailyWorkout(
      date: DateTime.utc(2024, 1, 1),
      dayName: 'CHEST',
      exercises: const [
        PlannedExercise(
          exercise: Exercise(
            id: 'bench',
            name: 'Bench Press',
            muscleGroup: 'Chest',
            prescribedWeight: 80,
          ),
          prescribedWeight: 80,
          targetSets: 3,
          restSeconds: 180,
        ),
      ],
    );

    await cache.set(
        CacheService.todaysWorkoutKey, workout, CacheService.shortTTL);

    final result = await cache.get<DailyWorkout>(CacheService.todaysWorkoutKey);
    expect(result, isNotNull);
    expect(result!.dayName, workout.dayName);
    expect(result.exercises.length, workout.exercises.length);
    expect(result.exercises.first.prescribedWeight,
        workout.exercises.first.prescribedWeight);
  });

  test('CacheService round-trips workout history collections', () async {
    final cache = CacheService();
    final session = WorkoutSession(
      id: 'session_1',
      date: DateTime.utc(2024, 1, 2),
      sets: [
        SetData(
          exerciseId: 'squat',
          weight: 100,
          actualReps: 5,
          timestamp: DateTime.utc(2024, 1, 2),
          setNumber: 1,
          restTaken: 180,
        ),
      ],
      completed: true,
    );

    await cache.set(
        CacheService.workoutHistoryKey, [session], CacheService.mediumTTL);

    final fetched =
        await cache.get<List<WorkoutSession>>(CacheService.workoutHistoryKey);
    expect(fetched, isNotNull);
    expect(fetched!.length, 1);
    expect(fetched.first.sets.first.weight, session.sets.first.weight);
  });

  test('CacheService round-trips PerformanceStats', () async {
    final cache = CacheService();
    const stats = PerformanceStats(
      totalSets: 10,
      mandateSets: 6,
      failureSets: 2,
      exceededSets: 2,
      totalVolume: 1500,
      workoutDays: 4,
      mandateAdherence: 60,
    );

    await cache.set(
        CacheService.performanceStatsKey, stats, CacheService.mediumTTL);

    final fetched =
        await cache.get<PerformanceStats>(CacheService.performanceStatsKey);
    expect(fetched, isNotNull);
    expect(fetched!.totalSets, stats.totalSets);
    expect(fetched.mandateAdherence, stats.mandateAdherence);
  });
}
