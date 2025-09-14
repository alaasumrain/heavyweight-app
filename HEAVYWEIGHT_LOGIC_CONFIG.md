HEAVYWEIGHT Logic Config (Editable)

Purpose
- Central place to define training logic the app uses: rotation, progression, rest, calibration behavior, and unit rules. You can edit the JSON and ship new behavior without code changes (once wired).

Files
- assets/system_config.json — main logic configuration (this file documents its schema)
- assets/calibration_config.json — calibration-specific settings (already used by CalibrationService)
- assets/workout_config.json — exercise alternatives and warmups (already used by ExerciseViewModel)

Schema (assets/system_config.json)
- version: Number
- units:
  - system: "kg" | "lb"
  - incrementKg, incrementLb: Number — rounding increments
  - minWeightKg, minWeightLb: Number — default minimum floors
  - plates: { kg: Number[], lb: Number[] } — available plate sizes (optional)
  - exerciseOverrides: Map exerciseId → { minWeightKg?, minWeightLb? }
- exercises: Map exerciseId →
  - name: String
  - muscleGroup: String
  - startingWeightKg: Number
  - restSeconds: Number
  - isBodyweight: Boolean
- rotation:
  - order: ["CHEST", "BACK", "ARMS", "SHOULDERS", "LEGS"] — 5-day cycle
  - days: Map of DAY → [exerciseId]
  - dayIdMap: Map of DAY → Number (DB/Supabase IDs)
- progression:
  - thresholds: { failure|below|mandate|exceeded → { reps: String, multiplier: Number } }
  - rounding: { incrementKg, incrementLb }
  - minClampDefaultKg, minClampDefaultLb
  - overrides: Map exerciseId → { exceededMultiplier?, failureMultiplier?, belowMultiplier? }
- rest:
  - baseSeconds: Number
  - byPerformance: { failure, below, mandate, exceeded } (seconds or "base")
  - overrides: Map exerciseId → { baseSeconds? }
- calibration:
  - integratedIntoDays: Boolean
  - targetReps: Number
  - maxAttempts: Number
  - estimationOnBench: Boolean
  - benchRatios: Map exerciseId → Number
  - configFile: String (path to calibration_config.json)
- alternatives:
  - preserveLoadUsingRatio: Boolean
  - onSwap: "map_from_current" | "use_default"
  - ratios: Map "from->to" → Number (e.g., "bench->overhead": 0.66)
- enforcement:
  - minDaysBetweenWorkouts: Number
- metrics:
  - adherenceWindows: Number[]
  - plateau: { windowSessions: Number, minProgressPercent: Number }
  - track: String[] (e.g., mandateAdherence, progressionRate)
- repository:
  - useDayIdMap: Boolean
- logging:
  - enabled: Boolean
  - events: [String]

Defaults included
- Mirrors the current app behavior: 
  - Progression multipliers: 0→0.8, 1–3→0.95, 4–6→1.0, 7+→1.025
  - Rest: failure 300s, below 240s, mandate/exceeded use base 180s
  - Rounding: 2.5 kg, default min clamp 20 kg with overrides for pullups/dips = 0 kg
  - Rotation: CHEST/BACK/ARMS/SHOULDERS/LEGS with listed exercises
  - Calibration: integrated into days, 5 reps target, bench ratios provided

How we’ll use it (wiring plan)
- Engine will read units, progression, rest, and enforcement from system_config.json.
- ProtocolScreen will use calibration.integratedIntoDays to run per-exercise calibration when an exercise has no history; if bench is calibrated, we can seed other loads via benchRatios.
- Alternatives flow will use alternatives.onSwap and preserveLoadUsingRatio to map current load to the alternative using provided ratios.

Editing tips
- JSON has no comments; keep a copy of this file handy.
- Stick to known exercise IDs used in the code: squat, deadlift, bench, overhead, row, pullup, incline_db, chest_fly, dips.
- If using lb, set units.system to "lb" and adjust rounding increment to 5.

Next steps (optional)
- Wire WorkoutEngine to read system_config.json for progression and rest.
- Apply bodyweight exceptions (pullups/dips) using units.exerciseOverrides.
- Map alternatives to preserve load using alternatives.defaultRatios.
