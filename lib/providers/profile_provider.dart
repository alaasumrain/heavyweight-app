import 'package:flutter/foundation.dart';

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
    _experience = experience;
    notifyListeners();
  }
  
  void setFrequency(int frequency) {
    _frequency = frequency;
    notifyListeners();
  }
  
  void setAge(int age) {
    _age = age;
    notifyListeners();
  }
  
  void setWeight(double weight) {
    _weight = weight;
    notifyListeners();
  }
  
  void setHeight(int height) {
    _height = height;
    notifyListeners();
  }
  
  void setObjective(TrainingObjective objective) {
    _objective = objective;
    notifyListeners();
  }
  
  void setUnit(Unit unit) {
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
}