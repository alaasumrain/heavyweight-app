# PRD: Settings, Data Export & Compliance

## User Stories
- Manage account, export data, reset the app safely.
- Understand privacy implications and consequences of destructive actions.

## UX States & Acceptance Criteria
| State | Description | Acceptance Criteria |
|-------|-------------|---------------------|
| Settings Overview | Entry screen | Shows app version, export/reset, support links. |
| Data Export | Request export | Generates bundle (Supabase + local); delivery confirmed. |
| Reset | Destructive action | Explicit confirmation (checkbox/typed phrase); summaries of effect; success banner. |
| Failure | Export/reset error | Clear error message, retry, event logging. |

## Data Contracts
- **Supabase**: Export queries for `workouts`, `sets`, `calibration_resume`, `user_training_state`.
- **Local**: SharedPreferences cleared on reset; optional backup before wipe.

## Telemetry & Metrics
- Events: `settings_export_data`, `settings_reset_all_*`.
- Metrics: Export success rate, reset frequency, support link usage.
- Alerts: Export failure >5%, reset error occurrences.

## Validation & Rollout
- **Automated**: Unit tests for export packaging, reset logic.
- **Manual**: QA export output, reset integrity, Supabase row cleanup.
- **Rollout**: Beta export with limited rollout; collect feedback; expand once stable.

