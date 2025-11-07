# HEAVYWEIGHT Product Audit (2025-02)

## Purpose
- Capture how the current build behaves end to end so we can benchmark future changes against a known baseline.
- Surface weak links in onboarding, daily training, recovery, monetization, and supporting infrastructure.
- Translate observations into actionable pull-request ideas the team can chip away at.

## App Pillars at a Glance
- **Mandate-first training loop** – `WorkoutEngine` drives a fixed rotation (CHEST → BACK → ARMS → SHOULDERS → LEGS) plus adaptive loads and rest (`lib/fortress/engine/workout_engine.dart`).
- **Dual persistence for state** – Immediate UX relies on `SharedPreferences` (`AppState`, `TrainingState`, `WorkoutSessionManager`), while Supabase provides durable history and cross-device sync (`lib/backend/supabase/`).
- **Structured but local-only telemetry** – `HWLog` prints JSON in debug builds (`lib/core/logging.dart`), letting us trace flows during development yet leaving release builds largely blind.

## User Journeys & Touchpoints

### Onboarding & Profile Calibration
**Flow**
1. Legal gate → manifesto commitment → profile stack (`lib/screens/onboarding/`).
2. Profile sub-flows capture units, stats, experience, frequency, rest days, duration, and objectives (`ProfileProvider`, `AppState`).
3. Authentication gate (`lib/screens/onboarding/auth_screen.dart`).

**Data & Dependencies**
- `AppState` stores every onboarding decision in `SharedPreferences` (`lib/core/app_state.dart`).
- Routing derives from `AppState.nextRoute`, guarded by minimum training frequency (3–6) and rest-day balance.
- `ProfileProvider` holds in-memory edits before persisting via `AppStateProvider`.

**Guardrails Already in Place**
- Frequency selector clamps to 3–6 days (`training_frequency_screen.dart`).
- Rest-day picker enforces ≥3 training days and ≤6 (`rest_days_screen.dart`).
- Manifesto completion required before authentication.

**Weak Spots / Risks**
- Profile decisions live only locally until Supabase auth succeeds; reinstalling before login wipes progress.
- No network-awareness: a user can reach auth while offline and stall without clear recovery.
- Lack of validation telemetry; failures or abandonment in onboarding are invisible outside debug sessions.

**Opportunities**
- Mirror onboarding data into a `user_profile` row once Supabase auth is available, keeping SharedPreferences as cache.
- Add offline banners plus retry flows around auth and Supabase writes.
- Emit structured events (with eventual remote transport) for each milestone to measure funnel drop-off.

### Daily Assignment & Preparation
**Flow**
1. `AssignmentScreen` (`lib/screens/training/assignment_screen.dart`) summarizes the mandate, rest status, and exercise list.
2. `DailyWorkoutScreen` (`lib/screens/training/daily_workout_screen.dart`) becomes the launch pad and handles session resume prompts.
3. Exercise alternatives come from `ExerciseViewModel` and `assets/workout_config.json`.

**Data & Dependencies**
- `WorkoutViewModel.initialize()` pulls history via `SupabaseWorkoutRepository`, caches workouts, and primes `TrainingState`.
- `WorkoutSessionManager` keeps a 4-hour local snapshot for crash recovery.
- Alternative selections are session-scoped in-memory (`ExerciseViewModel._selectedAlternatives`).

**Weak Spots / Risks**
- Alternative choices persist locally but are still not mirrored to Supabase, so cross-device swaps drift.
- Resume banner only checks SharedPreferences; if a crash happens before `WorkoutSessionManager.saveActiveSession` runs, progress is lost.
- Assignment now surfaces alternative-config failures, but there is no automatic backoff/retry strategy or remote alerting.

**Opportunities**
- Mirror alternative selections to Supabase (and expose in assignment UI) so swaps follow users across devices.
- Gate the “Begin Training” button until alternatives load successfully or adopt a background retry with status indicator.
- Extend the session snapshot to upload partial set data, protecting against OS purges beyond 4 hours.

