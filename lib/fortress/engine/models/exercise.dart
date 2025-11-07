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

  static final Map<String, double> _runtimeStartingWeights = {};

  /// The Big Six compound movements - Starting weights for serious lifters
  static const List<Exercise> bigSix = [
    Exercise(
      databaseId: 1,
      id: 'squat',
      name: 'Barbell Squat',
      muscleGroup: 'Legs',
      prescribedWeight: 80.0, // Bar + 30kg per side (serious starting point)
    ),
    Exercise(
      databaseId: 3,
      id: 'deadlift',
      name: 'Deadlift',
      muscleGroup: 'Back/Legs',
      prescribedWeight: 100.0, // Bar + 40kg per side (lifters can handle this)
    ),
    Exercise(
      databaseId: 2,
      id: 'bench',
      name: 'Bench Press',
      muscleGroup: 'Chest',
      prescribedWeight: 80.0, // Bar + 30kg per side - SERIOUS starting weight
    ),
    Exercise(
      databaseId: 4,
      id: 'overhead',
      name: 'Overhead Press',
      muscleGroup: 'Shoulders',
      prescribedWeight: 40.0, // Bar + 10kg per side (reasonable for OHP)
    ),
    Exercise(
      databaseId: 5,
      id: 'row',
      name: 'Barbell Row',
      muscleGroup: 'Back',
      prescribedWeight: 50.0, // Bar + 15kg per side (solid starting row)
    ),
    Exercise(
      databaseId: 9,
      id: 'pullup',
      name: 'Weighted Pull-up',
      muscleGroup: 'Back/Biceps',
      prescribedWeight: 0.0, // Bodyweight to start (proper progression)
    ),
  ];

  /// Chest day exercises - HEAVYWEIGHT starting weights for serious lifters
  static const List<Exercise> chestExercises = [
    Exercise(
      databaseId: 2,
      id: 'bench',
      name: 'Bench Press',
      muscleGroup: 'Chest',
      prescribedWeight: 80.0, // Serious starting weight - Bar + 30kg per side
    ),
    Exercise(
      databaseId: 6,
      id: 'incline_db',
      name: 'DB Incline Bench Press',
      muscleGroup: 'Chest',
      prescribedWeight: 25.0, // Per hand - good starting weight
    ),
    Exercise(
      databaseId: 7,
      id: 'chest_fly',
      name: 'Chest Flies',
      muscleGroup: 'Chest',
      prescribedWeight: 30.0, // Machine stack weight (not per hand)
    ),
    Exercise(
      databaseId: 8,
      id: 'dips',
      name: 'Dips',
      muscleGroup: 'Chest/Triceps',
      prescribedWeight: 0.0, // Bodyweight first, then add weight
    ),
  ];

  /// Back day exercises
  static const List<Exercise> backExercises = [
    Exercise(
      databaseId: 3,
      id: 'deadlift',
      name: 'Deadlift',
      muscleGroup: 'Back/Legs',
      prescribedWeight: 100.0,
    ),
    Exercise(
      databaseId: 5,
      id: 'row',
      name: 'Barbell Row',
      muscleGroup: 'Back',
      prescribedWeight: 50.0,
    ),
    Exercise(
      databaseId: 9,
      id: 'pullup',
      name: 'Weighted Pull-up',
      muscleGroup: 'Back/Biceps',
      prescribedWeight: 0.0,
    ),
    Exercise(
      databaseId: 10,
      id: 'face_pulls',
      name: 'Face Pulls',
      muscleGroup: 'Back/Shoulders',
      prescribedWeight: 20.0,
    ),
    Exercise(
      databaseId: 11,
      id: 'lat_pulldown',
      name: 'Lat Pulldown',
      muscleGroup: 'Back',
      prescribedWeight: 45.0,
    ),
    Exercise(
      databaseId: 12,
      id: 'single_arm_lat_pulldown',
      name: 'Single Arm Lat Pulldown',
      muscleGroup: 'Back',
      prescribedWeight: 20.0,
    ),
  ];

  /// Arms day exercises
  static const List<Exercise> armExercises = [
    Exercise(
      databaseId: 16,
      id: 'hammer_curls',
      name: 'Hammer Curls',
      muscleGroup: 'Arms',
      prescribedWeight: 20.0,
    ),
    Exercise(
      databaseId: 17,
      id: 'preacher_curls',
      name: 'Preacher Curls',
      muscleGroup: 'Arms',
      prescribedWeight: 30.0,
    ),
    Exercise(
      databaseId: 18,
      id: 'tricep_pushdowns',
      name: 'Tricep Pushdowns',
      muscleGroup: 'Arms',
      prescribedWeight: 35.0,
    ),
    Exercise(
      databaseId: 19,
      id: 'overhead_tricep_extension',
      name: 'Overhead Tricep Extension',
      muscleGroup: 'Arms',
      prescribedWeight: 20.0,
    ),
    Exercise(
      databaseId: 9,
      id: 'pullup',
      name: 'Weighted Pull-up',
      muscleGroup: 'Back/Biceps',
      prescribedWeight: 0.0,
    ),
    Exercise(
      databaseId: 4,
      id: 'overhead',
      name: 'Overhead Press',
      muscleGroup: 'Shoulders/Triceps',
      prescribedWeight: 40.0,
    ),
  ];

  /// Shoulders day exercises
  static const List<Exercise> shoulderExercises = [
    Exercise(
      databaseId: 4,
      id: 'overhead',
      name: 'Overhead Press',
      muscleGroup: 'Shoulders',
      prescribedWeight: 40.0,
    ),
    Exercise(
      databaseId: 5,
      id: 'row',
      name: 'Barbell Row',
      muscleGroup: 'Back/Rear Delts',
      prescribedWeight: 50.0,
    ),
    Exercise(
      databaseId: 13,
      id: 'lateral_raises',
      name: 'Lateral Raises',
      muscleGroup: 'Shoulders',
      prescribedWeight: 12.5,
    ),
    Exercise(
      databaseId: 14,
      id: 'front_raises',
      name: 'Front Raises',
      muscleGroup: 'Shoulders',
      prescribedWeight: 12.5,
    ),
    Exercise(
      databaseId: 15,
      id: 'shrugs',
      name: 'Shrugs',
      muscleGroup: 'Shoulders/Traps',
      prescribedWeight: 40.0,
    ),
  ];

  /// Legs day exercises
  static const List<Exercise> legExercises = [
    Exercise(
      databaseId: 1,
      id: 'squat',
      name: 'Barbell Squat',
      muscleGroup: 'Legs',
      prescribedWeight: 80.0,
    ),
    Exercise(
      databaseId: 3,
      id: 'deadlift',
      name: 'Deadlift',
      muscleGroup: 'Back/Legs',
      prescribedWeight: 100.0,
    ),
    Exercise(
      databaseId: 20,
      id: 'leg_press',
      name: 'Leg Press',
      muscleGroup: 'Legs',
      prescribedWeight: 120.0,
    ),
    Exercise(
      databaseId: 21,
      id: 'leg_extensions',
      name: 'Leg Extensions',
      muscleGroup: 'Legs',
      prescribedWeight: 35.0,
    ),
    Exercise(
      databaseId: 22,
      id: 'hamstring_curls',
      name: 'Hamstring Curls',
      muscleGroup: 'Legs',
      prescribedWeight: 35.0,
    ),
    Exercise(
      databaseId: 23,
      id: 'calf_raises',
      name: 'Calf Raises',
      muscleGroup: 'Legs',
      prescribedWeight: 40.0,
    ),
    Exercise(
      databaseId: 24,
      id: 'rdls',
      name: 'RDLs',
      muscleGroup: 'Legs/Back',
      prescribedWeight: 70.0,
    ),
    Exercise(
      databaseId: 25,
      id: 'hip_thrusts',
      name: 'Hip Thrusts',
      muscleGroup: 'Glutes',
      prescribedWeight: 80.0,
    ),
  ];

  /// All known exercises (deduplicated by id)
  static List<Exercise> get allExercises {
    final Map<String, Exercise> byId = {};
    for (final group in [
      bigSix,
      chestExercises,
      backExercises,
      armExercises,
      shoulderExercises,
      legExercises,
    ]) {
      for (final ex in group) {
        byId[ex.id] = ex;
      }
    }
    return byId.values.toList();
  }

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
    double? startingWeightKg,
    int setsTarget = 3,
  }) {
    final id = Exercise.mapNameToId(name);
    final startingWeight = startingWeightKg ?? Exercise.startingWeightFor(id);
    _runtimeStartingWeights[id] = startingWeight;
    return Exercise(
      databaseId: databaseId,
      id: id,
      name: name,
      muscleGroup: 'Mixed', // Will be set based on day
      prescribedWeight: startingWeight,
      setsTarget: setsTarget,
      description: description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'databaseId': databaseId,
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
      databaseId: json['databaseId'],
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
    final id = _mapExerciseNameToId(row['name']);
    final startingWeight = (row['starting_weight_kg'] as num?)?.toDouble() ??
        Exercise.startingWeightFor(id);
    _runtimeStartingWeights[id] = startingWeight;
    return Exercise(
      databaseId: row['id'],
      id: id,
      name: row['name'],
      muscleGroup: _getMuscleGroupForExercise(row['name']),
      prescribedWeight: startingWeight,
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
      case 'face pulls':
        return 'face_pulls';
      case 'lat pulldown':
        return 'lat_pulldown';
      case 'single arm lat pulldown':
        return 'single_arm_lat_pulldown';
      case 'lateral raises':
        return 'lateral_raises';
      case 'front raises':
        return 'front_raises';
      case 'shrugs':
        return 'shrugs';
      case 'hammer curls':
        return 'hammer_curls';
      case 'preacher curls':
        return 'preacher_curls';
      case 'tricep pushdowns':
        return 'tricep_pushdowns';
      case 'overhead tricep extension':
        return 'overhead_tricep_extension';
      case 'leg press':
        return 'leg_press';
      case 'leg extensions':
        return 'leg_extensions';
      case 'hamstring curls':
        return 'hamstring_curls';
      case 'calf raises':
        return 'calf_raises';
      case 'rdls':
        return 'rdls';
      case 'hip thrusts':
        return 'hip_thrusts';
      default:
        return name.toLowerCase().replaceAll(' ', '_');
    }
  }

  /// Public method for external use of exercise name mapping
  static String mapNameToId(String name) => _mapExerciseNameToId(name);

  /// Get starting weight for exercise - HEAVYWEIGHT weights for serious lifters
  static double startingWeightFor(String id) {
    if (_runtimeStartingWeights.containsKey(id)) {
      return _runtimeStartingWeights[id]!;
    }
    switch (id) {
      case 'bench':
        return 80.0; // Bar + 30kg per side - SERIOUS
      case 'squat':
        return 80.0; // Bar + 30kg per side
      case 'deadlift':
        return 100.0; // Bar + 40kg per side
      case 'overhead':
        return 40.0; // Bar + 10kg per side
      case 'row':
        return 50.0; // Bar + 15kg per side
      case 'incline_db':
        return 25.0; // Per hand
      case 'chest_fly':
        return 30.0; // Machine stack weight
      case 'dips':
        return 0.0; // Bodyweight first
      case 'pullup':
        return 0.0; // Bodyweight
      case 'face_pulls':
        return 20.0;
      case 'lat_pulldown':
        return 45.0;
      case 'single_arm_lat_pulldown':
        return 20.0;
      case 'lateral_raises':
        return 12.5;
      case 'front_raises':
        return 12.5;
      case 'shrugs':
        return 40.0;
      case 'hammer_curls':
        return 20.0;
      case 'preacher_curls':
        return 30.0;
      case 'tricep_pushdowns':
        return 35.0;
      case 'overhead_tricep_extension':
        return 20.0;
      case 'leg_press':
        return 120.0;
      case 'leg_extensions':
        return 35.0;
      case 'hamstring_curls':
        return 35.0;
      case 'calf_raises':
        return 40.0;
      case 'rdls':
        return 70.0;
      case 'hip_thrusts':
        return 80.0;
      default:
        return 20.0; // Safe minimum
    }
  }

  /// Get exercise by ID from the Big Six
  static Exercise? getById(String id) {
    try {
      final runtime = _runtimeStartingWeights[id];
      if (runtime != null) {
        return allExercises.firstWhere((e) => e.id == id).copyWith(
              prescribedWeight: runtime,
            );
      }
      return allExercises.firstWhere((e) => e.id == id);
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
      case 'face pulls':
        return 'Back/Shoulders';
      case 'lat pulldown':
      case 'single arm lat pulldown':
        return 'Back';
      case 'lateral raises':
      case 'front raises':
      case 'shrugs':
        return 'Shoulders';
      case 'hammer curls':
      case 'preacher curls':
        return 'Arms';
      case 'tricep pushdowns':
      case 'overhead tricep extension':
        return 'Arms/Triceps';
      case 'leg press':
      case 'leg extensions':
      case 'hamstring curls':
      case 'calf raises':
      case 'rdls':
      case 'hip thrusts':
        return 'Legs';
      default:
        return 'Unknown';
    }
  }
}
