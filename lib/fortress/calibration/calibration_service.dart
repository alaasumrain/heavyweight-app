import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/logging.dart';

/// Configurable calibration service for finding 5RM
/// Reads settings from calibration_config.json
class CalibrationService {
  static CalibrationService? _instance;
  static CalibrationService get instance =>
      _instance ??= CalibrationService._();
  CalibrationService._();

  Map<String, dynamic>? _config;

  /// Load calibration configuration from assets
  Future<void> loadConfig() async {
    try {
      final configString =
          await rootBundle.loadString('assets/calibration_config.json');
      _config = json.decode(configString);
      HWLog.event('calibration_config_loaded');
    } catch (e) {
      HWLog.event('calibration_config_error', data: {'error': e.toString()});
      // Use defaults if config fails to load
      _config = _getDefaultConfig();
    }
  }

  /// Calculate next calibration weight based on performance
  double calculateNextWeight(double currentWeight, int actualReps) {
    final multipliers = _config?['rep_multipliers'] ?? _getDefaultMultipliers();

    // Get exact multiplier for this rep count
    double multiplier = 1.0;

    // First try exact rep match
    final repString = actualReps.toString();
    if (multipliers.containsKey(repString)) {
      multiplier = (multipliers[repString] ?? 1.0).toDouble();
    } else if (actualReps > 25) {
      // Beyond our table - use highest multiplier
      multiplier = (multipliers['25'] ?? 2.2).toDouble();
    } else {
      // Fallback to closest value (shouldn't happen with our complete table)
      multiplier = 1.0;
    }

    final newWeight = currentWeight * multiplier;
    final safetyLimits = _config?['safety_limits'] ?? _getDefaultSafetyLimits();
    final minWeight = (safetyLimits['min_weight'] ?? 20.0).toDouble();
    final maxIncrease =
        (safetyLimits['max_increase_per_attempt'] ?? 50.0).toDouble();
    final maxDecrease =
        (safetyLimits['max_decrease_per_attempt'] ?? 30.0).toDouble();

    // Apply safety limits
    double safeWeight = newWeight;
    if (newWeight > currentWeight + maxIncrease) {
      safeWeight = currentWeight + maxIncrease;
    } else if (newWeight < currentWeight - maxDecrease) {
      safeWeight = currentWeight - maxDecrease;
    }

    // Never go below minimum weight
    safeWeight = safeWeight < minWeight ? minWeight : safeWeight;

    // Round to 2.5kg increments
    final rounded = (safeWeight / 2.5).round() * 2.5;

    HWLog.event('calibration_weight_calculated', data: {
      'currentWeight': currentWeight,
      'actualReps': actualReps,
      'multiplier': multiplier,
      'newWeight': rounded,
    });

    return rounded;
  }

  /// Get warmup protocol for exercise
  List<Map<String, dynamic>> getWarmupProtocol(
      String exerciseId, double targetWeight) {
    final warmups = _config?['warmup_protocols'] ?? {};
    final protocol =
        warmups[exerciseId] ?? warmups['default'] ?? _getDefaultWarmup();

    return (protocol as List).map((warmup) {
      final percentage = (warmup['percentage'] ?? 0.4).toDouble();
      final weight =
          (targetWeight * percentage / 2.5).round() * 2.5; // Round to 2.5kg

      return {
        'weight': weight < 20.0 ? 20.0 : weight, // Never below bar weight
        'reps': warmup['reps'] ?? 5,
        'rest': warmup['rest'] ?? 60,
        'description': warmup['description'] ?? 'Warmup set',
      };
    }).toList();
  }

  /// Get feedback message for reps achieved
  String getFeedbackMessage(int actualReps) {
    final feedback = _config?['calibration_feedback'] ?? _getDefaultFeedback();

    if (actualReps >= 20) return feedback['20+'] ?? 'WAY TOO LIGHT';
    if (actualReps >= 15) return feedback['15-19'] ?? 'TOO LIGHT';
    if (actualReps >= 12) return feedback['12-14'] ?? 'LIGHT';
    if (actualReps >= 8) return feedback['8-11'] ?? 'GETTING CLOSER';
    if (actualReps >= 6) return feedback['6-7'] ?? 'VERY CLOSE';
    if (actualReps == 5) return feedback['5'] ?? 'PERFECT - 5RM FOUND!';
    if (actualReps == 4) return feedback['4'] ?? 'SLIGHTLY HEAVY';
    if (actualReps >= 1) return feedback['1-3'] ?? 'TOO HEAVY';
    return feedback['0'] ?? 'COMPLETE FAILURE';
  }

  /// Get maximum calibration attempts
  int get maxAttempts => _config?['calibration_settings']?['max_attempts'] ?? 5;

  /// Check if warmups are enabled
  bool get warmupsEnabled =>
      _config?['calibration_settings']?['enable_warmups'] ?? true;

  /// Get rest time between calibration attempts
  int get restBetweenAttempts =>
      _config?['calibration_settings']?['rest_between_attempts'] ?? 180;

  Map<String, dynamic> _getDefaultConfig() {
    return {
      'calibration_settings': {
        'max_attempts': 5,
        'target_reps': 5,
        'enable_warmups': true,
      },
      'rep_multipliers': {
        '20+': 2.0,
        '15-19': 1.8,
        '12-14': 1.6,
        '8-11': 1.3,
        '6-7': 1.05,
        '4-5': 0.95,
        '1-3': 0.85,
        '0': 0.7,
      },
    };
  }

  Map<String, double> _getDefaultMultipliers() {
    return {
      '20+': 2.0,
      '15-19': 1.8,
      '12-14': 1.6,
      '8-11': 1.3,
      '6-7': 1.05,
      '4-5': 0.95,
      '1-3': 0.85,
      '0': 0.7,
    };
  }

  Map<String, double> _getDefaultSafetyLimits() {
    return {
      'min_weight': 20.0,
      'max_increase_per_attempt': 50.0,
      'max_decrease_per_attempt': 30.0,
    };
  }

  List<Map<String, dynamic>> _getDefaultWarmup() {
    return [
      {'percentage': 0.4, 'reps': 8, 'rest': 60, 'description': 'Light warmup'},
      {
        'percentage': 0.65,
        'reps': 5,
        'rest': 90,
        'description': 'Medium warmup'
      },
    ];
  }

  Map<String, String> _getDefaultFeedback() {
    return {
      '20+': 'WAY TOO LIGHT - Major jump needed',
      '15-19': 'TOO LIGHT - Big increase',
      '12-14': 'LIGHT - Significant increase',
      '8-11': 'GETTING CLOSER - Moderate increase',
      '6-7': 'VERY CLOSE - Small adjustment',
      '5': 'PERFECT - 5RM FOUND!',
      '4': 'SLIGHTLY HEAVY - Small reduction',
      '1-3': 'TOO HEAVY - Reduce weight',
      '0': 'COMPLETE FAILURE - Major reduction',
    };
  }
}
