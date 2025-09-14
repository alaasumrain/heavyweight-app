/// Exercise model for the Fortress system
/// Represents a single exercise with its prescribed weight and mandate
class Exercise {
  final int? databaseId; // Database ID from Supabase
  final String id; // Legacy string ID (for compatibility)
  final String name;
  final String muscleGroup;
  final double prescribedWeight; // In kg
  final int targetReps; // Always 4-6, but stored for clarity
  final int restSeconds; // Rest period after this exercise
  final int? setsTarget; // Target sets for this exercise (from database)
  final String? description; // Exercise description
  
  const Exercise({
    this.databaseId,
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.prescribedWeight,
    this.targetReps = 5, // Middle of the 4-6 mandate
    this.restSeconds = 180, // 3 minutes default
    this.setsTarget,
    this.description,
  });
  
  /// The Big Six compound movements - Starting weights for serious lifters
  static const List<Exercise> bigSix = [
    Exercise(
      id: 'squat',
      name: 'Barbell Squat',
      muscleGroup: 'Legs',
      prescribedWeight: 80.0, // Bar + 30kg per side (serious starting point)
    ),
    Exercise(
      id: 'deadlift',
      name: 'Deadlift',
      muscleGroup: 'Back/Legs',
      prescribedWeight: 100.0, // Bar + 40kg per side (lifters can handle this)
    ),
    Exercise(
      id: 'bench',
      name: 'Bench Press',
      muscleGroup: 'Chest',
      prescribedWeight: 80.0, // Bar + 30kg per side - SERIOUS starting weight
    ),
    Exercise(
      id: 'overhead',
      name: 'Overhead Press',
      muscleGroup: 'Shoulders',
      prescribedWeight: 40.0, // Bar + 10kg per side (reasonable for OHP)
    ),
    Exercise(
      id: 'row',
      name: 'Barbell Row',
      muscleGroup: 'Back',
      prescribedWeight: 50.0, // Bar + 15kg per side (solid starting row)
    ),
    Exercise(
      id: 'pullup',
      name: 'Weighted Pull-up',
      muscleGroup: 'Back/Biceps',
      prescribedWeight: 0.0, // Bodyweight to start (proper progression)
    ),
  ];

  /// Chest day exercises - HEAVYWEIGHT starting weights for serious lifters
  static const List<Exercise> chestExercises = [
    Exercise(
      id: 'bench',
      name: 'Bench Press',
      muscleGroup: 'Chest',
      prescribedWeight: 80.0, // Serious starting weight - Bar + 30kg per side
    ),
    Exercise(
      id: 'incline_db',
      name: 'DB Incline Bench Press',
      muscleGroup: 'Chest',
      prescribedWeight: 25.0, // Per hand - good starting weight
    ),
    Exercise(
      id: 'chest_fly',
      name: 'Chest Flies',
      muscleGroup: 'Chest',
      prescribedWeight: 30.0, // Machine stack weight (not per hand)
    ),
    Exercise(
      id: 'dips',
      name: 'Dips',
      muscleGroup: 'Chest/Triceps',
      prescribedWeight: 0.0, // Bodyweight first, then add weight
    ),
  ];

  /// Back day exercises
  static const List<Exercise> backExercises = [
    Exercise(
      id: 'deadlift',
      name: 'Deadlift',
      muscleGroup: 'Back/Legs',
      prescribedWeight: 100.0,
    ),
    Exercise(
      id: 'row',
      name: 'Barbell Row',
      muscleGroup: 'Back',
      prescribedWeight: 50.0,
    ),
    Exercise(
      id: 'pullup',
      name: 'Weighted Pull-up',
      muscleGroup: 'Back/Biceps',
      prescribedWeight: 0.0,
    ),
  ];

  /// Arms day exercises
  static const List<Exercise> armExercises = [
    Exercise(
      id: 'pullup',
      name: 'Weighted Pull-up',
      muscleGroup: 'Back/Biceps',
      prescribedWeight: 0.0,
    ),
    Exercise(
      id: 'overhead',
      name: 'Overhead Press',
      muscleGroup: 'Shoulders/Triceps',
      prescribedWeight: 40.0,
    ),
  ];

  /// Shoulders day exercises
  static const List<Exercise> shoulderExercises = [
    Exercise(
      id: 'overhead',
      name: 'Overhead Press',
      muscleGroup: 'Shoulders',
      prescribedWeight: 40.0,
    ),
    Exercise(
      id: 'row',
      name: 'Barbell Row',
      muscleGroup: 'Back/Rear Delts',
      prescribedWeight: 50.0,
    ),
  ];

