# PRD: Training Log & Historical Insight

## User Stories
- Review past sessions and track progress trends.
- Inspect detailed set data (rest, notes, alternatives).
- Understand offline limitations gracefully.

## UX States & Acceptance Criteria
| State | Description | Acceptance Criteria |
|-------|-------------|---------------------|
| Logbook | Session list | Paginated, sorted by date/day, pull-to-refresh. |
| Session Detail | Detailed timeline | Accurate set order, rest, notes, alternative indicator. |
| Empty | No sessions | Motivational copy + CTA. |
| Offline/Error | Supabase unreachable | Banner, cached snapshot if available, retry button. |

## Data Contracts
- **Remote**: `workouts`, `sets`, `exercises`; `hw_last_for_exercises_by_slug` for fetches.
- **Local**: Plan to cache recent sessions via `CacheService`.

## Telemetry & Metrics
- Events: `logbook_fetch_start/success/failure`, `session_detail_view`.
- Metrics: Fetch latency/error rate, cache hit ratio, session view frequency.
- Alerts: Failure rate >3% or latency >2s p95.

## Validation & Rollout
- **Automated**: Repository unit tests, widget tests for list/detail.
- **Manual**: Offline mode, pagination, alternative display, export interplay.
- **Rollout**: Stage caching; monitor error trends before widening TTL.

