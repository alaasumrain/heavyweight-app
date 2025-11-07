import 'package:flutter_test/flutter_test.dart';

import 'package:heavyweight_app/fortress/engine/models/set_data.dart';
import 'package:heavyweight_app/fortress/engine/workout_engine.dart';

void main() {
  group('WorkoutEngine Tests', () {
    late WorkoutEngine engine;

    setUp(() {
      engine = WorkoutEngine();
    });

    group('calculateNextWeight', () {
      test('should maintain weight for 4-6 reps (mandate satisfied)', () {
        // Test the core 4-6 rep mandate
        expect(engine.calculateNextWeight(100.0, 4), equals(100.0));
        expect(engine.calculateNextWeight(100.0, 5), equals(100.0));
        expect(engine.calculateNextWeight(100.0, 6), equals(100.0));
      });

      test('should increase weight for 7+ reps', () {
        // Test progression logic
        expect(engine.calculateNextWeight(100.0, 7), equals(102.5));
        expect(engine.calculateNextWeight(100.0, 8), equals(102.5));
        expect(engine.calculateNextWeight(100.0, 10), equals(105.0));
        expect(engine.calculateNextWeight(100.0, 15), equals(107.5));
      });

      test('should decrease weight for <4 reps', () {
        // Test regression logic
        expect(engine.calculateNextWeight(100.0, 3), equals(95.0));
        expect(engine.calculateNextWeight(100.0, 2), equals(95.0));
        expect(engine.calculateNextWeight(100.0, 1), equals(95.0));
      });

      test('should handle failure (0 reps)', () {
        // Test failure scenario
        expect(engine.calculateNextWeight(100.0, 0), equals(80.0));
      });

      test('should handle edge cases', () {
        // Test very low weights
        expect(engine.calculateNextWeight(2.5, 7), equals(5.0));
        expect(
            engine.calculateNextWeight(1.0, 0), equals(1.0)); // Minimum weight

        // Test very high weights
        expect(engine.calculateNextWeight(200.0, 7), equals(205.0));
      });
    });

    group('calculateCalibrationWeight', () {
      test('should calculate correct calibration weights', () {
        // Test calibration progression
        expect(
            engine.calculateCalibrationWeight(50.0, 14), equals(77.5)); // 1.55x
        expect(
            engine.calculateCalibrationWeight(50.0, 10), equals(62.5)); // 1.25x
        expect(engine.calculateCalibrationWeight(50.0, 5),
            equals(50.0)); // Perfect
        expect(engine.calculateCalibrationWeight(50.0, 3),
            lessThan(50.0)); // Reduce
      });
    });

    group('generateDailyWorkout', () {
      test('should generate workout with proper day rotation', () async {
        // Test with no history (first workout)
        final workout = await engine.generateDailyWorkout([]);

        expect(workout, isNotNull);
        expect(workout.dayName, isNotEmpty);
        expect(workout.exercises, isNotEmpty);
        expect(workout.exercises.length, greaterThanOrEqualTo(1));
      });

      test('should follow 5-day rotation cycle', () async {
        // Create mock history for different workout counts
        final history1 = <SetData>[]; // Workout 0 -> CHEST
        final history2 = _createMockHistory(1); // Workout 1 -> BACK
        final history3 = _createMockHistory(2); // Workout 2 -> ARMS

        final workout1 = await engine.generateDailyWorkout(history1);
        final workout2 = await engine.generateDailyWorkout(history2);
        final workout3 = await engine.generateDailyWorkout(history3);

        // Verify rotation
        expect(workout1.dayName, equals('CHEST'));
        expect(workout2.dayName, equals('BACK'));
        expect(workout3.dayName, equals('ARMS'));
      });

      test('should calculate prescribed weights based on history', () async {
        // Create history with specific weights
        final history = [
          SetData(
            exerciseId: 'bench',
            weight: 100.0,
            actualReps: 5,
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            setNumber: 1,
            restTaken: 180,
          ),
        ];

        final workout = await engine.generateDailyWorkout(history);

        // Find bench press in workout
        final benchExercise = workout.exercises.firstWhere(
          (e) => e.exercise.id == 'bench',
          orElse: () => workout.exercises.first,
        );

        expect(benchExercise.prescribedWeight, greaterThan(0));
      });
    });

    group('Weight Calculation Edge Cases', () {
      test('should handle empty history gracefully', () async {
        final workout = await engine.generateDailyWorkout([]);
        expect(workout.exercises, isNotEmpty);

        for (final exercise in workout.exercises) {
          expect(exercise.prescribedWeight, greaterThan(0));
        }
      });

      test('should use fallback weights when no history exists', () async {
        final workout = await engine.generateDailyWorkout([]);

        // Should use default weights from system config
        for (final exercise in workout.exercises) {
          expect(exercise.prescribedWeight, greaterThanOrEqualTo(20.0));
          expect(exercise.prescribedWeight, lessThanOrEqualTo(100.0));
        }
      });
    });

    group('Exercise Selection', () {
      test('should select appropriate exercises for each day', () async {
        final chestWorkout = await engine.generateDailyWorkout([]);

        // Should have exercises appropriate for the day
        expect(chestWorkout.exercises, isNotEmpty);
        expect(chestWorkout.exercises.length, lessThanOrEqualTo(4));
      });
    });

    group('Performance Tests', () {
      test('should generate workout quickly', () async {
        final stopwatch = Stopwatch()..start();

        await engine.generateDailyWorkout([]);

        stopwatch.stop();

        // Should complete in under 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle large history efficiently', () async {
        // Create large history (100 workouts)
        final largeHistory = <SetData>[];
        for (int i = 0; i < 500; i++) {
          largeHistory.add(SetData(
            exerciseId: 'bench',
            weight: 100.0 + i,
            actualReps: 5,
            timestamp: DateTime.now().subtract(Duration(days: i)),
            setNumber: 1,
            restTaken: 180,
          ));
        }

        final stopwatch = Stopwatch()..start();
        await engine.generateDailyWorkout(largeHistory);
        stopwatch.stop();

        // Should still complete quickly with large history
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });
    });
  });
}

/// Helper function to create mock workout history
List<SetData> _createMockHistory(int workoutCount) {
  final history = <SetData>[];

  for (int i = 0; i < workoutCount; i++) {
    history.addAll([
      SetData(
        exerciseId: 'bench',
        weight: 100.0,
        actualReps: 5,
        timestamp: DateTime.now().subtract(Duration(days: i * 2)),
        setNumber: 1,
        restTaken: 180,
      ),
      SetData(
        exerciseId: 'squat',
        weight: 120.0,
        actualReps: 5,
        timestamp: DateTime.now().subtract(Duration(days: i * 2)),
        setNumber: 1,
        restTaken: 180,
      ),
    ]);
  }

  return history;
}
