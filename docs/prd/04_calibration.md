# PRD: Calibration & Warm-Up Guidance

## User Stories
- **New athlete**: Calibrate loads so mandate starts at correct intensity.
- **Returning athlete**: Resume calibration after interruptions across devices.
- **All athletes**: Receive warm-up suggestions tailored to the session.

## UX States & Acceptance Criteria
| State | Description | Acceptance Criteria |
|-------|-------------|---------------------|
| Calibration Active | Calibration protocol running | Shows attempt number, load, guidance; saves after each set. |
| Resume Calibration | Resume prompt | Detects existing data; resumes without duplication; offers skip option. |
| Calibration Complete | Finalized | Marks calibration done; updates profile/exercise weights. |
| Warm-Up Panel | Pre-session guidance | Displays templates from config; fallback text if load fails. |
| Sync Failure | Supabase/asset error | Banner + retry; maintain local copy; log failure event. |

## Data Contracts
- **Local**: `CalibrationResumeStore` (SharedPreferences); templates from `assets/workout_config.json`.
- **Remote**: `calibration_resume` table; final 1RM stored in `profiles.exercise_weights`.

## Telemetry & Metrics
- Events: `calibration_config_loaded`, `calibration_weight_calculated`, `calibration_resume_*`.
- Metrics: Completion rate, attempts per exercise, resume success rate, config error rate.
- Alerts: Calibration resume fetch failures >5%; warm-up config missing.

## Validation & Rollout
- **Automated**: Unit tests for weight progression, serialization, config parsing.
- **Manual**: Offline resume, multi-device scenario, corrupted config fallback.
- **Rollout**: Migration checklist for schema updates; warm-up changes versioned in config.

