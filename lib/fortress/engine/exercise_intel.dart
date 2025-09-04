/// Exercise Intel System
/// Provides form protocols, safety thresholds, and tactical guidance
/// No fluff. No motivation. Just precise execution parameters.

import 'models/exercise.dart';

class ExerciseIntel {
  
  /// Get complete intelligence profile for an exercise
  static ExerciseIntelProfile getIntelProfile(String exerciseId) {
    switch (exerciseId) {
      case 'squat':
        return _squatIntel;
      case 'deadlift':
        return _deadliftIntel;
      case 'bench':
        return _benchIntel;
      case 'overhead':
        return _overheadIntel;
      case 'row':
        return _rowIntel;
      case 'pullup':
        return _pullupIntel;
      default:
        return _defaultIntel;
    }
  }
  
  /// Get quick form protocol for display
  static List<String> getFormProtocol(String exerciseId) {
    return getIntelProfile(exerciseId).formProtocol;
  }
  
  /// Get safety thresholds for exercise
  static List<String> getSafetyThresholds(String exerciseId) {
    return getIntelProfile(exerciseId).safetyThresholds;
  }
  
  /// Get execution parameters
  static Map<String, String> getExecutionParams(String exerciseId) {
    return getIntelProfile(exerciseId).executionParams;
  }
}

class ExerciseIntelProfile {
  final String exerciseId;
  final String codename;
  final List<String> formProtocol;
  final List<String> safetyThresholds;
  final Map<String, String> executionParams;
  final List<String> commonFailures;
  final String abortConditions;
  
  const ExerciseIntelProfile({
    required this.exerciseId,
    required this.codename,
    required this.formProtocol,
    required this.safetyThresholds,
    required this.executionParams,
    required this.commonFailures,
    required this.abortConditions,
  });
}

// EXERCISE INTEL PROFILES

const _squatIntel = ExerciseIntelProfile(
  exerciseId: 'squat',
  codename: 'DEPTH_CHARGE',
  formProtocol: [
    'BAR_POSITION: High bar, traps. Low bar if experienced.',
    'STANCE: Shoulder width. Toes 15-30° outward.',
    'DESCENT: Hip hinge first. Knees track over toes.',
    'DEPTH: Hip crease below knee cap. Non-negotiable.',
    'ASCENT: Drive through heels. Chest up. Knees out.',
  ],
  safetyThresholds: [
    'ABORT if knees cave inward beyond 15°',
    'ABORT if back rounds excessively',
    'ABORT if cannot achieve depth with load',
    'ABORT if balance compromised',
  ],
  executionParams: {
    'TEMPO': '3-1-X-1 (3s down, 1s pause, explosive up, 1s rest)',
    'BREATHING': 'Inhale top, hold descent, exhale through ascent',
    'SETUP_TIME': '15-30 seconds maximum',
  },
  commonFailures: [
    'Insufficient depth (above parallel)',
    'Knee valgus collapse',
    'Forward lean (chest collapse)',
    'Heel rise during ascent',
  ],
  abortConditions: 'Any form breakdown. Load reduction mandatory.',
);

const _benchIntel = ExerciseIntelProfile(
  exerciseId: 'bench',
  codename: 'PRESS_PROTOCOL',
  formProtocol: [
    'SETUP: Eyes under bar. Shoulders retracted.',
    'GRIP: Slightly wider than shoulders. Firm.',
    'ARCH: Natural arch. Glutes contact bench.',
    'DESCENT: Control to chest. Touch lightly.',
    'PRESS: Drive through feet. Straight path up.',
  ],
  safetyThresholds: [
    'NEVER bench without spotter or safety bars',
    'ABORT if bar path deviates significantly',
    'ABORT if shoulder impingement pain',
    'ABORT if cannot control descent',
  ],
  executionParams: {
    'TEMPO': '2-1-X-1 (2s down, 1s pause on chest, explosive up)',
    'BREATHING': 'Full breath at top, exhale through press',
    'BAR_SPEED': 'Controlled down, maximum velocity up',
  },
  commonFailures: [
    'Bouncing off chest',
    'Uneven bar path',
    'Loss of shoulder stability',
    'Incomplete lockout',
  ],
  abortConditions: 'Any loss of control. Safety systems non-negotiable.',
);