### Calibration & Warm-Up Flow
**Flow**
1. Calibration entry points surface whenever `WorkoutViewModel.needsCalibration` is true, eventually pushing into `CalibrationService` workflows (`lib/fortress/calibration/`).
2. During calibration, the app prescribes progressive sets and stores progress via `CalibrationResumeStore`; completed results sync to Supabase table `calibration_resume`.
3. Warm-up guidance pulls from `assets/workout_config.json` through `ExerciseViewModel.getWarmUpFor()` and renders inside protocol prep sheets.

**Weak Spots / Risks**
- Calibration resume data relies on Supabase writes succeeding; offline sessions revert to local-only copies with no merge strategy when reconnecting.
- Warm-up templates are purely static; if config fails to load, the app silently omits guidance.
- No user feedback when calibration sync or resume retrieval throws (errors logged but not surfaced).

**Opportunities**
- Add optimistic UI banners for calibration sync status (saving, offline, error) and queue retries once connectivity returns.
- Validate the warm-up JSON at startup and expose a lightweight fallback (baseline dynamic warm-ups) when assets fail to load.
- Capture calibration attempt metrics (number of repeats, dropouts) to tune multipliers and instructions.

### Active Protocol & Rest Execution
**Flow**
1. `ProtocolScreen` orchestrates the workout loop and feeds `SessionActiveScreen`/`RepLogger` widgets.
2. Rest flow hits `RestTimer` (`lib/fortress/protocol/widgets/rest_timer.dart`) and, when required, `EnforcedRestScreen`.
3. Completed sets push back through `WorkoutViewModel.processWorkoutResults` for Supabase storage and streak updates.

**Weak Spots / Risks**
- The rest timer’s skip/extend decisions are only logged locally; we do not learn how often users deviate from the mandate.
- `WorkoutSessionManager` clears state on errors while silently swallowing them, so unexpected JSON issues nuke progress.
- Protocol heavy-lifts on the main isolate; long-running Supabase writes could stutter UI on low-end devices.

**Opportunities**
- Record rest timer outcomes and deviations to Supabase analytics or a remote log stream.
- Harden `WorkoutSessionManager.loadActiveSession()` with schema-version guards and fallbacks rather than clearing immediately.
- Move Supabase writes for completed sets onto an isolate or queue to keep the protocol loop fluid.

### Post-Workout & History
**Flow**
1. `SessionCompleteScreen` acknowledges completion and triggers cache invalidation.
2. `TrainingLogScreen` and `SessionDetailScreen` read Supabase history through `LogbookViewModel`.

**Weak Spots / Risks**
- Training log relies entirely on Supabase; offline access shows an empty log without context.
- No deduplicated sync: repeated taps on “Complete” flood Supabase with duplicate set writes.
- Log details depend on the same RPCs as the assignment screen; failure in one place cascades throughout the app.

**Opportunities**
- Cache the latest N sessions locally (e.g., via `CacheService`) for offline review.
- Tag set uploads with an idempotency token so repeated submissions do not duplicate rows.
- Surface a toast/banner when history fetch fails, offering retry and explaining offline expectations.

### Recovery & Rest Day Enforcement
**Flow**
- Rest days render through `_buildRestDay()` and `EnforcedRestScreen`, leaning on `TrainingState.getDaysSinceLastWorkout()`.
- Enforced rest blocks navigation until the timer expires.

**Weak Spots / Risks**
- Rest enforcement logic is local; clearing app data or reinstalling bypasses cooldown entirely.
- No integration with system notifications to remind users a rest block completed.

**Opportunities**
- Persist enforced rest state to Supabase so cooldowns survive reinstalls.
- Offer optional local notifications when rest is over to pull users back into the protocol.

