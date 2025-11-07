// Exercise Intel System
// Provides form protocols, safety thresholds, and tactical guidance
// No fluff. No motivation. Just precise execution parameters.

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
    'Set the bar across your traps (use low-bar only if you already train with it).',
    'Stand shoulder-width with toes turned slightly out.',
    'Sit back with your hips and let knees track over your toes.',
    'Squat until your hips drop just below your knees.',
    'Drive up through the floor and keep your chest tall.',
  ],
  safetyThresholds: [
    'Stop the set if your knees cave inward.',
    'Stop if your lower back starts rounding.',
    'Pause if you lose balance or can’t reach depth.',
    'Use spotters when the bar feels unstable.',
  ],
  executionParams: {
    'Tempo': '3 seconds down, brief pause, drive up fast.',
    'Breathing':
        'Take a deep breath before you descend, hold it, exhale on the way up.',
    'Setup': 'Give yourself 15-30 seconds to brace and center the bar.',
  },
  commonFailures: [
    'Cutting the squat high.',
    'Knees caving in at the bottom.',
    'Chest dropping forward.',
    'Heels lifting off the floor.',
  ],
  abortConditions:
      'If balance, depth, or back position breaks down, rack the bar and reset with lighter weight.',
);

const _benchIntel = ExerciseIntelProfile(
  exerciseId: 'bench',
  codename: 'PRESS_PROTOCOL',
  formProtocol: [
    'Set up with eyes under the bar and upper back tight.',
    'Grip the bar slightly wider than shoulders and squeeze hard.',
    'Keep a natural arch with glutes and shoulders on the bench.',
    'Lower the bar under control to mid chest with a light touch.',
    'Drive the bar up while pushing your feet through the floor.',
  ],
  safetyThresholds: [
    'Always bench with safeties or a spotter.',
    'Stop the set if the bar wanders forward or backward.',
    'Stop if you feel sharp shoulder pain.',
    'Abort if the bar drops faster than you can control.',
  ],
  executionParams: {
    'Tempo': '2 seconds down, short pause on the chest, press up with speed.',
    'Breathing': 'Fill your belly at the top, hold, exhale at lockout.',
    'Bar Speed': 'Smooth on the way down, aggressive on the press.',
  },
  commonFailures: [
    'Bouncing the bar off your chest.',
    'Pressing unevenly or twisting wrists.',
    'Losing shoulder tightness.',
    'Not locking elbows at the top.',
  ],
  abortConditions:
      'If control or shoulder stability disappears, rack it immediately and reduce the load.',
);

const _deadliftIntel = ExerciseIntelProfile(
  exerciseId: 'deadlift',
  codename: 'GROUND_EXTRACTION',
  formProtocol: [
    'Line the bar over mid-foot and keep it close to your shins.',
    'Grip with mixed or double overhand just outside your legs.',
    'Brace a neutral spine, chest up, lats tight.',
    'Push the floor away with your legs before you hinge hips through.',
    'Stand tall with full hip extension and shoulders back.',
  ],
  safetyThresholds: [
    'End the set if your back starts to round.',
    'Stop if the bar drifts away from your shins.',
    'Stop if your knees buckle inward.',
    'Reset after any noticeable form breakdown.',
  ],
  executionParams: {
    'Tempo': 'Controlled off the floor and on the way down.',
    'Breathing': 'Deep breath before you pull, hold it, exhale at lockout.',
    'Bar Path':
        'Keep the bar traveling straight up and down against your legs.',
  },
  commonFailures: [
    'Rounded lower back.',
    'Bar drifting away from your body.',
    'Not finishing the hip lockout.',
    'Knees collapsing inward on heavy pulls.',
  ],
  abortConditions:
      'If your back rounds or the bar leaves your shins, stop the set and reset with lighter weight.',
);

const _overheadIntel = ExerciseIntelProfile(
  exerciseId: 'overhead',
  codename: 'VERTICAL_DOMINANCE',
  formProtocol: [
    'Rest the bar on your shoulders with elbows slightly forward.',
    'Grip at shoulder width with wrists stacked and straight.',
    'Press straight up keeping the bar close to your face.',
    'Lock out with the bar stacked over shoulders, hips, and feet.',
    'Brace your core to prevent your lower back from arching.',
  ],
  safetyThresholds: [
    'Stop the set if your lower back over-arches.',
    'Stop if the bar drifts forward of your head.',
    'Pause if you feel shoulder impingement.',
    'Reset if you lose core stability.',
  ],
  executionParams: {
    'Tempo': 'Controlled press, brief pause overhead, smooth return.',
    'Breathing': 'Breathe at the bottom, brace, exhale at lockout.',
    'Head Position':
        'Keep a neutral gaze and move your head slightly back as the bar passes.',
  },
  commonFailures: [
    'Pressing the bar forward.',
    'Leaning back and overextending.',
    'Stopping short of full lockout.',
    'Losing core tension mid set.',
  ],
  abortConditions:
      'If you can’t keep the bar stacked over your shoulders and mid-foot, lower the weight and reset.',
);

const _rowIntel = ExerciseIntelProfile(
  exerciseId: 'row',
  codename: 'HORIZONTAL_EXTRACTION',
  formProtocol: [
    'Hinge to about 45° with a strong, flat back.',
    'Grip overhand just outside your shoulders.',
    'Pull the bar toward your lower chest or upper abs.',
    'Squeeze your shoulder blades together at the top.',
    'Lower the bar under control back to start.',
  ],
  safetyThresholds: [
    'Stop if your back rounds during the pull.',
    'Stop if you need to use momentum to move the weight.',
    'Reset if you can’t hold the bent-over position.',
    'Pause immediately if your lower back hurts.',
  ],
  executionParams: {
    'Tempo': 'Pull with intent, squeeze briefly, lower in about 2 seconds.',
    'Breathing': 'Exhale as you pull, inhale as you lower.',
    'Torso Angle': 'Hold the hinge angle steady for every rep.',
  },
  commonFailures: [
    'Swinging the weight with your body.',
    'Stopping short of a full pull.',
    'Standing up mid-set and losing the hinge.',
    'Pulling too high or too low on your torso.',
  ],
  abortConditions:
      'If the hinge or control falls apart, set the bar down and reset before the next set.',
);

const _pullupIntel = ExerciseIntelProfile(
  exerciseId: 'pullup',
  codename: 'VERTICAL_ASCENSION',
  formProtocol: [
    'Grip the bar overhand just outside shoulder width.',
    'Hang with elbows straight and shoulders active.',
    'Pull until your chest is close to the bar and chin clears.',
    'Lower slowly back to a full hang.',
    'Keep your body still—no swinging or kipping.',
  ],
  safetyThresholds: [
    'Stop if your shoulders start to hurt.',
    'Stop if you need to swing or kip to finish reps.',
    'End the set when your grip slips.',
    'Pause if you can’t hit full range of motion.',
  ],
  executionParams: {
    'Tempo': 'Strong pull up, 2-3 seconds lowering back down.',
    'Breathing': 'Exhale on the pull, inhale as you lower.',
    'Progression': 'Add weight only after you own bodyweight reps.',
  },
  commonFailures: [
    'Stopping short of the bar.',
    'Using a big swing to finish reps.',
    'Grip failing before your back does.',
    'Reaching with your chin instead of your chest.',
  ],
  abortConditions:
      'If strict reps fall apart, drop from the bar, rest, and continue with lighter assistance.',
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
