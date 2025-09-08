import 'exercise.dart';

/// Workout day model representing a day in the training program
class WorkoutDay {
  final int id;
  final String name;
  final int dayOrder;
  final List<DayExercise> exercises;

  const WorkoutDay({
    required this.id,
    required this.name,
    required this.dayOrder,
    required this.exercises,
  });

  /// Create WorkoutDay from database row
  factory WorkoutDay.fromDatabase({
    required int id,
    required String name,
    required int dayOrder,
    List<DayExercise> exercises = const [],
  }) {
    return WorkoutDay(
      id: id,
      name: name,
      dayOrder: dayOrder,
      exercises: exercises,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'day_order': dayOrder,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

/// Day exercise linking model
class DayExercise {
  final int id;
  final int workoutDayId;
  final Exercise exercise;
  final int orderInDay;
  final int setsTarget;

  const DayExercise({
    required this.id,
    required this.workoutDayId,
    required this.exercise,
    required this.orderInDay,
    required this.setsTarget,
  });

  /// Create DayExercise from database join
  factory DayExercise.fromDatabase({
    required int id,
    required int workoutDayId,
    required int orderInDay,
    required int setsTarget,
    required Exercise exercise,
  }) {
    return DayExercise(
      id: id,
      workoutDayId: workoutDayId,
      exercise: exercise,
      orderInDay: orderInDay,
      setsTarget: setsTarget,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_day_id': workoutDayId,
      'exercise': exercise.toJson(),
      'order_in_day': orderInDay,
      'sets_target': setsTarget,
    };
  }
}