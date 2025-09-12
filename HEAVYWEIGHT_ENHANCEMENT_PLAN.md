# HEAVYWEIGHT ENHANCEMENT PLAN
*No bloat. No overengineering. Just features that help people lift more weight.*

## ✅ COMPLETED
- [x] Updated starting weights to realistic levels (60kg bench, 80kg squat, 100kg deadlift)
- [x] Fixed navigation issues (context.go vs context.push)
- [x] Weight progression algorithm (0.7x, 0.9x, 1.0x, 1.05x)

## 📋 PHASE 1: CORE ENHANCEMENTS (This Week)
### 1. Navigation Helpers
```dart
void goProfile(BuildContext c) => c.go('/profile');
void goLog(BuildContext c) => c.go('/app?tab=1');
void goHome(BuildContext c) => c.go('/app');
```

### 2. Progression Graph (Per Exercise)
- Line chart: Last 12 sessions
- Mark PRs (●), failures (×), light days (△)
- Tap dot → open session details
- **Table:** `exercise_sessions(id, user_id, exercise_id, date, top_set_weight, top_set_reps, is_pr, is_light)`

### 3. Calendar View Above Log
- Month grid: ✅ done, ❌ missed, ◯ planned, ▪ rest
- Tap ❌ → force reason modal
- **Table:** `training_calendar(id, user_id, date, status, reason_text, reason_tag)`

## 📋 PHASE 2: ACCOUNTABILITY (Next Week)
### 1. Missed Workout Reasons
- Categories: weak/legitimate/planning/social
- AI verdict: "Hungover? Weak. -10 respect."
- Block new sessions until reason provided

### 2. Consistency Score (Not Streak!)
```dart
consistency = (days_done / days_planned) * 100 // Rolling 28 days
```

### 3. Smart Rest Day Scheduler
**Onboarding Questions:**
- "Which days can you DEFINITELY train?"
- "Earliest training time?"
- "Shift/Job type?" (desk/shift/physical)
- "Weekend nights: usually out?"
- "Sleep range?" (6-7h, 7-8h, 8-9h)

**Auto-scheduling:**
- Map 5-day split to available days
- Avoid heavy legs after party nights
- Auto-remap after 2+ consecutive misses

## 📋 PHASE 3: INTELLIGENCE (Following Week)
### 1. Light Day Auto-Insertion
```dart
bool useLightDay(int failsInWindow) => failsInWindow >= 3; // 80% weight
```

### 2. Plate Math Helper
- Show exact plates to load
- Warm-up sets calculated
- Next session preview

### 3. Pattern Recognition
- "You always fail squats on Mondays" → Move to Wednesday
- "You miss Fridays 60% of time" → 4-day program
- "Bench improves faster than squat" → Add leg volume

## 🎯 WHAT TO COPY (AND FROM WHERE)
- **StrongLifts:** Plate math, warm-up sets, next session forecast
- **BLS:** 4-6 rep mandate, 3:00 rest enforcement
- **Starting Strength:** Light day trigger logic (automatic, not user choice)
- **Alpha/Hevy:** Clean progress charts, PR detection
- **JuggernautAI:** One-tap readiness ("Sleep OK?" → ±2.5% adjustment)

## 🚫 WHAT TO IGNORE
- Social feeds, leaderboards, stories
- RPE/velocity complexity
- Form video libraries
- Any feature that breaks 4-6RM clarity

## 📊 KPIs TO TRACK
- **Consistency %** (28-day rolling)
- **Time to next PR** per lift
- **Rest adherence** (3:00 compliance)
- **Missed day patterns** (to tune scheduler)

## 💾 DATABASE ADDITIONS (MINIMAL)
```sql
-- Just 3 new tables, no bloat
CREATE TABLE exercise_sessions (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users,
  exercise_id INT,
  date DATE,
  top_set_weight DECIMAL,
  top_set_reps INT,
  is_pr BOOLEAN DEFAULT FALSE,
  is_light BOOLEAN DEFAULT FALSE
);

CREATE TABLE training_calendar (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users,
  date DATE,
  status ENUM('done','missed','rest','planned'),
  reason_text TEXT,
  reason_tag ENUM('weak','legitimate','planning','social'),
  ai_verdict TEXT
);

CREATE TABLE user_schedule (
  user_id UUID PRIMARY KEY REFERENCES users,
  weekly_days JSON, -- ['mon','wed','fri']
  last_remap_at TIMESTAMP,
  compressed_mode BOOLEAN DEFAULT FALSE
);
```

## 🔨 IMPLEMENTATION NOTES
- Use existing theme/components (no custom UI)
- Follow current logging patterns (HWLog)
- Maintain 4-6 rep mandate throughout
- Keep shame/accountability tone consistent
- No feature should take >3 taps to use

## 🚀 READY TO GYM TEST
The app is currently functional with:
- Realistic starting weights
- Smart progression algorithm
- Fixed navigation
- 5-day rotation
- Rep logging with failure tracking
- Rest timer enforcement

**GO HIT THE GYM AND TEST IT!**

---
*Last Updated: 2025-09-12*
*Status: App ready for gym testing. Enhancement phases planned but not blocking.*