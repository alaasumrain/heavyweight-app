# HEAVYWEIGHT - SUPABASE SETUP GUIDE
*Complete guide to set up Supabase backend for HEAVYWEIGHT app*

---

## 🎯 **CURRENT STATUS**

### **✅ ALREADY CONFIGURED:**
- **Supabase Project**: `oqsmbngbgvlnehcxvcto.supabase.co`
- **Authentication**: Email/password auth enabled
- **API Keys**: Configured in `lib/backend/supabase/supabase.dart`
- **Flutter Integration**: Supabase Flutter SDK integrated

### **📋 WHAT'S NEEDED:**
- **Database Tables**: Create required tables for workout data
- **Row Level Security**: Set up data access policies
- **Storage Buckets**: For user avatars (optional)

---

## 🗄️ **REQUIRED DATABASE SCHEMA**

Based on the app code analysis, here are the tables needed:

### **1. Profiles Table**
```sql
-- User profile information
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT,
  email TEXT,
  age INTEGER,
  weight DECIMAL,
  height DECIMAL,
  experience TEXT, -- 'beginner', 'intermediate', 'advanced'
  frequency TEXT,  -- '2-3', '3-4', '4-5', '5+'
  objective TEXT,  -- 'strength', 'muscle', 'athletic', 'general'
  units TEXT DEFAULT 'kg', -- 'kg' or 'lb'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **2. Sets Table**
```sql
-- Individual set data
CREATE TABLE sets (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  workout_id INTEGER,
  exercise_id TEXT NOT NULL,
  weight DECIMAL NOT NULL,
  actual_reps INTEGER NOT NULL,
  target_reps INTEGER DEFAULT 5,
  set_number INTEGER NOT NULL,
  rest_taken INTEGER, -- seconds
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **3. Workouts Table**
```sql
-- Workout sessions
CREATE TABLE workouts (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  workout_date DATE NOT NULL,
  day_name TEXT NOT NULL, -- 'CHEST', 'BACK', etc.
  total_sets INTEGER DEFAULT 0,
  total_volume DECIMAL DEFAULT 0,
  duration_minutes INTEGER,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **4. Exercise Calibrations Table**
```sql
-- User-specific exercise calibrations
CREATE TABLE exercise_calibrations (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  exercise_id TEXT NOT NULL,
  calibrated_weight DECIMAL NOT NULL,
  five_rm DECIMAL, -- 5-rep max
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, exercise_id)
);
```

---

## 🔐 **ROW LEVEL SECURITY POLICIES**

### **Enable RLS on all tables:**
```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_calibrations ENABLE ROW LEVEL SECURITY;
```

### **Create Security Policies:**
```sql
-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Sets policies
CREATE POLICY "Users can view own sets" ON sets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sets" ON sets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Workouts policies
CREATE POLICY "Users can view own workouts" ON workouts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own workouts" ON workouts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own workouts" ON workouts
  FOR UPDATE USING (auth.uid() = user_id);

-- Exercise calibrations policies
CREATE POLICY "Users can view own calibrations" ON exercise_calibrations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own calibrations" ON exercise_calibrations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own calibrations" ON exercise_calibrations
  FOR UPDATE USING (auth.uid() = user_id);
