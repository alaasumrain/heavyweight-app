# HEAVYWEIGHT Troubleshooting Guide

## Quick Diagnostics

### 🔧 Health Check Commands
```bash
# 1. Flutter environment
flutter doctor -v

# 2. Build verification
flutter build ios --no-codesign

# 3. Test suite
flutter test

# 4. Dependencies
flutter pub deps
```

### 🏥 Debug Screen Access
Navigate to `/dev/status` in the app to see:
- Database connection status
- Current training state
- Cache performance
- Onboarding completion

---

## Common Issues

### 🚫 Build Failures

#### Symptom: "Type 'NextRouteDebug' not found"
```dart
// lib/core/app_state.dart:127:3: Error: Type 'NextRouteDebug' not found.
```

**Solution:**
```dart
// Add class definition to app_state.dart
class NextRouteDebug {
  final List<String> unmetRequirements;
  final String? nextRoute;
  
  const NextRouteDebug({
    required this.unmetRequirements, 
    required this.nextRoute,
  });
}
```

#### Symptom: "Type 'SetData' not found in assignment_screen.dart"
```dart
// lib/screens/training/assignment_screen.dart:38:15: Error: Type 'SetData' not found.
```

**Solution:**
```dart
// Add import to assignment_screen.dart
import '../../fortress/engine/models/set_data.dart';
```

#### Symptom: "String? can't be assigned to Object"
```dart
// The argument type 'String?' can't be assigned to the parameter type 'Object'.
```

**Solution:**
```dart
// Use null-aware operator for safety
.eq('workouts.user_id', _supabase.auth.currentUser?.id ?? '')
```

#### Symptom: iOS Build Fails with Pod Issues
```bash
[ios] could not find included file 'Generated.xcconfig'
```

**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios --no-codesign
```

---

### 🐌 Performance Issues

#### Symptom: Assignment Screen Takes 3-5 Seconds to Load
**Root Cause:** Individual database queries instead of batch RPC

**Diagnosis:**
1. Check Supabase dashboard for query frequency
2. Look for multiple `SELECT * FROM exercises WHERE name = ?` queries
3. Monitor network tab for excessive requests

**Solution:**
```dart
// Verify slug-based RPC is being used
final response = await _supabase.rpc('hw_last_for_exercises_by_slug', {
  'slugs': exerciseIds.toList()
});

// Check for fallback message in logs
HWLog.event('slug_rpc_fallback', data: {'reason': 'RPC not available'});
```

**Verification:**
- Assignment screen should load in <1 second
- Single RPC call in Supabase dashboard
- Cache hit logs in console

#### Symptom: Frequent Database Timeouts
**Root Cause:** Network connectivity or Supabase load

**Solution:**
```dart
// Increase timeout and add retries
final client = SupabaseClient(
  supabaseUrl,
  supabaseAnonKey,
  httpClient: HttpClient()..connectionTimeout = Duration(seconds: 30),
);

