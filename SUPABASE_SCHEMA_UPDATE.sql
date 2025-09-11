-- HEAVYWEIGHT APP - SUPABASE SCHEMA UPDATE
-- Run this SQL in your Supabase dashboard to make the database compatible with the app

-- ============================================================================
-- 1. ADD MISSING COLUMNS TO EXISTING TABLES
-- ============================================================================

-- Update workouts table
ALTER TABLE workouts ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
ALTER TABLE workouts ADD COLUMN IF NOT EXISTS ended_at TIMESTAMPTZ;

-- Update sets table  
ALTER TABLE sets ADD COLUMN IF NOT EXISTS set_number INT4 DEFAULT 1;
ALTER TABLE sets ADD COLUMN IF NOT EXISTS rest_taken INT4 DEFAULT 180;

-- Update profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS exercise_weights JSONB DEFAULT '{}';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS age INT4;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS weight NUMERIC;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS height NUMERIC;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS experience TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS frequency TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS objective TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS units TEXT DEFAULT 'kg';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ============================================================================
-- 2. ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE day_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_days ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 3. CREATE SECURITY POLICIES
-- ============================================================================

-- Exercises policies (public read)
DROP POLICY IF EXISTS "Anyone can view exercises" ON exercises;
CREATE POLICY "Anyone can view exercises" ON exercises FOR SELECT USING (true);

-- Sets policies
DROP POLICY IF EXISTS "Users can view own sets" ON sets;
CREATE POLICY "Users can view own sets" ON sets
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM workouts 
      WHERE workouts.id = sets.workout_id 
      AND workouts.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can insert own sets" ON sets;
CREATE POLICY "Users can insert own sets" ON sets
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM workouts 
      WHERE workouts.id = sets.workout_id 
      AND workouts.user_id = auth.uid()
    )
  );

-- Workouts policies
DROP POLICY IF EXISTS "Users can view own workouts" ON workouts;
CREATE POLICY "Users can view own workouts" ON workouts
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own workouts" ON workouts;
CREATE POLICY "Users can insert own workouts" ON workouts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own workouts" ON workouts;
CREATE POLICY "Users can update own workouts" ON workouts
  FOR UPDATE USING (auth.uid() = user_id);

-- Profiles policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Workout days policies (public read)
DROP POLICY IF EXISTS "Anyone can view workout days" ON workout_days;
CREATE POLICY "Anyone can view workout days" ON workout_days FOR SELECT USING (true);

-- Day exercises policies (public read)
DROP POLICY IF EXISTS "Anyone can view day exercises" ON day_exercises;
CREATE POLICY "Anyone can view day exercises" ON day_exercises FOR SELECT USING (true);

-- ============================================================================
-- 4. POPULATE REQUIRED DATA
-- ============================================================================

-- Insert the Big Six exercises that the app expects
INSERT INTO exercises (name, description) VALUES
('Squat', 'Barbell back squat - the king of all exercises'),
('Bench Press', 'Barbell bench press - upper body power'),
('Deadlift', 'Conventional deadlift - full body strength'),
('Overhead Press', 'Standing military press - shoulder stability'),
('Barbell Row', 'Bent-over barbell row - back development'),
('Pull-up', 'Bodyweight pull-up - vertical pulling strength')
ON CONFLICT (name) DO NOTHING;

-- Insert workout days
INSERT INTO workout_days (name, day_order) VALUES
('CHEST', 1),
('BACK', 2),
('LEGS', 3),
('SHOULDERS', 4),
('ARMS', 5)
ON CONFLICT (name) DO NOTHING;

-- Link exercises to workout days (example setup)
-- You can customize this based on your workout program
DO $$
DECLARE
    chest_day_id INT;
    back_day_id INT;
    legs_day_id INT;
    shoulders_day_id INT;
    arms_day_id INT;
    
    squat_id INT;
    bench_id INT;
    deadlift_id INT;
    press_id INT;
    row_id INT;
    pullup_id INT;
BEGIN
    -- Get workout day IDs
    SELECT id INTO chest_day_id FROM workout_days WHERE name = 'CHEST';
    SELECT id INTO back_day_id FROM workout_days WHERE name = 'BACK';
    SELECT id INTO legs_day_id FROM workout_days WHERE name = 'LEGS';
    SELECT id INTO shoulders_day_id FROM workout_days WHERE name = 'SHOULDERS';
    SELECT id INTO arms_day_id FROM workout_days WHERE name = 'ARMS';
    
    -- Get exercise IDs
    SELECT id INTO squat_id FROM exercises WHERE name = 'Squat';
    SELECT id INTO bench_id FROM exercises WHERE name = 'Bench Press';
    SELECT id INTO deadlift_id FROM exercises WHERE name = 'Deadlift';
    SELECT id INTO press_id FROM exercises WHERE name = 'Overhead Press';
    SELECT id INTO row_id FROM exercises WHERE name = 'Barbell Row';
    SELECT id INTO pullup_id FROM exercises WHERE name = 'Pull-up';
    
    -- Insert day exercises (customize as needed)
    INSERT INTO day_exercises (workout_day_id, exercise_id, order_in_day, sets_target) VALUES
    -- Chest Day
    (chest_day_id, bench_id, 1, 5),
    (chest_day_id, press_id, 2, 3),
    
    -- Back Day  
    (back_day_id, deadlift_id, 1, 5),
    (back_day_id, row_id, 2, 5),
    (back_day_id, pullup_id, 3, 3),
    
    -- Legs Day
    (legs_day_id, squat_id, 1, 5),
    (legs_day_id, deadlift_id, 2, 3),
    
    -- Shoulders Day
    (shoulders_day_id, press_id, 1, 5),
    (shoulders_day_id, row_id, 2, 3),
    
    -- Arms Day
    (arms_day_id, bench_id, 1, 3),
    (arms_day_id, pullup_id, 2, 5)
    
    ON CONFLICT (workout_day_id, exercise_id) DO NOTHING;
END $$;

-- ============================================================================
-- 5. CREATE HELPFUL INDEXES
-- ============================================================================

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_sets_workout_id ON sets(workout_id);
CREATE INDEX IF NOT EXISTS idx_sets_exercise_id ON sets(exercise_id);
CREATE INDEX IF NOT EXISTS idx_workouts_user_id ON workouts(user_id);
CREATE INDEX IF NOT EXISTS idx_workouts_created_at ON workouts(created_at);

-- ============================================================================
-- SETUP COMPLETE! 
-- ============================================================================

-- Your HEAVYWEIGHT app should now work with this database schema.
-- Test by:
-- 1. Creating a user account in the app
-- 2. Completing the onboarding flow  
-- 3. Starting a workout and logging some sets
-- 4. Checking this database to see if data appears

SELECT 'HEAVYWEIGHT database schema update completed successfully!' as status;
