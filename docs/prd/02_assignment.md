# PRD: Daily Assignment & Preparation

## User Stories
- **Committed athlete**: Review today’s mandate, load, and alternatives before training.
- **Returning mid-session**: Resume where they left off without losing progress.
- **Swap experimenter**: Persist alternative selections so the UI reflects choices next launch.

## UX States & Acceptance Criteria
| State | Description | Acceptance Criteria |
|-------|-------------|---------------------|
| Happy Path | Assignment list with loads, statuses, swap affordances | `WorkoutViewModel` supplies workout; alternatives loaded; calibration badges accurate. |
| Loading | Awaiting workout history or alternatives | Skeleton/loading indicator; CTA disabled; auto retry. |
| Resume Available | Snapshot detected | Resume banner; tapping resumes protocol with restored state. |
| Alternatives Error | Config load failure | Retry banner; swap icons disabled; `exercise_viewmodel_init_failed` logged. |
| Rest Day | No workout | Rest-day panel; begin training CTA hidden. |

## Data Contracts
- **Local**: `CacheService` for today’s workout; `WorkoutSessionManager` for session state; SharedPreferences persistence for alternative selections.
- **Remote**: `user_training_state` updated on assignment; `sets`/`workouts` untouched until protocol begins.
- **Assets**: `assets/workout_config.json` for alternatives and warm-ups.

## Telemetry & Metrics
- Events: `assignment_build`, `assignment_load_stats_*`, `exercise_alternative_selected`, `exercise_alternatives_rehydrated`, `exercise_alternatives_*_error`, `workout_session_*`.
- Metrics: Alternative usage rate, resume acceptance rate, assignment load latency/failure rate, config failure frequency.
- Alerts: Trigger if assignment load p95 > 2s or alternative load failure >10%.

## Validation & Rollout
- **Automated**: Widget test for assignment render & swap; unit test for resume state retrieval; integration test for rest-day branch.
- **Manual**: Scenarios for alternative retry, resume accept/decline, offline cache, calibration badge.
- **Rollout**: Gate alternative persistence behind flag; monitor swap telemetry before general release.