// Implement exponential backoff
Future<T> withRetry<T>(Future<T> Function() operation) async {
  for (int attempt = 1; attempt <= 3; attempt++) {
    try {
      return await operation();
    } catch (e) {
      if (attempt == 3) rethrow;
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
  throw Exception('Max retries exceeded');
}
```

---

### 🔐 Authentication Issues

#### Symptom: "User not authenticated" errors
**Root Cause:** Expired or missing auth token

**Diagnosis:**
```dart
// Check auth status
final user = supabase.auth.currentUser;
if (user == null) {
  print('No authenticated user');
} else {
  print('User: ${user.email}, Expires: ${user.userMetadata}');
}
```

**Solution:**
```dart
// Implement token refresh
supabase.auth.onAuthStateChange.listen((data) {
  final AuthChangeEvent event = data.event;
  final Session? session = data.session;
  
  if (event == AuthChangeEvent.tokenRefreshed) {
    HWLog.event('auth_token_refreshed');
  } else if (event == AuthChangeEvent.signedOut) {
    // Redirect to login
    context.go('/auth/login');
  }
});
```

#### Symptom: RLS Policy Blocking Queries
```sql
-- Error: new row violates row-level security policy
```

**Diagnosis:**
```sql
-- Check RLS policies
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('sets', 'workouts', 'calibration_resume');
```

**Solution:**
```sql
-- Ensure policies filter by auth.uid()
CREATE POLICY "Users can access own data" ON sets
  FOR ALL USING (
    workout_id IN (
      SELECT id FROM workouts WHERE user_id = auth.uid()
    )
  );
```

---

### 📊 Data Synchronization Issues

#### Symptom: Training State Not Persisting Across Devices
**Root Cause:** Supabase sync failing silently

**Diagnosis:**
```dart
// Check sync status in logs
HWLog.event('training_state_sync_start', data: {'day': dayName});

try {
  await _syncToServer();
  HWLog.event('training_state_sync_success');
} catch (e) {
  HWLog.event('training_state_sync_failed', data: {'error': e.toString()});
}
```

**Solution:**
```dart
// Add retry mechanism for sync
static Future<void> _syncToServer({int retries = 3}) async {
  for (int attempt = 1; attempt <= retries; attempt++) {
    try {
      await supabase.from('user_training_state').upsert({
        'user_id': userId,
        'last_assigned_day': dayName,
        'current_streak': streak,
      });
      return; // Success
    } catch (e) {
      if (attempt == retries) {
        HWLog.event('training_state_sync_final_failure', data: {
          'attempts': attempt,
          'error': e.toString(),
        });
      } else {
        await Future.delayed(Duration(seconds: attempt));
      }
    }
  }
}
```

#### Symptom: Calibration Resume Data Lost
**Root Cause:** Local storage cleared or server sync failed

**Diagnosis:**
```dart
// Check both local and server data
final localData = await SharedPreferences.getInstance();
final localCalib = localData.getString('hw_calibration_resume_state');

final serverData = await supabase
  .from('calibration_resume')
  .select()
  .eq('user_id', userId)
  .maybeSingle();

print('Local: ${localCalib != null}');
print('Server: ${serverData != null}');
```

**Solution:**
```dart
// Implement robust conflict resolution
static Future<CalibrationAttemptRecord?> loadPending() async {
  try {
    final local = await _loadFromLocal();
    final server = await _loadFromServer();
    
    // Use newest-wins strategy
    if (local == null) return server;
    if (server == null) return local;
    
    final localTime = DateTime.parse(local.tsIso);
    final serverTime = DateTime.parse(server.tsIso);
    
    final newest = serverTime.isAfter(localTime) ? server : local;
    
    // Sync the newest to both locations
    await _saveToLocal(newest);
    await _saveToServer(newest);
    
    return newest;
  } catch (e) {
    HWLog.event('calibration_load_failed', data: {'error': e.toString()});
    return null;
  }
}
```

---

### 🎛️ Configuration Issues

#### Symptom: App Using Wrong Multipliers/Settings
**Root Cause:** Configuration not loading or using defaults

**Diagnosis:**
```dart
// Check config loading status
if (!SystemConfig.instance.isLoaded) {
  print('Config not loaded - using defaults');
  await SystemConfig.instance.load();
}

print('Multipliers: ${SystemConfig.instance.multiplierFailure}');
print('Rotation: ${SystemConfig.instance.rotationOrder}');
```

**Solution:**
```dart
// Add config validation
class SystemConfig {
  Future<void> load() async {
    try {
      final configString = await rootBundle.loadString('assets/system_config.json');
      _data = json.decode(configString);
      _isLoaded = true;
      
      // Validate required fields
      _validateConfig();
      
      HWLog.event('config_loaded_successfully');
    } catch (e) {
      HWLog.event('config_load_failed', data: {'error': e.toString()});
      _loadDefaults();
    }
  }
  
  void _validateConfig() {
    final required = ['multipliers', 'rotation_order', 'exercise_defaults'];
    for (final field in required) {
      if (!_data.containsKey(field)) {
        throw Exception('Missing required config field: $field');
      }
    }
  }
}
```

---

### 🧪 Testing Issues

#### Symptom: Tests Failing Due to Missing Mocks
```dart
// NoSuchMethodError: The method 'foo' was called on null.
```

**Solution:**
```dart
// Proper mock setup
class MockWorkoutRepository extends Mock implements WorkoutRepositoryInterface {}

void main() {
  late MockWorkoutRepository mockRepo;
  
  setUp(() {
    mockRepo = MockWorkoutRepository();
    
    // Setup default responses
    when(() => mockRepo.getHistory()).thenAnswer((_) async => []);
    when(() => mockRepo.getLastForExercises(any()))
        .thenAnswer((_) async => <String, SetData>{});
  });
}
```

#### Symptom: Widget Tests Failing Due to Provider Not Found
```dart
// Error: Could not find the correct Provider<WorkoutViewModel>
```

**Solution:**
```dart
testWidgets('widget should display correctly', (tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkoutViewModel>(
          create: (_) => WorkoutViewModel(
            repository: MockWorkoutRepository(),
            engine: WorkoutEngine(),
          ),
        ),
      ],
      child: MaterialApp(
        home: WidgetUnderTest(),
      ),
    ),
  );
  
  // Test assertions...
});
```

---

## Database Issues

### 🔍 RPC Function Missing
```sql
-- Check if RPC exists
SELECT routine_name, routine_definition 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name = 'hw_last_for_exercises_by_slug';
```

**If missing, apply migration:**
```sql
-- Run migration from file
-- supabase/migrations/2025-09-15_hw_last_for_exercises_by_slug.sql
```

### 📋 Table Schema Issues
```sql
-- Verify table structure
\d+ calibration_resume
\d+ user_training_state
\d+ sets

-- Check for missing columns
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'sets' 
AND column_name IN ('set_number', 'rest_taken');
```

### 🔐 Permission Issues
```sql
-- Check RPC permissions
SELECT p.proname, p.proacl 
FROM pg_proc p 
WHERE p.proname LIKE 'hw_%';

