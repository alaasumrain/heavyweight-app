import 'package:flutter/foundation.dart';

import '../core/app_state.dart';

enum ExperienceLevel { beginner, intermediate, advanced }

enum TrainingObjective { strength, size, endurance, general }

enum Unit { kg, lb }

class ProfileProvider extends ChangeNotifier {
  ExperienceLevel? _experience;
  int? _frequency;
  int? _age;
  double? _weight;
  int? _height;
  TrainingObjective? _objective;
  Unit _unit = Unit.kg;

  // Getters
  ExperienceLevel? get experience => _experience;
  int? get frequency => _frequency;
  int? get age => _age;
  double? get weight => _weight;
  int? get height => _height;
  TrainingObjective? get objective => _objective;
  Unit get unit => _unit;

  bool get isComplete =>
      _experience != null &&
      _frequency != null &&
      _age != null &&
      _weight != null &&
      _height != null &&
      _objective != null;

  // Setters
  void setExperience(ExperienceLevel experience) {
    if (_experience == experience) return;
    _experience = experience;
    notifyListeners();
  }

  void setFrequency(int frequency) {
    if (_frequency == frequency) return;
    _frequency = frequency;
    notifyListeners();
  }

  void setAge(int age) {
    if (_age == age) return;
    _age = age;
    notifyListeners();
  }

  void setWeight(double weight) {
    if (_weight == weight) return;
    _weight = weight;
    notifyListeners();
  }

  void setHeight(int height) {
    if (_height == height) return;
    _height = height;
    notifyListeners();
  }

  void setObjective(TrainingObjective objective) {
    if (_objective == objective) return;
    _objective = objective;
    notifyListeners();
  }

  void setUnit(Unit unit) {
    if (_unit == unit) return;
    _unit = unit;
    notifyListeners();
  }

  void reset() {
    _experience = null;
    _frequency = null;
    _age = null;
    _weight = null;
    _height = null;
    _objective = null;
    _unit = Unit.kg;
    notifyListeners();
  }

  // Convert weight based on unit
  double get weightInKg {
    if (_weight == null) return 0;
    if (_unit == Unit.lb) {
      return _weight! * 0.453592; // Convert lbs to kg
    }
    return _weight!;
  }

  double get weightInLb {
    if (_weight == null) return 0;
    if (_unit == Unit.kg) {
      return _weight! * 2.20462; // Convert kg to lbs
    }
    return _weight!;
  }

  void applyAppState(AppState state) {
    bool changed = false;

    final newExperience = _experienceFromString(state.trainingExperience);
    if (_experience != newExperience) {
      _experience = newExperience;
      changed = true;
    }

    final freqString = state.trainingFrequency;
    final newFrequency = freqString == null ? null : int.tryParse(freqString);
    if (_frequency != newFrequency) {
      _frequency = newFrequency;
      changed = true;
    }

    final newObjective = _objectiveFromString(state.trainingObjective);
    if (_objective != newObjective) {
      _objective = newObjective;
      changed = true;
    }

    final newUnit = _unitFromString(state.unitPreference) ?? Unit.kg;
    if (_unit != newUnit) {
      _unit = newUnit;
      changed = true;
    }

    final stats = state.physicalStats;
    if (stats != null && stats.isNotEmpty) {
      final parts = stats.split(',');
      if (parts.length >= 3) {
        final parsedAge = int.tryParse(parts[0]);
        final parsedWeight = double.tryParse(parts[1]);
        final parsedHeight = int.tryParse(parts[2]);

        if (_age != parsedAge) {
          _age = parsedAge;
          changed = true;
        }
        if (_weight != parsedWeight) {
          _weight = parsedWeight;
          changed = true;
        }
        if (_height != parsedHeight) {
          _height = parsedHeight;
          changed = true;
        }
      }
    } else {
      if (_age != null) {
        _age = null;
        changed = true;
      }
      if (_weight != null) {
        _weight = null;
        changed = true;
      }
      if (_height != null) {
        _height = null;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  ExperienceLevel? _experienceFromString(String? value) {
    switch (value) {
      case 'beginner':
        return ExperienceLevel.beginner;
      case 'intermediate':
        return ExperienceLevel.intermediate;
      case 'advanced':
        return ExperienceLevel.advanced;
      default:
        return null;
    }
  }

  TrainingObjective? _objectiveFromString(String? value) {
    switch (value) {
      case 'strength':
        return TrainingObjective.strength;
      case 'size':
        return TrainingObjective.size;
      case 'endurance':
        return TrainingObjective.endurance;
      case 'general':
        return TrainingObjective.general;
      default:
        return null;
    }
  }

  Unit? _unitFromString(String? value) {
    switch (value) {
      case 'kg':
        return Unit.kg;
      case 'lb':
        return Unit.lb;
      default:
        return null;
    }
  }
}