### Subscription & Monetization
**Flow**
- `PaywallScreen` and `SubscriptionPlansScreen` wrap `RevenueCatService` for purchase/restore operations.
- Entitlement checks gate premium content via `RevenueCatService.hasActiveSubscription`.

**Weak Spots / Risks**
- Paywall UX depends on online Offerings; offline users see empty plans without fallback copy.
- Purchases that fail before `Purchases.purchaseStoreProduct` returns are only surfaced via debug logs.
- No telemetry ties conversions back to onboarding personas or training behavior.

**Opportunities**
- Cache the last known offerings/offline messaging so an offline paywall still communicates status.
- Wrap purchase calls with user-visible error states and recovery actions.
- Emit purchase funnel analytics (view → purchase → restore) to correlate monetization with training engagement.

### Settings & Data Management
**Flow**
- `SettingsMainScreen` provides data export/reset and surfaces app metadata.
- Reset uses `TrainingState.clearAll()` and clears SharedPreferences keys.

**Weak Spots / Risks**
- Reset confirmation is a single dialog; no backup/export path exists before destructive actions.
- Data export tooling is marked TODO; compliance risk if users request their data.

**Opportunities**
- Add a “Download data” CTA that packages recent sessions from Supabase before reset.
- Double-confirm destructive actions with explicit checkboxes or typed confirmation to avoid accidental wipes.

## Supporting Systems
- **Data & Sync** – `SupabaseWorkoutRepository` offers slug-based RPCs with fallbacks, while `TrainingState` mirrors assignments/streaks server-side for cross-device continuity.
- **Session persistence** – `WorkoutSessionManager` keeps transient progress in `SharedPreferences`, but retention is capped at ~4 hours and never leaves the device.
- **Caching** – `CacheService` memoizes today’s workout and performance stats with short TTLs; invalidation happens after `processWorkoutResults`.
- **Alternatives & Warm-ups** – `ExerciseViewModel` parses `assets/workout_config.json` on launch, exposing alternatives and warm-ups entirely client-side.
- **Telemetry** – `HWLog` throttles and prints JSON in debug mode only; release builds disable `_print`, so no remote analytics/crash breadcrumbs exist today.
- **Testing Surface** – Automated tests are placeholder-only (`test/integration_test.dart` simply pumps static widgets). Core flows lack coverage.

## Screen Coverage Checklist
| Domain | Screen / Entry Point | Purpose | Notes |
|--------|----------------------|---------|-------|
| Shell & Navigation | `main.dart`, `navigation_shell.dart`, `main_app_shell.dart` | App bootstrap, tab navigation, back-stack orchestration | Navigation logging exists, but no runtime guard for mismatched routes or deep-link fallbacks. |
| Onboarding | `legal_gate_screen.dart`, `manifesto_screen.dart`, `profile/*` | Capture commitment, profile data, and readiness | Each step logs minimal analytics; offline/latency handling needs attention. |
| Authentication | `onboarding/auth_screen.dart` | Supabase email/password auth | Error states shown inline; no passwordless or social fallback, no retry telemetry. |
| Assignment | `training/assignment_screen.dart` | Present daily mandate and exercise list | Alternatives + resume badge documented; relies on ExerciseViewModel load with no failure UI. |
| Daily Workout | `training/daily_workout_screen.dart` | Launch pad, handles session resume | Dialogue for resume vs new session; needs Supabase-backed resume for durability. |
| Protocol | `training/protocol_screen.dart`, `session_active_screen.dart` | Run workout loop, logging reps/sets | Rest timer, set logger, calibration hooks; Supabase writes on main thread. |
| Rest Enforcement | `training/enforced_rest_screen.dart` | Mandatory cooldown enforcement | Local-only guard; bypassable after reinstall. |
| Session Complete | `training/session_complete_screen.dart` | Confirm completion, nudge reflection | Minimal copy; could solicit feedback or capture perceived exertion. |
| Logbook | `training/training_log_screen.dart`, `session_detail_screen.dart` | Display historical sessions | Supabase-dependent; offline UX unhandled. |
| Exercise Intel | `training/exercise_intel_screen.dart` | Surface coaching cues | Pulls static intel; future dynamic tips could leverage logged mistakes. |
| Settings | `settings_main_screen.dart` | Reset, export, system info | Export TODO, destructive actions lightly guarded. |
| Profile (post-onboarding) | `profile/profile_screen.dart` | View/edit stored profile data | Edits feed back into `AppState`; Supabase sync after initial onboarding needs expansion. |
| Paywall | `paywall_screen.dart`, `subscription_plans_screen.dart` | Present offerings, manage purchases | Remote offerings only; offline fallback missing. |
| Developer Tools | `screens/dev/*` | Internal diagnostics | Useful in debug builds; ensure they stay gated in release. |

