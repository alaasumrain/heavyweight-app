# HEAVYWEIGHT Supabase Database Schema (2025-02)

This document captures the current Supabase schema as deployed in production. It reflects the output of

```sql
SELECT
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage ccu
  ON tc.constraint_name = ccu.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.constraint_type IN ('PRIMARY KEY','FOREIGN KEY','UNIQUE')
ORDER BY tc.table_name, tc.constraint_type;
```

> Supabase also ships the standard `auth`, `storage`, and `realtime` schemas; only the `public` schema is outlined below.

---

## Table Inventory

| Table | Primary Key | Row-Level Security |
|-------|-------------|--------------------|
| `profiles` | `id` (`uuid`, FK → `auth.users.id`) | Enabled |
| `exercises` | `id` (`bigint`, identity) | Enabled |
| `workout_days` | `id` (`integer`, identity) | Enabled |
| `day_exercises` | `id` (`integer`, identity) | Enabled |
| `workouts` | `id` (`bigint`, identity) | Enabled |
| `sets` | `id` (`bigint`, identity) | Enabled |
| `user_training_state` | `user_id` (`uuid`, FK → `profiles.id`) | Enabled |
| `calibration_resume` | Composite (`user_id`, `exercise_id`) | Enabled |

All tables enforce row-level security. Policies typically follow “user can read/write rows where `user_id = auth.uid()`”.

---

## Table Definitions

### `profiles`
Extended user profile linked 1:1 with `auth.users`.

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `uuid` | PRIMARY KEY, FK → `auth.users.id` |
| `username` | `text` | NOT NULL, UNIQUE |
| `exercise_weights` | `jsonb` | DEFAULT `'{}'::jsonb` |
| `created_at` | `timestamptz` | DEFAULT `now()` |

### `exercises`
Master catalog of exercises with optional starting load.

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `bigint` | PRIMARY KEY (identity) |
| `name` | `text` | NOT NULL |
| `description` | `text` | NULL |
| `starting_weight_kg` | `numeric` | NULL |
| `created_at` | `timestamptz` | DEFAULT `now()` |

### `workout_days`
Defines the fixed five-day rotation (CHEST, BACK, ARMS, SHOULDERS, LEGS).

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `integer` | PRIMARY KEY (identity) |
| `name` | `text` | NOT NULL, UNIQUE |
| `day_order` | `integer` | NOT NULL, UNIQUE (1–5) |
| `created_at` | `timestamptz` | DEFAULT `now()` |

### `day_exercises`
Maps exercises to rotation days.

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `integer` | PRIMARY KEY (identity) |
| `workout_day_id` | `integer` | FK → `workout_days.id` |
| `exercise_id` | `bigint` | FK → `exercises.id` |
| `order_in_day` | `integer` | NOT NULL |
| `sets_target` | `integer` | DEFAULT `3` |
| `created_at` | `timestamptz` | DEFAULT `now()` |
| Unique Constraints | `UNIQUE(workout_day_id, exercise_id)` |

### `workouts`
Workout session header table.

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `bigint` | PRIMARY KEY (identity) |
| `user_id` | `uuid` | NOT NULL, FK → `profiles.id` |
| `created_at` | `timestamptz` | DEFAULT `now()` |
| `ended_at` | `timestamptz` | NULL |

### `sets`
Individual set records captured during a workout.

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `bigint` | PRIMARY KEY (identity) |
| `workout_id` | `bigint` | NOT NULL, FK → `workouts.id` |
| `exercise_id` | `bigint` | NOT NULL, FK → `exercises.id` |
| `set_number` | `integer` | NULL |
| `target_reps` | `smallint` | NOT NULL |
| `actual_reps` | `smallint` | NOT NULL |
| `weight` | `numeric` | NOT NULL |
| `rest_taken` | `integer` | NULL (seconds) |
| `notes` | `text` | NULL |
| `created_at` | `timestamptz` | DEFAULT `now()` |

### `user_training_state`
Stores sticky day assignment and streak metadata per user.

| Column | Type | Constraints |
|--------|------|-------------|
| `user_id` | `uuid` | PRIMARY KEY, FK → `profiles.id` |
| `last_assigned_day` | `text` | NULL |
| `last_assigned_at` | `timestamptz` | NULL |
| `last_completed_at` | `timestamptz` | NULL |
| `current_streak` | `integer` | DEFAULT `0` |
| `updated_at` | `timestamptz` | DEFAULT `now()` |

### `calibration_resume`
Cross-device calibration resume data; composite key ensures one record per exercise per user.

| Column | Type | Constraints |
|--------|------|-------------|
| `user_id` | `uuid` | PRIMARY KEY, FK → `profiles.id` |
| `exercise_id` | `bigint` | PRIMARY KEY, FK → `exercises.id` |
| `attempt_idx` | `integer` | NOT NULL |
| `signed_load_kg` | `numeric` | NOT NULL |
| `effective_load_kg` | `numeric` | NOT NULL |
| `reps` | `integer` | NOT NULL |
| `est1rm_kg` | `numeric` | NOT NULL |
| `next_signed_kg` | `numeric` | NOT NULL |
| `updated_at` | `timestamptz` | DEFAULT `now()` |

---

## Relationships Summary

```
auth.users (uuid)
   │
   └─1:1─ profiles.id
            │
            ├─1:1─ user_training_state.user_id
            │
            └─1:many─ workouts.user_id
                         │
                         └─1:many─ sets.workout_id
                                       │
                                       └─many:1─ exercises.id

workout_days.id
   │
   └─1:many─ day_exercises.workout_day_id
                │
                └─many:1─ exercises.id

profiles.id × exercises.id
   │
   └─many:many─ calibration_resume (composite key)
```

---

## Operational Notes

- **Row Level Security**: Enabled everywhere. Ensure new functions either use `SECURITY DEFINER` with care or call Supabase via RPC adhering to RLS policies.
- **Starting Weights**: `exercises.starting_weight_kg` powers the initial assignments seeded into `assets/workout_config.json`.
- **History Volume**: `sets` and `workouts` are the primary growth tables; plan retention/archival strategies accordingly.
- **RPC Helpers**: Production relies on `hw_last_for_exercises_by_slug` and `hw_last_for_exercises` to batch fetch recent set data. Refer to `lib/backend/supabase/supabase_workout_repository.dart` for usage patterns.

Keep this document in sync with migrations to maintain a trustworthy reference for PRDs and architecture reviews.
