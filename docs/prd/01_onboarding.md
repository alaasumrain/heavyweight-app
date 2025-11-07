# PRD: Onboarding & Profile Calibration

## User Stories
- **New athlete**: Understand the mandate, accept legal terms, and commit to the manifesto.
- **First-time user**: Provide baseline stats (experience, frequency, units, physical stats, rest days, session duration, objective) so the engine assigns the right protocol.
- **Returning user**: Resume onboarding where they left off, even across devices.

## UX States & Acceptance Criteria
| State | Description | Acceptance Criteria |
|-------|-------------|---------------------|
| Happy Path | Legal → Manifesto → Units → Stats → Experience → Frequency → Rest Days → Duration → Objective → Auth | All required fields stored in `AppState`, profile row upserted in Supabase, next route `/app?tab=0`. |
| Incomplete Profile | User exits mid-flow | Partial data persisted locally; resume banner surfaces; protocol gated until complete. |
| Offline | No network | Offline banner shown; profile sync queued; auth gated until network returns. |
| Validation Error | Invalid frequency/rest/units | Inline error copy; CTA disabled; `HWLog.event` recorded. |
| Auth Failure | Supabase login/signup failure | Error copy + retry; structured `auth_failed` logged; data not lost. |

## Data Contracts
- **Local**: SharedPreferences keys per `AppState` (e.g., `training_frequency`, `unit_preference`, `physical_stats`).
- **Remote**: `profiles` row upserted via Supabase; future `user_profile` view to mirror onboarding data.

## Telemetry & Metrics
- Events: `HWLog.screen` per step, `profile_*` submissions.
- Metrics: Step completion rate, drop-off per step, avg time to complete, auth failure rate.
- Alerts: Trigger when auth failures exceed 5% or profile sync retries exceed 3 attempts per user.

## Validation & Rollout
- **Automated**: Widget test covering full flow; unit tests for `AppState.nextRoute`; integration test for profile upsert.
- **Manual**: QA matrix for offline start, crash resume, invalid input, auth errors, device swap.
- **Rollout**: Feature flag gating new screens; smoke test with seeded Supabase user; rollback via flag + migration reset if needed.

