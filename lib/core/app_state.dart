import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/supabase/supabase.dart';

/// Centralized application state management
/// Tracks user progress through onboarding flow and determines routing
class AppState extends ChangeNotifier {
  static const String _keyLegalAccepted = 'legal_accepted';
  static const String _keyManifestoCommitted = 'manifesto_committed';
  static const String _keyTrainingExperience = 'training_experience';
  static const String _keyTrainingFrequency = 'training_frequency';
  static const String _keyUnitPreference = 'unit_preference';

  // State variables
  bool _legalAccepted = false;
  bool _manifestoCommitted = false;
  String? _trainingExperience;
  String? _trainingFrequency;
  String? _unitPreference;
  bool _isAuthenticated = false;

  // Getters
  bool get legalAccepted => _legalAccepted;
  bool get manifestoCommitted => _manifestoCommitted;
  String? get trainingExperience => _trainingExperience;
  String? get trainingFrequency => _trainingFrequency;
  String? get unitPreference => _unitPreference;
  bool get isAuthenticated => _isAuthenticated;

  /// Check if minimal profile is complete (for basic app usage)
  bool get isMinimalProfileComplete {
    return _trainingExperience != null && 
           _trainingFrequency != null && 
           _unitPreference != null;
  }

  /// Get the initial route based on current completion state
  String get initialRoute {
    if (!_legalAccepted) return '/legal';
    if (!_manifestoCommitted) return '/manifesto';
    if (!isMinimalProfileComplete) return '/profile';
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
  }

  /// Check current authentication state
  Future<void> _checkAuthState() async {
    _isAuthenticated = supabase.auth.currentSession != null;
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

  /// Handle auth state changes (login/logout)
  void onAuthStateChanged() {
    _isAuthenticated = supabase.auth.currentSession != null;
    notifyListeners();
  }

  /// Determine redirect route based on current URL and completion state
  String? getRedirectRoute(String currentLocation) {
    final targetRoute = initialRoute;
    
    // If we're already at the target route, no redirect needed
    if (currentLocation == targetRoute) return null;
    
    // If we're at splash and should go somewhere else, redirect
    if (currentLocation == '/' && targetRoute != '/') return targetRoute;
    
    // Check if we need to enforce flow order
    final routeOrder = ['/legal', '/manifesto', '/profile', '/auth', '/assignment'];
    final currentIndex = routeOrder.indexOf(currentLocation);
    final targetIndex = routeOrder.indexOf(targetRoute);
    
    // If current route is ahead of where we should be, redirect back
    if (currentIndex > targetIndex) return targetRoute;
    
    // No redirect needed
    return null;
  }

  /// Reset all state (for testing or logout)
  Future<void> reset() async {
    _legalAccepted = false;
    _manifestoCommitted = false;
    _trainingExperience = null;
    _trainingFrequency = null;
    _unitPreference = null;
    _isAuthenticated = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}