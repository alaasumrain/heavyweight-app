# Workout UI Issues - Branch: claude/workout-ui-issues-011CUtKmr3En8ho8c7xM2iHW

## Purpose
This document identifies current UI/UX issues discovered during gym usage testing. This branch is for **issue identification only** - fixes will be implemented in a separate branch.

---

## Issue #1: Workout Exercise Screen - Layout & Styling Problems

**Location:** `lib/screens/training/protocol_screen.dart`

**Problems Identified:**
1. **Component Overlap ("Splashing into each other")**
   - Components appear to be colliding or overlapping on the workout screen
   - Layout spacing may not be adequate
   - Likely affecting readability and usability during workout

2. **Time Display Issues**
   - The timer/time display has UI problems
   - Possibly related to the rest timer widget or set timing displays
   - May be causing visual confusion during rest periods

3. **Scrollbar Issues**
   - Problems with scrolling behavior or scrollbar visibility
   - Could be interfering with the user experience
   - May be related to the SingleChildScrollView in protocol_screen.dart (line 1004)

**Current Implementation:**
- File: `lib/screens/training/protocol_screen.dart`
- Uses `HeavyweightScaffold` with `SingleChildScrollView` for layout
- Components involved:
  - `_TrainingHeader` (lines 1264-1318)
  - `_TrainingWeightCard` (lines 1320-1425)
  - `GuidanceCard` (lines 1211-1262)
  - `RepLogger` widget (lines 119-151)
  - `RestTimer` widget (displayed during rest mode, lines 951-982)

**User Impact:** Medium-High
- Affects usability during active workout
- Visual confusion can impact workout flow and timing

---

## Issue #2: Bottom Navigation Bar - Visibility During Workout

**Location:** `lib/components/ui/navigation_bar.dart`, `lib/components/layout/heavyweight_scaffold.dart`

**Problem:**
- Bottom navigation bar remains visible during workout/exercise workout screen
- Should be hidden when user enters workout mode
- Should reappear when user exits workout and returns to other screens

**Expected Behavior:**
```
- User starts workout → Bottom nav hides
- User in workout screen → Bottom nav remains hidden
- User exits workout → Bottom nav reappears
- User on Assignment/Logbook/Settings → Bottom nav visible
```

**Current Implementation:**
- Navigation bar defined in: `lib/components/ui/navigation_bar.dart`
- 3-tab system: ASSIGNMENT (tab=0), LOGBOOK (tab=1), SETTINGS (tab=2)
- Fixed height: 70 + bottom inset padding
- Always visible regardless of current screen

**Affected Screens:**
- `protocol_screen.dart` (main workout screen)
- `session_complete_screen.dart` (completion screen - nav should remain visible here)

**User Impact:** Medium
- Bottom nav takes up screen real estate during workout
- May cause accidental taps during exercise
- Reduces focus on workout content

---

## Issue #3: Exercise Completion Flow - Duplicate Confirmations & Back Button Behavior

**Location:** `lib/screens/training/protocol_screen.dart`, `lib/screens/training/session_complete_screen.dart`

**Problems Identified:**

### 3.1: Duplicate Confirmation Display
- When finishing an exercise, a confirmation dialog appears
- User reports seeing the confirmation twice OR it appears in the background when navigating back
- May be related to the SnackBar shown at line 710-719 in protocol_screen.dart
- Could also be related to navigation to session_complete_screen.dart at line 912

### 3.2: Back Button Behavior During/After Workout
**Current Behavior:**
- User completes exercise → Sees confirmation
- User presses back button → Sees confirmation again or duplicate
- User is still in workout screen instead of returning cleanly

**Expected Behavior:**
- User presses back during exercise → Show exit confirmation dialog (already implemented at lines 374-417)
- User completes exercise → Navigate to workout view automatically
- If user abandons mid-exercise → Auto-mark as incomplete
- Provide option to continue/resume workout later

**Current Implementation:**
- Exit confirmation dialog exists: `_showExitConfirmation()` (lines 374-417)
- Dialog shows: "Your progress will be saved and you can resume later."
- Session state is saved via `WorkoutSessionManager` (lines 240-252)
- PopScope configured at lines 935-947 for back button handling

### 3.3: Resume Workout UI Element Missing
- User mentions "a small image that allows us to go back to continue the workout"
- This UI element should appear when there's an incomplete workout
- Likely related to the resume workout dialog in `daily_workout_screen.dart`
- May need to be more visible or accessible

**Affected Files:**
- `lib/screens/training/protocol_screen.dart` (workout execution)
- `lib/screens/training/session_complete_screen.dart` (completion screen)
- `lib/screens/training/daily_workout_screen.dart` (resume dialog)
- `lib/core/workout_session_manager.dart` (session persistence)

**Current Resume Logic:**
- `WorkoutSessionManager.hasActiveSession()` checks for unfinished workouts
- Resume dialog shown in `daily_workout_screen.dart` on startup
- Session expires after 4 hours

**User Impact:** High
- Confusing navigation flow disrupts workout experience
- Risk of losing workout progress
- User frustration with duplicate confirmations
- Difficulty resuming workouts

---

## Summary of Issues by Priority

### High Priority:
1. **Issue #3**: Exercise completion flow - Direct impact on workout experience and data integrity

### Medium Priority:
2. **Issue #2**: Bottom navigation visibility - Impacts usability and focus
3. **Issue #1**: Workout screen styling - Affects readability during workout

---

## Next Steps

1. **Validation Phase** (Current)
   - Review this document with team/product owner
   - Prioritize issues
   - Add screenshots/recordings if available
   - Confirm expected behaviors

2. **Design Phase**
   - Create mockups for Issue #1 (layout improvements)
   - Design navigation hide/show behavior for Issue #2
   - Design improved completion flow for Issue #3

3. **Implementation Phase** (Separate Branch)
   - Create new branch: `fix/workout-ui-improvements`
   - Implement fixes in priority order
   - Test thoroughly at gym
   - Submit for review

---

## Technical Notes

### Key Components to Modify:
1. `lib/screens/training/protocol_screen.dart` - Main workout screen
2. `lib/components/ui/navigation_bar.dart` - Navigation visibility
3. `lib/components/layout/heavyweight_scaffold.dart` - May need navigation control
4. `lib/screens/training/session_complete_screen.dart` - Completion flow
5. `lib/core/workout_session_manager.dart` - Session state management

### Testing Checklist (For Implementation Phase):
- [ ] Test workout screen layout on different screen sizes
- [ ] Verify bottom nav hides during workout
- [ ] Verify bottom nav shows on other screens
- [ ] Test back button during workout (should show confirmation)
- [ ] Test back button after set completion
- [ ] Test workout completion flow (no duplicates)
- [ ] Test workout resume flow
- [ ] Test session persistence across app restarts
- [ ] Test edge cases (network loss, app backgrounded, etc.)

---

**Document Created:** 2025-11-07
**Branch:** claude/workout-ui-issues-011CUtKmr3En8ho8c7xM2iHW
**Status:** Issue Identification Phase
**Next Action:** Review and prioritize issues before implementation
