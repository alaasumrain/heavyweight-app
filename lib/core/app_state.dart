import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// Centralized application state management
/// Tracks user progress through onboarding flow and determines routing
class AppState extends ChangeNotifier {
  static const String _keyLegalAccepted = 'legal_accepted';
  static const String _keyManifestoCommitted = 'manifesto_committed';
  static const String _keyTrainingExperience = 'training_experience';
  static const String _keyTrainingFrequency = 'training_frequency';
  static const String _keyUnitPreference = 'unit_preference';
  static const String _keyPhysicalStats = 'physical_stats';
  static const String _keyTrainingObjective = 'training_objective';

  // State variables
  bool _legalAccepted = false;
  bool _manifestoCommitted = false;
  String? _trainingExperience;
  String? _trainingFrequency;
  String? _unitPreference;
  String? _physicalStats;
  String? _trainingObjective;
  bool _isAuthenticated = false;

  // Getters
  bool get legalAccepted => _legalAccepted;
  bool get manifestoCommitted => _manifestoCommitted;
  String? get trainingExperience => _trainingExperience;
  String? get trainingFrequency => _trainingFrequency;
  String? get unitPreference => _unitPreference;
  String? get physicalStats => _physicalStats;
  String? get trainingObjective => _trainingObjective;
  bool get isAuthenticated => _isAuthenticated;

  /// Check if minimal profile is complete (for basic app usage)
  bool get isMinimalProfileComplete {
    return _trainingExperience != null && 
           _trainingFrequency != null && 
           _unitPreference != null &&
           _physicalStats != null &&
           _trainingObjective != null;
  }

  /// Get the next route in the complete onboarding flow
  String get nextRoute {
    if (!_legalAccepted) return '/legal';
    if (!_manifestoCommitted) return '/manifesto';
    if (_trainingExperience == null) return '/profile/experience';
    if (_trainingFrequency == null) return '/profile/frequency';
    if (_unitPreference == null) return '/profile/units';
    if (_physicalStats == null) return '/profile/stats';
    if (_trainingObjective == null) return '/profile/objective';
    if (!_isAuthenticated) return '/auth';
    return '/assignment';
  }

  /// Initialize the app state - load from persistent storage and check auth
  Future<void> initialize() async {
    await _loadFromStorage();
    await _checkAuthState();
    notifyListeners();
  }

  /// Load state from SharedPreferences
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _legalAccepted = prefs.getBool(_keyLegalAccepted) ?? false;
    _manifestoCommitted = prefs.getBool(_keyManifestoCommitted) ?? false;
    _trainingExperience = prefs.getString(_keyTrainingExperience);
    _trainingFrequency = prefs.getString(_keyTrainingFrequency);
    _unitPreference = prefs.getString(_keyUnitPreference);
    _physicalStats = prefs.getString(_keyPhysicalStats);
    _trainingObjective = prefs.getString(_keyTrainingObjective);
  }

  /// Check current authentication state
  Future<void> _checkAuthState() async {
    // Initialize auth service
    final authService = AuthService();
    await authService.initialize();
    
    // Check authentication status
    _isAuthenticated = authService.isAuthenticated;
    
    // Listen to auth changes
    authService.addListener(() {
      _isAuthenticated = authService.isAuthenticated;
      notifyListeners();
    });
  }

  /// Mark legal terms as accepted
  Future<void> acceptLegal() async {
    _legalAccepted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLegalAccepted, true);
    notifyListeners();
  }

  /// Mark manifesto as committed to
  Future<void> commitToManifesto() async {
    _manifestoCommitted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyManifestoCommitted, true);
    notifyListeners();
  }

  /// Alias for commitToManifesto (for backward compatibility)
  Future<void> commitManifesto() async {
    await commitToManifesto();
  }

  /// Update training experience
  Future<void> setTrainingExperience(String experience) async {
    _trainingExperience = experience;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTrainingExperience, experience);
    notifyListeners();
  }

  /// Alias for setTrainingExperience (for backward compatibility)
  Future<void> setExperience(String experience) async {
    await setTrainingExperience(experience);
  }

  /// Update training frequency
  Future<void> setTrainingFrequency(String frequency) async {
    _trainingFrequency = frequency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTrainingFrequency, frequency);
    notifyListeners();
  }

  /// Alias for setTrainingFrequency (for backward compatibility)
  Future<void> setFrequency(String frequency) async {
    await setTrainingFrequency(frequency);
  }

  /// Update unit preference
  Future<void> setUnitPreference(String units) async {
    _unitPreference = units;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUnitPreference, units);
    notifyListeners();
  }

  /// Update physical stats
  Future<void> setPhysicalStats(String stats) async {
    _physicalStats = stats;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhysicalStats, stats);
    notifyListeners();
  }

  /// Update training objective
  Future<void> setTrainingObjective(String objective) async {
    _trainingObjective = objective;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTrainingObjective, objective);
    notifyListeners();
  }

  /// Handle auth state changes (login/logout)
  void onAuthStateChanged() {
    final authService = AuthService();
    _isAuthenticated = authService.isAuthenticated;
    notifyListeners();
  }


  /// Reset all state (for testing or logout)
  Future<void> reset() async {
    _legalAccepted = false;
    _manifestoCommitted = false;
    _trainingExperience = null;
    _trainingFrequency = null;
    _unitPreference = null;
    _physicalStats = null;
    _trainingObjective = null;
    _isAuthenticated = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}