  /// Legs day exercises
  static const List<Exercise> legExercises = [
    Exercise(
      id: 'squat',
      name: 'Barbell Squat',
      muscleGroup: 'Legs',
      prescribedWeight: 80.0,
    ),
    Exercise(
      id: 'deadlift',
      name: 'Deadlift',
      muscleGroup: 'Back/Legs',
      prescribedWeight: 100.0,
    ),
  ];
  
  Exercise copyWith({
    int? databaseId,
    String? id,
    String? name,
    String? muscleGroup,
    double? prescribedWeight,
    int? targetReps,
    int? restSeconds,
    int? setsTarget,
    String? description,
  }) {
    return Exercise(
      databaseId: databaseId ?? this.databaseId,
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      prescribedWeight: prescribedWeight ?? this.prescribedWeight,
      targetReps: targetReps ?? this.targetReps,
      restSeconds: restSeconds ?? this.restSeconds,
      setsTarget: setsTarget ?? this.setsTarget,
      description: description ?? this.description,
    );
  }
  
  /// Create Exercise from database row
  factory Exercise.fromDatabase({
    required int databaseId,
    required String name,
    required String description,
    int setsTarget = 3,
  }) {
    final id = Exercise.mapNameToId(name);
    return Exercise(
      databaseId: databaseId,
      id: id,
      name: name,
      muscleGroup: 'Mixed', // Will be set based on day
      prescribedWeight: Exercise.startingWeightFor(id), // Use proper starting weight
      setsTarget: setsTarget,
      description: description,
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
      prescribedWeight: (json['prescribedWeight'] as num).toDouble(),
      targetReps: json['targetReps'] ?? 5,
      restSeconds: json['restSeconds'] ?? 180,
    );
  }

  /// Create Exercise from Supabase database row
  factory Exercise.fromSupabase(Map<String, dynamic> row) {
    return Exercise(
      id: _mapExerciseNameToId(row['name']),
      name: row['name'],
      muscleGroup: _getMuscleGroupForExercise(row['name']),
      prescribedWeight: startingWeightFor(_mapExerciseNameToId(row['name'])), // Use consistent starting weight
      targetReps: 5,
      restSeconds: 180,
    );
  }

  /// Map exercise name from Supabase to internal ID format
  static String _mapExerciseNameToId(String name) {
    switch (name.toLowerCase()) {
      case 'squat':
        return 'squat';
      case 'bench press':
        return 'bench';
      case 'deadlift':
        return 'deadlift';
      case 'overhead press':
        return 'overhead';
      case 'row':
        return 'row';
      case 'pull-ups':
        return 'pullup';
      // Chest exercise mappings
      case 'db incline bench press':
        return 'incline_db';
      case 'chest flies':
        return 'chest_fly';
      case 'dips':
        return 'dips';
      default:
        return name.toLowerCase().replaceAll(' ', '_');
    }
  }

  /// Public method for external use of exercise name mapping
  static String mapNameToId(String name) => _mapExerciseNameToId(name);

  /// Get starting weight for exercise - HEAVYWEIGHT weights for serious lifters
  static double startingWeightFor(String id) {
    switch (id) {
      case 'bench': return 80.0;           // Bar + 30kg per side - SERIOUS
      case 'squat': return 80.0;           // Bar + 30kg per side  
      case 'deadlift': return 100.0;       // Bar + 40kg per side
      case 'overhead': return 40.0;        // Bar + 10kg per side
      case 'row': return 50.0;             // Bar + 15kg per side
      case 'incline_db': return 25.0;      // Per hand
      case 'chest_fly': return 30.0;       // Machine stack weight
      case 'dips': return 0.0;             // Bodyweight first
      case 'pullup': return 0.0;           // Bodyweight
      default: return 20.0;                // Safe minimum
    }
  }

  /// Get exercise by ID from the Big Six
  static Exercise? getById(String id) {
    try {
      return bigSix.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get muscle group for exercise name
  static String _getMuscleGroupForExercise(String name) {
    switch (name.toLowerCase()) {
      case 'squat':
        return 'Legs';
      case 'bench press':
        return 'Chest';
      case 'deadlift':
        return 'Back/Legs';
      case 'overhead press':
        return 'Shoulders';
      case 'row':
        return 'Back';
      default:
        return 'Unknown';
    }
  }
}