-- Grant if missing
GRANT EXECUTE ON FUNCTION hw_last_for_exercises_by_slug(text[]) TO authenticated;
```

---

## Performance Debugging

### 📊 Profiling Assignment Screen Load
```dart
// Add timing measurements
class AssignmentScreenState extends State<AssignmentScreen> {
  @override
  void initState() {
    super.initState();
    _measureLoadTime();
  }
  
  Future<void> _measureLoadTime() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      await _loadWorkoutData();
      stopwatch.stop();
      
      HWLog.event('assignment_screen_load_time', data: {
        'duration_ms': stopwatch.elapsedMilliseconds,
        'target_ms': 1000,
        'performance_met': stopwatch.elapsedMilliseconds < 1000,
      });
    } catch (e) {
      stopwatch.stop();
      HWLog.event('assignment_screen_load_failed', data: {
        'duration_ms': stopwatch.elapsedMilliseconds,
        'error': e.toString(),
      });
    }
  }
}
```

### 🔍 Query Performance Analysis
```sql
-- Enable query logging in Supabase
-- Check slow query log for patterns

-- Analyze query performance
EXPLAIN ANALYZE 
SELECT DISTINCT ON (s.exercise_id)
  s.exercise_id, s.weight, s.actual_reps
FROM sets s
JOIN workouts w ON w.id = s.workout_id
WHERE w.user_id = 'user-id'
ORDER BY s.exercise_id, s.created_at DESC;
```

---

## Recovery Procedures

### 🔄 Data Recovery

#### Lost Calibration Data
```dart
// Attempt recovery from multiple sources
static Future<void> recoverCalibrationData() async {
  // 1. Check local backup
  final prefs = await SharedPreferences.getInstance();
  final backup = prefs.getString('hw_calibration_backup');
  
  // 2. Check server history
  final serverHistory = await supabase
    .from('calibration_resume')
    .select()
    .eq('user_id', userId)
    .order('updated_at', ascending: false)
    .limit(10);
  
  // 3. Reconstruct from workout history
  final workoutSets = await supabase
    .from('sets')
    .select('*, workouts!inner(user_id)')
    .eq('workouts.user_id', userId)
    .order('created_at', ascending: false);
  
  // Use most recent valid data
  final recovered = _selectBestRecoveryData(backup, serverHistory, workoutSets);
  if (recovered != null) {
    await CalibrationResumeStore.saveAttempt(/* ... */);
  }
}
```

#### Corrupted Training State
```dart
// Reset and rebuild from workout history
static Future<void> rebuildTrainingState() async {
  try {
    // Get all workout dates
    final workoutDates = await supabase
      .from('workouts')
      .select('created_at')
      .eq('user_id', userId)
      .order('created_at', ascending: false);
    
    // Calculate current streak
    final streak = _calculateStreakFromDates(workoutDates);
    
    // Determine current day from rotation
    final workoutCount = workoutDates.length;
    final dayNames = ["CHEST", "BACK", "ARMS", "SHOULDERS", "LEGS"];
    final currentDay = dayNames[workoutCount % 5];
    
    // Restore state
    await TrainingState.assignDay(currentDay);
    await _setStreak(streak);
    
    HWLog.event('training_state_recovered', data: {
      'current_day': currentDay,
      'streak': streak,
      'workout_count': workoutCount,
    });
  } catch (e) {
    HWLog.event('training_state_recovery_failed', data: {'error': e.toString()});
    
    // Reset to safe defaults
    await TrainingState.assignDay("CHEST");
    await TrainingState.resetStreak();
  }
}
```

### 🔧 Cache Reset
```dart
// Clear all caches and force reload
static Future<void> resetAllCaches() async {
  // Clear exercise ID cache
  SupabaseWorkoutRepository._exerciseIdCache.clear();
  
  // Clear SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final keysToRemove = prefs.getKeys()
    .where((key) => key.startsWith('hw_'))
    .toList();
  
  for (final key in keysToRemove) {
    await prefs.remove(key);
  }
  
  // Clear system config
  SystemConfig.instance.reset();
  
  // Force reload
  await SystemConfig.instance.load();
  
  HWLog.event('cache_reset_complete');
}
```

---

## Emergency Procedures

### 🚨 Critical Data Loss
1. **Stop all app instances** to prevent further data corruption
2. **Check Supabase audit logs** for recent changes
3. **Restore from backup** if available
4. **Implement data recovery procedures** above
5. **Verify data integrity** before resuming

### 🔥 Production Incident
1. **Assess impact** - How many users affected?
2. **Implement immediate fix** - Rollback or hotfix
3. **Monitor error rates** - Check Supabase dashboard
4. **Communicate status** - Update users if necessary
5. **Post-incident review** - Document and prevent recurrence

---

*Emergency Contact: Check #development-emergency channel*
*Last Updated: 2025-09-15*