```

---

## 🚀 **SETUP INSTRUCTIONS**

### **Option 1: Supabase Dashboard (Recommended)**

#### **Step 1: Access Your Project**
1. Go to https://supabase.com/dashboard
2. Select project: `oqsmbngbgvlnehcxvcto`
3. Navigate to **SQL Editor**

#### **Step 2: Create Tables**
1. Copy the SQL schema above
2. Paste into SQL Editor
3. Click **Run** to execute

#### **Step 3: Set Up Authentication**
1. Go to **Authentication** → **Settings**
2. Ensure **Email** provider is enabled
3. Configure email templates (optional)

#### **Step 4: Verify Setup**
1. Go to **Table Editor**
2. Confirm all 4 tables exist
3. Check **Authentication** → **Policies** for RLS rules

### **Option 2: Supabase CLI (Advanced)**

#### **Install Supabase CLI:**
```bash
npm install -g supabase
```

#### **Initialize Project:**
```bash
# In your project root
supabase init
supabase link --project-ref oqsmbngbgvlnehcxvcto
```

#### **Create Migration:**
```bash
supabase migration new create_heavyweight_schema
```

#### **Add Schema to Migration:**
```sql
-- Add the complete schema to the migration file
-- Then run:
supabase db push
```

---

## 🧪 **TESTING THE SETUP**

### **1. Test Authentication**
```sql
-- Check if auth is working
SELECT * FROM auth.users LIMIT 5;
```

### **2. Test Tables**
```sql
-- Verify tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';
```

### **3. Test RLS**
```sql
-- Check policies
SELECT * FROM pg_policies WHERE schemaname = 'public';
```

### **4. Test App Connection**
1. Run the HEAVYWEIGHT app
2. Create a new account
3. Complete a workout
4. Check if data appears in Supabase tables

---

## 📊 **CURRENT SUPABASE CONFIGURATION**

### **✅ Already Set Up:**
```
Project URL: https://oqsmbngbgvlnehcxvcto.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Service Role: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### **🔧 App Integration:**
- **File**: `lib/backend/supabase/supabase.dart`
- **Status**: ✅ Configured with fallback to hardcoded values
- **Environment**: Supports `.env` file for credentials

### **📱 App Features Using Supabase:**
- **Authentication**: Email/password signup and login
- **Workout Data**: Sets, reps, weights storage
- **User Profiles**: Personal information and preferences
- **Exercise Calibration**: 5RM calculations and progression
- **Statistics**: Workout history and performance tracking

---

## 🚨 **TROUBLESHOOTING**

### **Common Issues:**

#### **1. "Failed to initialize Supabase"**
- **Check**: Internet connection
- **Verify**: Project URL and API keys are correct
- **Solution**: Ensure Supabase project is active

#### **2. "Authentication failed"**
- **Check**: Email provider is enabled in Supabase
- **Verify**: User registration is allowed
- **Solution**: Check Authentication settings in dashboard

#### **3. "Permission denied for table"**
- **Check**: RLS policies are set up correctly
- **Verify**: User is authenticated
- **Solution**: Review and fix RLS policies

#### **4. "Table doesn't exist"**
- **Check**: All tables were created successfully
- **Verify**: Table names match the code
- **Solution**: Re-run the schema creation SQL

---

## 🎯 **NEXT STEPS**

### **Immediate Actions:**
1. **Create the database schema** using the SQL above
2. **Test authentication** by creating a user account
3. **Verify data flow** by completing a workout
4. **Check Supabase dashboard** for stored data

### **Optional Enhancements:**
1. **Storage bucket** for user avatars
2. **Real-time subscriptions** for live data updates
3. **Edge functions** for complex calculations
4. **Database backups** and monitoring

---

## 📋 **COMPLETE SETUP CHECKLIST**

- [ ] **Access Supabase dashboard** for project `oqsmbngbgvlnehcxvcto`
- [ ] **Create profiles table** with RLS policies
- [ ] **Create sets table** with RLS policies
- [ ] **Create workouts table** with RLS policies
- [ ] **Create exercise_calibrations table** with RLS policies
- [ ] **Enable email authentication** provider
- [ ] **Test user registration** in the app
- [ ] **Test workout data saving** in the app
- [ ] **Verify data appears** in Supabase tables
- [ ] **Test data retrieval** (training log screen)

---

**Once you complete the database schema setup, the HEAVYWEIGHT app will have full backend functionality with user authentication, workout tracking, and data persistence!** 💪

*The app is designed to work with or without Supabase (falls back to local storage), but Supabase provides the full experience with cloud sync and multi-device access.*
