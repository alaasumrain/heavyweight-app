import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'logging.dart';
import 'log_config.dart';

/// Lightweight loader for assets/system_config.json with safe defaults.
class SystemConfig {
  static SystemConfig? _instance;
  static SystemConfig get instance => _instance ??= SystemConfig._internal();
  SystemConfig._internal();

  Map<String, dynamic>? _data;
  bool get isLoaded => _data != null;
  final List<String> _warnings = [];
  List<String> get warnings => List.unmodifiable(_warnings);
  Map<String, dynamic> snapshot() => _data == null ? {} : jsonDecode(jsonEncode(_data!)) as Map<String, dynamic>;
  bool? _debugShortOverrideEnabled;
  int? _debugShortOverrideSeconds;

  Future<void> load() async {
    try {
      final raw = await rootBundle.loadString('assets/system_config.json');
      _data = jsonDecode(raw) as Map<String, dynamic>;
      // Update log config before emitting status event
      final logging = _data?['logging'] as Map<String, dynamic>?;
      LogConfig.update(
        mutes: (logging?['mutes'] as List?)?.map((e) => e.toString()),
        cooldownsMs: (logging?['cooldownsMs'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
        sampling: (logging?['sampling'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
      );
      _validate();
      HWLog.event('config_status', data: {
        'version': _data?['version'] ?? 0,
        'warnings': _warnings,
      });
    } catch (_) {
      _data = {};
      _warnings.clear();
      _warnings.add('FAILED_TO_LOAD_CONFIG');
      LogConfig.update();
      HWLog.event('config_status', data: {
        'version': 0,
        'warnings': _warnings,
      });
    }
  }

  void _validate() {
    _warnings.clear();
    // units
    final units = _data?['units'];
    if (units == null) _warnings.add('MISSING_units');
    // rotation
    final order = _data?['rotation']?['order'];
    if (order is! List || order.isEmpty) _warnings.add('INVALID_rotation.order');
    // progression
    final thr = _data?['progression']?['thresholds'];
    for (final k in ['failure','below','mandate','exceeded']) {
      final m = thr?[k]?['multiplier'];
      if (m == null) _warnings.add('MISSING_progression.thresholds.$k.multiplier');
    }
    // rest
    final base = _data?['rest']?['baseSeconds'];
    if (base == null) _warnings.add('MISSING_rest.baseSeconds');
    // calibration
    final maxAtt = _data?['calibration']?['maxAttempts'];
    if (maxAtt == null) _warnings.add('MISSING_calibration.maxAttempts');
  }

  // Units / rounding
  double get roundingIncrementKg =>
      _data?['units']?['incrementKg']?.toDouble() ??
      _data?['progression']?['rounding']?['incrementKg']?.toDouble() ?? 2.5;
  double get minClampDefaultKg => _data?['progression']?['minClampDefaultKg']?.toDouble() ?? 20.0;
  double minClampForExerciseKg(String exerciseId) {
    final overrides = _data?['units']?['exerciseOverrides'] as Map<String, dynamic>?;
    if (overrides != null) {
      final ov = overrides[exerciseId] as Map<String, dynamic>?;
      if (ov != null && ov['minWeightKg'] != null) {
        return (ov['minWeightKg'] as num).toDouble();
      }
    }
    return minClampDefaultKg;
  }

  double incrementForExerciseKg(String exerciseId) {
    final overrides = _data?['units']?['exerciseOverrides'] as Map<String, dynamic>?;
    if (overrides != null) {
      final ov = overrides[exerciseId] as Map<String, dynamic>?;
      if (ov != null && ov['incrementKg'] != null) {
        return (ov['incrementKg'] as num).toDouble();
      }
    }
    return roundingIncrementKg;
  }

  bool isBodyweightExercise(String exerciseId) {
    final ex = _data?['exercises']?[exerciseId] as Map<String, dynamic>?;
    if (ex == null) return false;
    final v = ex['isBodyweight'] ?? ex['bodyweight'];
    if (v is bool) return v;
    return false;
  }

  // Debug helpers
  bool get debugShortRestEnabled =>
      _debugShortOverrideEnabled ?? (_data?['debug']?['shortRest']?['enabled'] == true);
  int get debugShortRestSeconds =>
      _debugShortOverrideSeconds ?? (_data?['debug']?['shortRest']?['seconds']?.toInt() ?? 5);

  void setDebugShortRestOverride({required bool enabled, int? seconds}) {
    _debugShortOverrideEnabled = enabled;
    if (seconds != null) _debugShortOverrideSeconds = seconds;
  }
  void clearDebugShortRestOverride() {
    _debugShortOverrideEnabled = null;
    _debugShortOverrideSeconds = null;
  }

  // Progression multipliers
  double get multiplierFailure => _data?['progression']?['thresholds']?['failure']?['multiplier']?.toDouble() ?? 0.8;
  double get multiplierBelow => _data?['progression']?['thresholds']?['below']?['multiplier']?.toDouble() ?? 0.95;
  double get multiplierMandate => _data?['progression']?['thresholds']?['mandate']?['multiplier']?.toDouble() ?? 1.0;
  double get multiplierExceeded => _data?['progression']?['thresholds']?['exceeded']?['multiplier']?.toDouble() ?? 1.025;

  // Calibration knobs
  int get calibMaxAttempts => _data?['calibration']?['maxAttempts']?.toInt() ?? 3;
  double get calibTmRatio => _data?['calibration']?['tmRatio']?.toDouble() ?? 0.90;
  double get calibWorkingFromTM => _data?['calibration']?['workingFromTM']?.toDouble() ?? 0.80;

  // Rest rules
  int get baseRestSeconds => _data?['rest']?['baseSeconds']?.toInt() ?? 180;
  int restForPerformance({required String category, String? exerciseId}) {
    // Per-exercise override (baseSeconds) if present
    final overrides = _data?['rest']?['overrides'] as Map<String, dynamic>?;
    final baseOverride = (exerciseId != null && overrides != null && overrides[exerciseId] != null)
        ? (overrides[exerciseId]['baseSeconds'] as num?)?.toInt()
        : null;
    final base = baseOverride ?? baseRestSeconds;

    final perf = _data?['rest']?['byPerformance'] as Map<String, dynamic>?;
    if (perf == null) return base;
    final val = perf[category];
    if (val == null || val == 'base') return base;
    return (val as num).toInt();
  }

  // Calibration ratios
  double benchRatioFor(String exerciseId) {
    final ratios = _data?['calibration']?['benchRatios'] as Map<String, dynamic>?;
    if (ratios == null) return _defaultBenchRatio(exerciseId);
    final v = ratios[exerciseId];
    return v == null ? _defaultBenchRatio(exerciseId) : (v as num).toDouble();
  }

  // Starting weights
  double? startingWeightFor(String exerciseId) {
    final ex = _data?['exercises']?[exerciseId] as Map<String, dynamic>?;
    if (ex == null) return null;
    final v = ex['startingWeightKg'];
    return v == null ? null : (v as num).toDouble();
  }

  // Internal defaults
  double _defaultBenchRatio(String id) {
    switch (id) {
      case 'overhead': return 0.66;
      case 'row': return 0.8;
      case 'squat': return 1.2;
      case 'deadlift': return 1.5;
      case 'pullup': return 0.0;
      default: return 1.0;
    }
  }

  // Rotation
  List<String> get rotationOrder {
    final order = _data?['rotation']?['order'];
    if (order is List) {
      return order.map((e) => e.toString()).toList();
    }
    return const ["CHEST", "BACK", "ARMS", "SHOULDERS", "LEGS"];
  }

  List<String> dayExercises(String dayName) {
    final days = _data?['rotation']?['days'] as Map<String, dynamic>?;
    if (days != null) {
      final ex = days[dayName.toUpperCase()];
      if (ex is List) {
        return ex.map((e) => e.toString()).toList();
      }
    }
    return const [];
  }

  int? dayIdFor(String dayName) {
    final map = _data?['rotation']?['dayIdMap'] as Map<String, dynamic>?;
    if (map == null) return null;
    final v = map[dayName.toUpperCase()] ?? map[dayName];
    if (v == null) return null;
    return (v as num).toInt();
  }

  // Alternatives mapping
  bool get altPreserveLoad => _data?['alternatives']?['preserveLoadUsingRatio'] == true;
  String get altOnSwap => (_data?['alternatives']?['onSwap'] as String?) ?? 'map_from_current';
  double? alternativeRatio(String fromId, String toId) {
    final ratios = _data?['alternatives']?['ratios'] as Map<String, dynamic>?;
    if (ratios == null) return null;
    final key = '$fromId->$toId';
    final v = ratios[key];
    if (v == null) return null;
    return (v as num).toDouble();
  }
}
