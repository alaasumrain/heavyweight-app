# PRD: Protocol Execution & Rest Management

## User Stories
- **In-session athlete**: Log sets quickly with focused UI, following mandated rest.
- **High performer**: Skip/extend rest responsibly with coaching feedback.
- **Overreaching athlete**: Respect enforced rest to prevent overtraining.

## UX States & Acceptance Criteria
| State | Description | Acceptance Criteria |
|-------|-------------|---------------------|
| Active Logging | SessionActive capturing reps/notes | Submissions update UI history; session snapshot saved. |
| Rest Timer | Countdown with skip/extend | Rules enforced; skip/extend events logged; completion triggers next set. |
| Enforced Rest | Mandatory cooldown screen | Navigation disabled until timer done; messaging clear. |
| Session Complete | Post-workout summary | Shows totals; Supabase writes succeed; session snapshot cleared. |
| Error States | Supabase or snapshot errors | User sees retry/continue prompt; logs contain error detail; no silent data loss. |

## Data Contracts
- **Local**: `WorkoutSessionManager` snapshots; rest state in `ProtocolScreen`; `CacheService` invalidations.
- **Remote**: `workouts` created on start; `sets` appended per logged set (plan idempotency key); `user_training_state` updated after completion.
- **Future**: Telemetry table for rest deviations.

## Telemetry & Metrics
- Events: `protocol_start_rest`, `rest_timer_*`, `session_active_log_set`, `workout_session_saved/cleared`, `training_session_restored`.
- Metrics: Rest adherence, set logging latency, completion rate, crash/abandon rate mid-protocol.
- Alerts: Supabase write latency >3s p95; rest completion failures >1%.

## Validation & Rollout
- **Automated**: Integration test for full workout; unit tests for rest gating; tests for session serialization compatibility.
- **Manual**: Mid-session crash recovery, offline logging, enforced rest, duplicate submission guard.
- **Rollout**: Flag rest copy/logic; watch telemetry before full rollout.

