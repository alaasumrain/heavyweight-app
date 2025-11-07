import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/logging.dart';
import '../fortress/engine/models/exercise.dart';
import '../services/preferences_service.dart';

class ExerciseAlternative {
  final String id;
  final String name;
  final String muscleGroup;
  final double prescribedWeight;
  final String description;
  final String difficulty;

  const ExerciseAlternative({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.prescribedWeight,
    required this.description,
    required this.difficulty,
  });

  factory ExerciseAlternative.fromJson(Map<String, dynamic> json) {
    return ExerciseAlternative(
      id: json['id'],
      name: json['name'],
      muscleGroup: json['muscleGroup'],
      prescribedWeight: (json['prescribedWeight'] as num).toDouble(),
      description: json['description'],
      difficulty: json['difficulty'],
    );
  }

  Exercise toExercise() {
    return Exercise(
      id: id,
      name: name,
      muscleGroup: muscleGroup,
      prescribedWeight: prescribedWeight,
      description: description,
    );
  }
}

class WarmUpExercise {
  final String name;
  final int? duration;
  final int? reps;
  final String description;

  const WarmUpExercise({
    required this.name,
    this.duration,
    this.reps,
    required this.description,
  });

  factory WarmUpExercise.fromJson(Map<String, dynamic> json) {
    return WarmUpExercise(
      name: json['name'],
      duration: json['duration'],
      reps: json['reps'],
      description: json['description'],
    );
  }
}

class ExerciseViewModel extends ChangeNotifier {
  static const _prefsKey = 'hw_selected_alternatives';
  Map<String, List<ExerciseAlternative>>? _exerciseAlternatives;
  Map<String, List<WarmUpExercise>>? _warmUpTemplates;
  final Map<String, String> _selectedAlternatives = {};
  bool _isLoaded = false;
  String? _error;
  final PreferencesService _preferencesService;

  ExerciseViewModel({PreferencesService? preferencesService})
      : _preferencesService = preferencesService ?? PreferencesService();

  bool get isLoaded => _isLoaded;
  String? get error => _error;
  Map<String, List<ExerciseAlternative>>? get exerciseAlternatives =>
      _exerciseAlternatives;
  Map<String, List<WarmUpExercise>>? get warmUpTemplates => _warmUpTemplates;

  Future<void> initialize() async {
    try {
      HWLog.event('exercise_viewmodel_init');

      final String response =
          await rootBundle.loadString('assets/workout_config.json');
      final Map<String, dynamic> data = json.decode(response);

      // Load exercise alternatives
      final alternatives =
          data['exercise_alternatives'] as Map<String, dynamic>;
      _exerciseAlternatives = {};

      alternatives.forEach((muscleGroup, exercises) {
        final exerciseMap = exercises as Map<String, dynamic>;
        exerciseMap.forEach((exerciseId, alternativesList) {
          final alternatives = (alternativesList as List)
              .map((alt) => ExerciseAlternative.fromJson(alt))
              .toList();
          _exerciseAlternatives![exerciseId] = alternatives;
        });
      });

      // Load warm-up templates
      final warmUps = data['warm_up_templates'] as Map<String, dynamic>;
      _warmUpTemplates = {};

      warmUps.forEach((muscleGroup, exercises) {
        final exerciseList = (exercises as List)
            .map((ex) => WarmUpExercise.fromJson(ex))
            .toList();
        _warmUpTemplates![muscleGroup] = exerciseList;
      });

      _isLoaded = true;
      _error = null;
      HWLog.event('exercise_viewmodel_loaded', data: {
        'alternatives_count': _exerciseAlternatives?.length ?? 0,
        'warmup_templates': _warmUpTemplates?.length ?? 0,
      });

      await _rehydrateSelections();
    } catch (e) {
      _error = e.toString();
      _isLoaded = false;
      HWLog.event('exercise_viewmodel_init_failed',
          data: {'error': e.toString()});
    }

    notifyListeners();
  }

  List<ExerciseAlternative> getAlternativesFor(String exerciseId) {
    if (!_isLoaded || _exerciseAlternatives == null) {
      return [];
    }
    return _exerciseAlternatives![exerciseId] ?? [];
  }

  List<WarmUpExercise> getWarmUpFor(String muscleGroup) {
    if (!_isLoaded || _warmUpTemplates == null) {
      return [];
    }
    return _warmUpTemplates![muscleGroup.toLowerCase()] ?? [];
  }

  ExerciseAlternative? getSelectedAlternative(String originalExerciseId) {
    if (!_isLoaded || _exerciseAlternatives == null) {
      return null;
    }

    final selectedId = _selectedAlternatives[originalExerciseId];
    if (selectedId == null) {
      // Return the first alternative (usually the original exercise)
      final alternatives = getAlternativesFor(originalExerciseId);
      return alternatives.isNotEmpty ? alternatives.first : null;
    }

    // Find the selected alternative
    final alternatives = getAlternativesFor(originalExerciseId);
    try {
      return alternatives.firstWhere((alt) => alt.id == selectedId);
    } catch (e) {
      return alternatives.isNotEmpty ? alternatives.first : null;
    }
  }

  void selectAlternative(String originalExerciseId, String alternativeId) {
    _selectedAlternatives[originalExerciseId] = alternativeId;
    HWLog.event('exercise_alternative_selected', data: {
      'original_id': originalExerciseId,
      'selected_id': alternativeId,
    });
    _persistSelections();
    notifyListeners();
  }

  Exercise? getExerciseWithAlternative(String originalExerciseId) {
    final alternative = getSelectedAlternative(originalExerciseId);
    return alternative?.toExercise();
  }

  Map<String, String> getSelectedAlternatives() {
    return Map.from(_selectedAlternatives);
  }

  void resetSelections() {
    _selectedAlternatives.clear();
    HWLog.event('exercise_alternatives_reset');
    _persistSelections();
    notifyListeners();
  }

  bool hasAlternatives(String exerciseId) {
    return getAlternativesFor(exerciseId).length > 1;
  }

  int getAlternativesCount(String exerciseId) {
    return getAlternativesFor(exerciseId).length;
  }

  Future<void> _rehydrateSelections() async {
    try {
      await _ensurePreferencesReady();
      final jsonString = _preferencesService.getString(_prefsKey);
      if (jsonString == null || jsonString.isEmpty) return;

      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      final cleaned = <String, String>{};

      decoded.forEach((exerciseId, alternativeId) {
        if (alternativeId is! String) {
          return;
        }
        final alternatives = getAlternativesFor(exerciseId);
        if (alternatives.any((alt) => alt.id == alternativeId)) {
          cleaned[exerciseId] = alternativeId;
        }
      });

      if (cleaned.isNotEmpty) {
        _selectedAlternatives
          ..clear()
          ..addAll(cleaned);
        HWLog.event('exercise_alternatives_rehydrated',
            data: {'count': cleaned.length});
      }
    } catch (e) {
      HWLog.event('exercise_alternatives_rehydrate_error',
          data: {'error': e.toString()});
    }
  }

  Future<void> _persistSelections() async {
    try {
      await _ensurePreferencesReady();
      await _preferencesService
          .setString(_prefsKey, jsonEncode(_selectedAlternatives));
    } catch (error) {
      HWLog.event('exercise_alternatives_persist_error',
          data: {'error': error.toString()});
    }
  }

  Future<void> _ensurePreferencesReady() async {
    if (!_preferencesService.isReady) {
      await _preferencesService.initialize();
    }
  }
}
