# PRD: Observability, Operations & Maintenance

## Telemetry Plan
- Route `HWLog` events to remote sink (PostHog/Sentry) with sampling and PII scrubbing.
- Define dashboards: onboarding completion, assignment latency, rest adherence, calibration retries, paywall conversion, export/reset usage.
- Set alert thresholds and document runbooks for common failures.

## Testing & Release Management
- Maintain automated test suites in CI (unit/widget/integration); block merges on failures.
- Use feature flags for major UX/logic changes; keep rollback procedures documented.
- Stage releases with smoke-test checklist and seeded Supabase data.

## Compliance & Data Governance
- Document retention/archival for `workouts`/`sets`; ensure export/reset meet legal obligations.
- Assign ownership for Supabase migrations, exercise config maintenance, monetization experiments.
- Schedule quarterly documentation reviews (audit, schema, PRD) and incident postmortems.

