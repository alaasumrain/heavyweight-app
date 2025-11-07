# PRD: Monetization & Paywall

## User Stories
- Understand premium benefits and pricing clearly.
- Complete purchase/restore flows reliably.
- Get informative messaging when offline or offerings missing.

## UX States & Acceptance Criteria
| State | Description | Acceptance Criteria |
|-------|-------------|---------------------|
| Paywall Loaded | Offerings displayed | Plans sorted by value; copy localized; CTA active. |
| Offline/No Offerings | RevenueCat unavailable | Cached plans or placeholder; purchase disabled; status message shown. |
| Purchase Flow | Buying subscription | Progress status; success updates entitlement; fallback messaging on error. |
| Restore Flow | Restoring purchases | Success banner; entitlement refreshed. |
| Failure | Error state | Inline error, retry option, telemetry with error code. |

## Data Contracts
- **RevenueCat**: `Offerings`, `CustomerInfo`; maintain cached copy for offline display.
- **Supabase**: Optional future fields in `profiles` for entitlement snapshots; primary authority remains RevenueCat.

## Telemetry & Metrics
- Events: `paywall_view`, `revenuecat_*`, purchase funnel events.
- Metrics: Conversion per plan, restore success rate, offering load latency.
- Alerts: Purchase failure spikes, offering load failure >5%.

## Validation & Rollout
- **Automated**: Unit tests mocking RevenueCat; widget tests for offline fallback.
- **Manual**: Sandbox purchase/restore, offline scenarios, locale variations.
- **Rollout**: Stage copy/plan changes; monitor conversion; backout via paywall configuration.

