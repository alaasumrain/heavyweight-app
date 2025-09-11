# Heavyweight UX Rework Plan (v1)

Purpose: capture immediate fixes and near-term UX decisions for onboarding, navigation, and training flows.

## Global
- Header: Title row should support an optional back control aligned on the left. For onboarding steps, hide back unless in explicit edit mode.
- Spacing: Reduce tall fixed gaps; prefer 16–24px steps. Enable scrolling for long content to avoid overflow.
- Loading: Use inline loading on primary CTAs via `CommandButton(isLoading: true)`. Disable form inputs while loading where appropriate.

## Onboarding
- LegalGate + Manifesto: Back control aligned with title when present; center titles remain. Keep copy minimal, high-contrast. Avoid deep vertical paddings.
- Experience (System Calibration):
  - Remove back (unless editing). CTA: “CONTINUE” (not “CALIBRATE”).
  - Keep options visible without needing to scroll on common phones.
- Frequency:
  - Remove back (unless editing). CTA: “CONTINUE”.
  - Selector + explanation fit above the fold where possible.
- Units, Physical Stats, Objective:
  - Same patterns: remove back (unless editing), clear CTA (“CONTINUE”).

## Auth
- Single action button shows spinner and disables on submit.
- Error feedback via toast and field validation before firing network.
- After success, route to `/app?tab=0`. AppState listener updates `isAuthenticated` for redirect safety.

## Navigation / Router
- Prevent `setState during build` by deferring `notifyListeners` in `AppStateNotifier.updateRoute`.
- Avoid triggering router refreshes from within GoRoute builders.
- For web, avoid relying on complex `extra` objects; prefer IDs, or add a codec strategy later.

## Training Flow
- Protocol Screen: ensure workout context is always present; if null on entry, fall back to ViewModel or show a clear initializing state.
- Session Complete:
  - Content is scrollable; no vertical overflow.
  - Clear mandate verdict, session summary, next-session hint, and navigation CTAs.

## Open Decisions (need confirmation)
- Header layout update: add a first-class back slot to `HeavyweightScaffold` header? If yes, we’ll migrate screens and remove inline back widgets.
- Calibration swipe/gesture: define expected interactions (e.g., swipe between exercises vs. explicit next).
- Manifesto copy tone: propose alternatives keeping terminology consistent.

## Next Steps
1) Implement header back-slot in `HeavyweightScaffold` and migrate screens.
2) Replace remaining onboarding CTAs with “CONTINUE”; normalize spacing.
3) Ensure Protocol Screen fallback when `extra` is missing on web.
4) Add consistent loading/disabled state to all network CTAs.

