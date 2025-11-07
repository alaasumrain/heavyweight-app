// ignore_for_file: constant_identifier_names

// HEAVYWEIGHT LEXICON
// Single source of truth for all user-facing strings
// ALL CAPS. TERMINAL STYLE. NO EMOJIS. NO FRIENDLY TONE.

abstract class S {
  // Core Terminology
  static const assignment = 'ASSIGNMENT';
  static const startSession = 'START_SESSION';
  static const session = 'SESSION';
  static const sessionActive = 'SESSION_ACTIVE';
  static const sessionComplete = 'SESSION_COMPLETE';
  static const baseline = 'BASELINE';
  static const trainingLog = 'TRAINING_LOG';
  static const restTimer = 'REST_TIMER';
  static const enforcedRest = 'ENFORCED_REST';
  static const iCommit = 'I_COMMIT';
  static const newMaxRecorded = 'NEW_MAX_RECORDED';
  static const operation = 'OPERATION';
  static const assignmentTarget = 'ASSIGNMENT_TARGET';
  static const schedule = 'SCHEDULE';
  static const systemSettings = 'SYSTEM_SETTINGS';

  // Screen Copy
  static const ASSIGNMENT_CHEST = 'ASSIGNMENT: CHEST';
  static const ASSIGNMENT_BACK = 'ASSIGNMENT: BACK';
  static const ASSIGNMENT_LEGS = 'ASSIGNMENT: LEGS';
  static const ASSIGNMENT_SHOULDERS = 'ASSIGNMENT: SHOULDERS';
  static const ASSIGNMENT_ARMS = 'ASSIGNMENT: ARMS';

  // Exercise Names
  static const BENCH_PRESS = 'BENCH_PRESS';
  static const SQUAT = 'SQUAT';
  static const DEADLIFT = 'DEADLIFT';
  static const OVERHEAD_PRESS = 'OVERHEAD_PRESS';
  static const ROW = 'ROW';
  static const PULLUP = 'PULLUP';

  // Commands
  static const INPUT_REPS = 'INPUT REPS:';
  static const LOG_SET = 'LOG_SET';
  static const BEGIN_ENFORCED_REST = 'COMMAND: BEGIN_ENFORCED_REST.';
  static const STAND_BY = 'STAND_BY:';

  // Baseline
  static const BASELINE_PROTOCOL_INITIATED = 'BASELINE_PROTOCOL_INITIATED.';
  static const SET_COMPLETE = 'SET \$n/\$total COMPLETE.';
  static const ANALYZING = 'ANALYZING...';
  static const INCREASE_LOAD = 'NOTE: INCREASE_LOAD.';
  static const DECREASE_LOAD = 'NOTE: DECREASE_LOAD.';
  static const LOAD_OPTIMAL = 'NOTE: LOAD_OPTIMAL.';

  // Training Log
  static const TRAINING_LOG_EMPTY = 'TRAINING_LOG_EMPTY.';
  static const PERFORMANCE_DATA_SAVED = 'PERFORMANCE_DATA_SAVED.';
  static const NEXT_ASSIGNMENT = 'NEXT_ASSIGNMENT:';

  // Status Messages
  static const ON_TARGET = 'STATUS: ON_TARGET.';
  static const TARGET_EXCEEDED = 'STATUS: TARGET_EXCEEDED.';
  static const TARGET_MISSED = 'STATUS: TARGET_MISSED.';
  static const LOAD_WILL_BE_INCREASED = 'NOTE: LOAD_WILL_BE_INCREASED.';
  static const LOAD_WILL_BE_REDUCED = 'NOTE: LOAD_WILL_BE_REDUCED.';

  // Errors & System States
  static const INPUT_INVALID = 'INPUT_INVALID. TYPE EXACTLY: I_COMMIT.';
  static const DATA_SYNC_FAILED = 'DATA_SYNC_FAILED. RETRY_LATER.';
  static const COMMAND_LOCKED = 'COMMAND_LOCKED. REST_NOT_COMPLETE.';
  static const INITIALIZING = 'INITIALIZING...';
  static const UPDATING_LOG = 'UPDATING_LOG...';
  static const OPERATION_SUCCESSFUL = 'OPERATION_SUCCESSFUL.';
  static const OPERATION_FAILED = 'OPERATION_FAILED.';
  static const NO_DATA = 'NO_DATA.';
  static const OFFLINE_MODE_ACTIVE =
      'OFFLINE_MODE_ACTIVE. LOGS_WILL_SYNC_ON_RECONNECT.';
  static const ACCESS_DENIED = 'ACCESS_DENIED.';
  static const SYSTEM_FAULT = 'SYSTEM_FAULT.';

  // Settings & Config
  static const WEIGHT_UNIT = 'WEIGHT_UNIT:';
  static const KG = 'KG';
  static const LB = 'LB';
  static const AVAILABLE_PLATES = 'AVAILABLE_PLATES:';
  static const TERMINATE_SESSION = 'TERMINATE_SESSION';

  // Rep Range
  static const MANDATE = '4-6 REPS';
  static const REPS = 'REPS';

  // Navigation
  static const NAV_ASSIGNMENT = 'ASSIGNMENT';
  static const NAV_TRAINING_LOG = 'TRAINING_LOG';
  static const NAV_SCHEDULE = 'SCHEDULE';
  static const NAV_SYSTEM_SETTINGS = 'SYSTEM_SETTINGS';
}
