/// Set data model - captures the TRUTH of what happened
/// No limits, no validation - we need honest data, especially in failure
class SetData {
  final String exerciseId;
  final double weight; // Actual weight used (kg)
  final int actualReps; // What REALLY happened (0-30+)
  final DateTime timestamp;
  final int setNumber; // Which set in the session (1, 2, 3, etc.)
  final int restTaken; // Actual rest taken in seconds

  const SetData({
    required this.exerciseId,
    required this.weight,
    required this.actualReps,
    required this.timestamp,
    required this.setNumber,
    required this.restTaken,
  });

  /// Determine if this set met the mandate
  bool get metMandate => actualReps >= 4 && actualReps <= 6;

  /// Determine if this was a failure
  bool get isFailure => actualReps < 4;

  /// Determine if this exceeded the mandate
  bool get exceededMandate => actualReps > 6;

  /// Get performance zone for visualization
  PerformanceZone get performanceZone {
    if (actualReps == 0) return PerformanceZone.completeFailure;
    if (actualReps < 4) return PerformanceZone.belowMandate;
    if (actualReps <= 6) return PerformanceZone.withinMandate;
    return PerformanceZone.aboveMandate;
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'weight': weight,
      'actualReps': actualReps,
      'timestamp': timestamp.toIso8601String(),
      'setNumber': setNumber,
      'restTaken': restTaken,
    };
  }

  factory SetData.fromJson(Map<String, dynamic> json) {
    return SetData(
      exerciseId: json['exerciseId'],
      weight: (json['weight'] as num).toDouble(),
      actualReps: json['actualReps'] as int,
      timestamp: DateTime.parse(json['timestamp']),
      setNumber: json['setNumber'] as int,
      restTaken: json['restTaken'] as int,
    );
  }
}

/// Performance zones for visual feedback
enum PerformanceZone {
  completeFailure, // 0 reps - catastrophic
  belowMandate, // 1-3 reps - reduce weight
  withinMandate, // 4-6 reps - perfect
  aboveMandate, // 7+ reps - increase weight
}

/// Workout session - collection of sets
class WorkoutSession {
  final String id;
  final DateTime date;
  final List<SetData> sets;
  final bool completed;
  final String? notes;

  const WorkoutSession({
    required this.id,
    required this.date,
    required this.sets,
    this.completed = false,
    this.notes,
  });

  /// Get all sets for a specific exercise
  List<SetData> setsForExercise(String exerciseId) {
    return sets.where((s) => s.exerciseId == exerciseId).toList();
  }

  /// Calculate session performance score (0-100)
  double get performanceScore {
    if (sets.isEmpty) return 0;

    final mandateSets = sets.where((s) => s.metMandate).length;
    return (mandateSets / sets.length) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'sets': sets.map((s) => s.toJson()).toList(),
      'completed': completed,
      'notes': notes,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      date: DateTime.parse(json['date']),
      sets: (json['sets'] as List).map((s) => SetData.fromJson(s)).toList(),
      completed: json['completed'] ?? false,
      notes: json['notes'],
    );
  }
}