## External Integrations & Services
- **Supabase** – Primary backend for workout history, calibration resume, training state, and authentication. Relies on RPC functions for performance.
- **RevenueCat** – Subscription management with SDK v8; successes/failures logged locally only.
- **SharedPreferences** – Stores onboarding state, session snapshots, cached workouts, and training streak counts.
- **Assets / JSON Config** – `assets/workout_config.json` drives alternatives and warm-ups; `system_config.json` (loaded via `SystemConfig`) controls multipliers and debug flags.
- **Logging & Diagnostics** – `HWLog` throttled JSON logs (debug builds), `LogConfig` offers sampling/muting, dev screens provide manual inspection.

## Known Risks & Potential PRs
| Area | Symptom | Impact | Proposed Fix |
|------|---------|--------|---------------|
| Onboarding state | Profile decisions live only in `SharedPreferences` until the user authenticates | Reinstalls or device swaps before auth force users to restart onboarding | Create a Supabase `user_profile` table; sync when `AuthService` logs in, keeping preferences cached locally |
| Exercise alternatives | `ExerciseViewModel` selections reset between sessions | Users lose chosen movements and may mistrust the swap feature | Persist selections via `WorkoutSessionManager` and sync long-term to a Supabase user preference key |
| Session resilience | `WorkoutSessionManager` drops state after 4 hours or JSON mismatch | Mid-workout crashes can wipe progress with no recovery | Add schema versions, upload partial set data to Supabase, and surface a resume banner with richer context |
| Observability | `HWLog` is silent in release builds | Production issues go undetected; no analytics | Pipe `HWLog` into a remote sink (Sentry, PostHog) with sampling, keeping JSON schema intact |
| Monetization UX | Paywall requires live offerings and lacks error UI | Offline users hit empty paywalls; purchase errors lack guidance | Cache offerings, add offline messaging, and show actionable error states with retry/restore buttons |
| Test coverage | Integration tests exercise only placeholder widgets | Regressions in training flows ship undetected | Build golden tests for onboarding, assignment, protocol loops, plus Supabase repository unit tests |

## Diagnostics & Observability Gaps
- No crash reporting or release-grade analytics; every production failure currently depends on user reports.
- Rest timer, calibration, and assignment success metrics never leave the device, so balancing difficulty is guesswork.
- Supabase RPC failures fall back quietly; we lack visibility into latency, error rates, or cache hit ratios.
- RevenueCat flows do not emit telemetry correlating paywall impressions, conversions, and churn.

## Suggested Next Steps
1. Stand up remote telemetry (export `HWLog` events) and add crash/error reporting to baseline observability.
2. Persist profile and workout preferences to Supabase so onboarding and exercise swaps survive reinstalls.
3. Harden workout session persistence with idempotent set uploads and richer resume context.
4. Build end-to-end widget tests for onboarding → assignment → protocol to catch regressions before QA ever touches the build.
5. Design offline messaging for paywall, assignment config load failures, and training log fetches to set expectations when connectivity drops.