const _deadliftIntel = ExerciseIntelProfile(
  exerciseId: 'deadlift',
  codename: 'GROUND_EXTRACTION',
  formProtocol: [
    'BAR_POSITION: Over midfoot. Against shins.',
    'GRIP: Mixed or double overhand. Outside legs.',
    'BACK: Neutral spine. Chest up. Lats engaged.',
    'LIFT: Legs drive first. Hip extension follows.',
    'LOCKOUT: Full hip extension. Shoulders back.',
  ],
  safetyThresholds: [
    'ABORT if back rounds during lift',
    'ABORT if bar drifts away from body',
    'ABORT if knees buckle inward',
    'ABORT on first sign of form failure',
  ],
  executionParams: {
    'TEMPO': 'Controlled lift, controlled descent',
    'BREATHING': 'Deep breath, hold through lift, exhale at top',
    'BAR_PATH': 'Straight vertical line. No forward drift.',
  },
  commonFailures: [
    'Lumbar spine flexion',
    'Bar drift away from body',
    'Incomplete hip extension',
    'Knee cave on heavy loads',
  ],
  abortConditions: 'Spinal flexion = immediate termination.',
);

const _overheadIntel = ExerciseIntelProfile(
  exerciseId: 'overhead',
  codename: 'VERTICAL_DOMINANCE',
  formProtocol: [
    'SETUP: Bar at shoulder level. Elbows forward.',
    'GRIP: Shoulder width. Wrists straight.',
    'PRESS: Straight up. No forward lean.',
    'LOCKOUT: Bar over shoulders. Arms extended.',
    'CORE: Tight throughout. Prevent back arch.',
  ],
  safetyThresholds: [
    'ABORT if excessive back arch develops',
    'ABORT if bar path deviates forward',
    'ABORT on shoulder impingement',
    'ABORT if core stability lost',
  ],
  executionParams: {
    'TEMPO': 'Controlled press, brief pause, controlled descent',
    'BREATHING': 'Breath at bottom, exhale through press',
    'HEAD_POSITION': 'Neutral. Move back slightly at top.',
  },
  commonFailures: [
    'Forward bar path',
    'Excessive lumbar extension',
    'Incomplete lockout',
    'Loss of core stability',
  ],
  abortConditions: 'Any deviation from vertical plane.',
);

const _rowIntel = ExerciseIntelProfile(
  exerciseId: 'row',
  codename: 'HORIZONTAL_EXTRACTION',
  formProtocol: [
    'SETUP: Bent over 45°. Bar at arms length.',
    'GRIP: Overhand, outside shoulders.',
    'PULL: To lower chest/upper abs.',
    'SQUEEZE: Retract shoulder blades at top.',
    'CONTROL: Slow negative to start position.',
  ],
  safetyThresholds: [
    'ABORT if back rounds during pull',
    'ABORT if body momentum used excessively',
    'ABORT if cannot maintain bent position',
    'ABORT on lower back pain',
  ],
  executionParams: {
    'TEMPO': '1-1-2-1 (1s up, 1s squeeze, 2s down)',
    'BREATHING': 'Exhale on pull, inhale on descent',
    'TORSO_ANGLE': '45° lean. Maintain throughout.',
  },
  commonFailures: [
    'Using momentum/body swing',
    'Incomplete range of motion',
    'Loss of torso angle',
    'Pulling to wrong location',
  ],
  abortConditions: 'Form breakdown = load reduction required.',
);

const _pullupIntel = ExerciseIntelProfile(
  exerciseId: 'pullup',
  codename: 'VERTICAL_ASCENSION',
  formProtocol: [
    'GRIP: Overhand, outside shoulders.',
    'HANG: Full extension. Shoulders active.',
    'PULL: Chest to bar. Chin over.',
    'CONTROL: Slow descent to full hang.',
    'NO_SWING: Body remains vertical.',
  ],
  safetyThresholds: [
    'ABORT if shoulder pain develops',
    'ABORT if using excessive swing',
    'ABORT if grip fails',
    'ABORT if cannot complete range',
  ],
  executionParams: {
    'TEMPO': 'Explosive up, 2-3s controlled down',
    'BREATHING': 'Exhale on pull, inhale on descent',
    'PROGRESSION': 'Weighted > Bodyweight > Assisted',
  },
  commonFailures: [
    'Incomplete range of motion',
    'Excessive body swing/kipping',
    'Grip failure before muscle failure',
    'Forward head position',
  ],
  abortConditions: 'Maintain strict form or reduce assistance/weight.',
);

const _defaultIntel = ExerciseIntelProfile(
  exerciseId: 'unknown',
  codename: 'UNKNOWN_PROTOCOL',
  formProtocol: [
    'PROTOCOL_UNAVAILABLE: Consult qualified instructor',
    'SAFETY_FIRST: Do not attempt without proper guidance',
  ],
  safetyThresholds: [
    'ABORT if unfamiliar with exercise',
  ],
  executionParams: {
    'STATUS': 'INTEL_UNAVAILABLE',
  },
  commonFailures: [
    'Attempting unknown movements without instruction',
  ],
  abortConditions: 'No intel available. Seek proper instruction.',
);