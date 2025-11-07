import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'logging.dart';

/// Debug information for onboarding route decisions
class NextRouteDebug {
  final List<String> unmetRequirements;
  final String? nextRoute;

  const NextRouteDebug({
    required this.unmetRequirements,
    required this.nextRoute,
  });
}

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
  static const String _keyPreferredStartingDay = 'preferred_starting_day';
  static const String _keyRestDays = 'rest_days';
  static const String _keySessionDurationMin = 'session_duration_min';
  static const String _keyBaselineBenchKg = 'baseline_bench_kg';
  static const String _keyBaselineSquatKg = 'baseline_squat_kg';
  static const String _keyBaselineDeadKg = 'baseline_dead_kg';

  // State variables
  bool _legalAccepted = false;
  bool _manifestoCommitted = false;
  String? _trainingExperience;
  String? _trainingFrequency;
  String? _unitPreference;
  String? _physicalStats;
  String? _trainingObjective;
  String? _preferredStartingDay;
  bool _isAuthenticated = false;
  double? _baselineBenchKg;
  double? _baselineSquatKg;
  double? _baselineDeadKg;
  List<int>? _restDays; // 0=Sun..6=Sat
  int? _sessionDurationMin;

  // Getters
  bool get legalAccepted => _legalAccepted;
  bool get manifestoCommitted => _manifestoCommitted;
  String? get trainingExperience => _trainingExperience;
  String? get trainingFrequency => _trainingFrequency;
  String? get unitPreference => _unitPreference;
  String? get physicalStats => _physicalStats;
  String? get trainingObjective => _trainingObjective;
  String? get preferredStartingDay => _preferredStartingDay;
  bool get isAuthenticated => _isAuthenticated;
  double? get baselineBenchKg => _baselineBenchKg;
  double? get baselineSquatKg => _baselineSquatKg;
  double? get baselineDeadKg => _baselineDeadKg;
  List<int>? get restDays => _restDays;
  int? get sessionDurationMin => _sessionDurationMin;

  // --- Onboarding computed helpers ---
  int? get _ageParsed {
    if (_physicalStats == null) return null;
    final parts = _physicalStats!.split(',');
    if (parts.isEmpty) return null;
    return int.tryParse(parts[0]);
  }

  double? get _weightKgParsed {
    if (_physicalStats == null) return null;
    final parts = _physicalStats!.split(',');
    if (parts.length < 2) return null;
    return double.tryParse(parts[1]);
  }

  int? get _heightCmParsed {
    if (_physicalStats == null) return null;
    final parts = _physicalStats!.split(',');
    if (parts.length < 3) return null;
    return int.tryParse(parts[2]);
  }

  bool get _hasUnits => _unitPreference != null;
  bool get _hasStats =>
      _ageParsed != null && _weightKgParsed != null && _heightCmParsed != null;
  bool get _hasRestDays => _restDays != null;
  int get _daysPerWeek => 7 - (_restDays?.length ?? 7);
  bool get _hasSessionDuration => (_sessionDurationMin ?? 0) > 0;
  bool get _hasManifesto => _manifestoCommitted == true;

  /// Check if minimal profile is complete (for basic app usage)
  bool get isMinimalProfileComplete {
    return _trainingExperience != null &&
        _trainingFrequency != null &&
        _unitPreference != null &&
        _physicalStats != null &&
        _trainingObjective != null &&
        _preferredStartingDay != null;
  }

  /// Get the next route in the complete onboarding flow
  String get nextRoute {
    // Legal first
    if (!_legalAccepted) return '/legal';
    // Streamlined onboarding order
    if (!_hasUnits) return '/profile/units';
    if (!_hasStats) return '/profile/stats';
    // Frequency guard: must be 3..6
    final freq = int.tryParse(_trainingFrequency ?? '') ?? 0;
    if (freq < 3 || freq > 6) return '/profile/frequency';
    // Rest days required: must leave at least 3 training days
    if (!_hasRestDays) return '/profile/rest-days';
    if (_daysPerWeek < 3 || _daysPerWeek > 6) return '/profile/frequency';
    if (!_hasSessionDuration) return '/profile/duration';
    // Manifesto last
    if (!_hasManifesto) return '/manifesto';
    // Optional legacy steps can be visited from Profile, do not gate here
    if (!_isAuthenticated) return '/auth';
    return '/app?tab=0';
  }

  /// Nullable variant for direct use
  String? nextOnboardingRoute() {
    if (!_hasUnits) return '/profile/units';
    if (!_hasStats) return '/profile/stats';
    final freq = int.tryParse(_trainingFrequency ?? '') ?? 0;
    if (freq < 3 || freq > 6) return '/profile/frequency';
    if (!_hasRestDays) return '/profile/rest-days';
    if (_daysPerWeek < 3 || _daysPerWeek > 6) return '/profile/frequency';
    if (!_hasSessionDuration) return '/profile/duration';
    if (!_hasManifesto) return '/manifesto';
    return null;
  }

  /// Debug struct for onboarding routing reasons
  NextRouteDebug nextOnboardingRouteDebug() {
    final unmet = <String>[];
    String? nr;
    if (!_hasUnits) {
      unmet.add('units');
      nr ??= '/profile/units';
    }
    if (!_hasStats) {
      unmet.add('stats');
      nr ??= '/profile/stats';
    }
    final freq = int.tryParse(_trainingFrequency ?? '') ?? 0;
    if (freq < 3 || freq > 6) {
      unmet.add('frequency(3-6)');
      nr ??= '/profile/frequency';
    }
    if (!_hasRestDays) {
      unmet.add('rest-days');
      nr ??= '/profile/rest-days';
    }
    if (_daysPerWeek < 3 || _daysPerWeek > 6) {
      unmet.add('days/week(3-6)');
      nr ??= '/profile/frequency';
    }
    if (!_hasSessionDuration) {
      unmet.add('duration');
      nr ??= '/profile/duration';
    }
    if (!_hasManifesto) {
      unmet.add('manifesto');
      nr ??= '/manifesto';
    }
    return NextRouteDebug(
      nextRoute: nr,
      unmetRequirements: unmet,
    );
  }

  /// Initialize the app state - load from persistent storage and check auth
  Future<void> initialize() async {
    debugPrint('🔧 AppState: Starting initialize()');
    debugPrint('🔧 AppState: About to call _loadFromStorage()');
    await _loadFromStorage();
    debugPrint('🔧 AppState: _loadFromStorage() completed');
    debugPrint('🔧 AppState: About to call _checkAuthState()');
    await _checkAuthState();
    debugPrint('🔧 AppState: _checkAuthState() completed');
    debugPrint('🔧 AppState: About to call notifyListeners()');
    notifyListeners();
    debugPrint('🔧 AppState: initialize() completed');
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
    _preferredStartingDay = prefs.getString(_keyPreferredStartingDay);
    _baselineBenchKg = prefs.getDouble(_keyBaselineBenchKg);
    _baselineSquatKg = prefs.getDouble(_keyBaselineSquatKg);
    _baselineDeadKg = prefs.getDouble(_keyBaselineDeadKg);
    final rd = prefs.getString(_keyRestDays);
    if (rd != null && rd.isNotEmpty) {
      _restDays = rd
          .split(',')
          .where((e) => e.isNotEmpty)
          .map((e) => int.tryParse(e) ?? -1)
          .where((e) => e >= 0 && e <= 6)
          .toList();
    }
    _sessionDurationMin = prefs.getInt(_keySessionDurationMin);
    // Defaults/migration
    if (_sessionDurationMin == null || _sessionDurationMin! <= 0) {
      _sessionDurationMin = 60; // default session duration
    }
    _restDays ??= <int>[]; // treat missing as empty
    // One-time migration marker (optional)
    final migrated = prefs.getBool('onboarding.migrated_v2') ?? false;
    if (!migrated) {
      await prefs.setBool('onboarding.migrated_v2', true);
    }
    // Log a snapshot of what we loaded (no PII)
    HWLog.appStateSnapshot({
      'phase': 'load_from_storage',
      'legalAccepted': _legalAccepted,
      'manifestoCommitted': _manifestoCommitted,
      'trainingExperience': _trainingExperience,
      'trainingFrequency': _trainingFrequency,
      'unitPreference': _unitPreference,
      'physicalStats': _physicalStats,
      'trainingObjective': _trainingObjective,
      'hasBaseline': _baselineBenchKg != null ||
          _baselineSquatKg != null ||
          _baselineDeadKg != null,
      'restDays': _restDays?.join(',') ?? 'none',
      'sessionDurationMin': _sessionDurationMin ?? 0,
    });
  }

  /// Save optional baseline lifts (in KG internally)
  Future<void> setBaseline(
      {double? benchKg, double? squatKg, double? deadKg}) async {
    final prefs = await SharedPreferences.getInstance();
    if (benchKg != null && benchKg > 0) {
      _baselineBenchKg = benchKg;
      await prefs.setDouble(_keyBaselineBenchKg, benchKg);
    }
    if (squatKg != null && squatKg > 0) {
      _baselineSquatKg = squatKg;
      await prefs.setDouble(_keyBaselineSquatKg, squatKg);
    }
    if (deadKg != null && deadKg > 0) {
      _baselineDeadKg = deadKg;
      await prefs.setDouble(_keyBaselineDeadKg, deadKg);
    }
    notifyListeners();
  }

  /// Check current authentication state
  Future<void> _checkAuthState() async {
    // Get existing auth service instance (already initialized in main.dart)
    final authService = AuthService();

    // Check authentication status
    _isAuthenticated = authService.isAuthenticated;
    HWLog.event('auth_state', data: {
      'phase': 'initial',
      'isAuthenticated': _isAuthenticated,
    });

    // Listen to auth changes
    authService.addListener(() {
      _isAuthenticated = authService.isAuthenticated;
      notifyListeners();
      HWLog.event('auth_state', data: {
        'phase': 'changed',
        'isAuthenticated': _isAuthenticated,
      });
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

  /// Update preferred starting day
  Future<void> setPreferredStartingDay(String startingDay) async {
    _preferredStartingDay = startingDay;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPreferredStartingDay, startingDay);
    notifyListeners();
  }

  /// Save rest days (0=Sun..6=Sat). Must leave at least 3 training days.
  Future<bool> setRestDays(List<int> days) async {
    final unique = days.toSet().where((d) => d >= 0 && d <= 6).toList()..sort();
    final trainDays = 7 - unique.length;
    if (trainDays < 3) {
      return false;
    }
    _restDays = unique;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRestDays, unique.join(','));
    notifyListeners();
    return true;
  }

  /// Save session duration in minutes (45/60/75/90)
  Future<void> setSessionDurationMin(int minutes) async {
    _sessionDurationMin = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySessionDurationMin, minutes);
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
    _preferredStartingDay = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
