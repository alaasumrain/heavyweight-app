/// Exercise model for the Fortress system
/// Represents a single exercise with its prescribed weight and mandate
class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final double prescribedWeight; // In kg
  final int targetReps; // Always 4-6, but stored for clarity
  final int restSeconds; // Rest period after this exercise
  
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.prescribedWeight,
    this.targetReps = 5, // Middle of the 4-6 mandate
    this.restSeconds = 180, // 3 minutes default
  });
  
  /// The Big Six compound movements
  static const List<Exercise> bigSix = [
    Exercise(
      id: 'squat',
      name: 'Barbell Squat',
      muscleGroup: 'Legs',
      prescribedWeight: 60.0, // Starting weight for calibration
    ),
    Exercise(
      id: 'deadlift',
      name: 'Deadlift',
      muscleGroup: 'Back/Legs',
      prescribedWeight: 80.0,
    ),
    Exercise(
      id: 'bench',
      name: 'Bench Press',
      muscleGroup: 'Chest',
      prescribedWeight: 50.0,
    ),
    Exercise(
      id: 'overhead',
      name: 'Overhead Press',
      muscleGroup: 'Shoulders',
      prescribedWeight: 30.0,
    ),
    Exercise(
      id: 'row',
      name: 'Barbell Row',
      muscleGroup: 'Back',
      prescribedWeight: 40.0,
    ),
    Exercise(
      id: 'pullup',
      name: 'Weighted Pull-up',
      muscleGroup: 'Back/Biceps',
      prescribedWeight: 0.0, // Bodyweight to start
    ),
  ];
  
  Exercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    double? prescribedWeight,
    int? targetReps,
    int? restSeconds,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      prescribedWeight: prescribedWeight ?? this.prescribedWeight,
      targetReps: targetReps ?? this.targetReps,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'prescribedWeight': prescribedWeight,
      'targetReps': targetReps,
      'restSeconds': restSeconds,
    };
  }
  
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      muscleGroup: json['muscleGroup'],
      prescribedWeight: json['prescribedWeight'].toDouble(),
      targetReps: json['targetReps'] ?? 5,
      restSeconds: json['restSeconds'] ?? 180,
    );
  }
}