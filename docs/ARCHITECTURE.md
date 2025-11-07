# HEAVYWEIGHT App Architecture Documentation

## Overview
HEAVYWEIGHT is a Flutter-based strength training app implementing a 4-6 rep mandate system with cross-device synchronization and performance optimization.

## Architecture Principles

### 1. **Clean Architecture Pattern**
```
┌─────────────────┐
│   Presentation  │ ← Screens, Widgets, ViewModels
├─────────────────┤
│    Business     │ ← Workout Engine, Training Logic
├─────────────────┤
│      Data       │ ← Repositories, APIs, Local Storage
├─────────────────┤
│   Infrastructure│ ← Supabase, SharedPreferences
└─────────────────┘
```

### 2. **State Management: Provider Pattern**
- **ChangeNotifier** for ViewModels
- **Provider** for dependency injection
- **Consumer** widgets for reactive UI updates

### 3. **Data Flow Strategy**
- **Dual Persistence**: Local (SharedPreferences) + Remote (Supabase)
- **Optimistic Updates**: Update UI immediately, sync in background
- **Graceful Degradation**: Multiple fallback layers for reliability

---

## Core Components

### 🏋️ **Workout Engine** (`lib/fortress/engine/`)
**Purpose**: Core business logic for 4-6 rep mandate system

**Key Classes**:
- `WorkoutEngine`: Calculates next weights, rest times, exercise selection
- `DailyWorkout`: Represents today's training plan
- `PlannedExercise`: Individual exercise with prescribed weight/sets

**Features**:
- Epley formula for 1RM calculations
- Adaptive weight progression based on performance
- 5-day rotation system (CHEST → BACK → ARMS → SHOULDERS → LEGS)

### 📊 **Training State** (`lib/core/training_state.dart`)
**Purpose**: Cross-device sticky day persistence and streak tracking

**Capabilities**:
- Day assignment persistence
- Training streak calculation
- Cross-device synchronization via Supabase

**Integration Points**:
- Called from `WorkoutEngine.generateDailyWorkout()` on workout start
- Called from `WorkoutViewModel.processWorkoutResults()` on completion

### 🔄 **Calibration System** (`lib/fortress/calibration/`)
**Purpose**: Find user's true 5RM for each exercise

**Components**:
- `CalibrationResumeStore`: Persist calibration state across sessions
- `CalibrationService`: Load configuration and calculate next weights
- `calibration_config.json`: Rep-specific multipliers and safety limits

**Resume Strategy**:
- Local storage for immediate access
- Supabase sync for cross-device calibration
- Newest-wins conflict resolution

---

## Data Architecture

### 🗄️ **Repository Pattern** (`lib/backend/supabase/`)

#### **SupabaseWorkoutRepository**
**Performance Optimizations**:
```dart
// Exercise ID Caching
Map<String, int> _exerciseIdCache = {};

// Batch RPC (5-10x faster than N queries)
final response = await _supabase.rpc('hw_last_for_exercises_by_slug', 
  params: {'slugs': exerciseIds.toList()});
```

**Fallback Strategy**:
1. **Slug-based RPC** (`hw_last_for_exercises_by_slug`) - Zero warmup
2. **ID-based RPC** (`hw_last_for_exercises`) - Cached IDs
3. **Individual queries** - Last resort

#### **Database Schema**
```sql
-- Performance RPC Functions
hw_last_for_exercises_by_slug(slugs text[])  -- New: Direct slug lookup
hw_last_for_exercises(exercise_ids int[])    -- Existing: ID-based batch

-- Cross-Device Tables
calibration_resume     -- Resume calibration across devices
user_training_state    -- Sticky day and streak persistence
```

### 💾 **Local Storage Strategy**
- **SharedPreferences**: Quick access, offline capability
- **Keys**: Prefixed with `hw_` for namespace isolation
- **Sync**: Fire-and-forget to Supabase, don't block UI

---

## Performance Features

### ⚡ **Query Optimization**
```dart
// BEFORE: 5-10 individual queries (3-5 seconds)
for (exercise in exercises) {
  final id = await getExerciseDbId(exercise);
  final lastSet = await getLastSet(id);
}

// AFTER: Single batch RPC (<1 second)
final allLastSets = await rpc('hw_last_for_exercises_by_slug', 
  params: {'slugs': allExerciseSlugs});
```

### 🎯 **Caching Strategy**
- **Exercise IDs**: In-memory cache, populated on-demand
- **Last Sets**: RPC batch fetching
- **Training State**: Local-first with background sync

### 🛡️ **Error Handling**
```dart
try {
  return await slugBasedRPC();
} catch (_) {
  try {
    return await idBasedRPC();
  } catch (_) {
    return await individualQueries();
  }
}
```

---

## Configuration System

### ⚙️ **SystemConfig** (`lib/core/system_config.dart`)
**JSON-Driven Configuration**:
```json
{
  "multipliers": {
    "failure": 0.8,
    "below": 0.95,
    "mandate": 1.0,
    "exceeded": 1.025
  },
  "rotation_order": ["CHEST", "BACK", "ARMS", "SHOULDERS", "LEGS"],
  "exercise_alternatives": { ... }
}
```

### 🎛️ **Calibration Config** (`assets/calibration_config.json`)
**Rep-Specific Multipliers**:
```json
{
  "rep_multipliers": {
    "5": 1.0,
    "8": 1.25,
    "14": 1.55
  },
  "safety_limits": {
    "max_attempts": 10,
    "min_rest_seconds": 180
  }
}
```

---

## Security & Best Practices

### 🔒 **Database Security**
- **RLS Policies**: All tables filtered by `auth.uid()`
- **SECURITY DEFINER**: RPC functions run with elevated privileges
- **Input Validation**: Parameterized queries prevent injection

### 🔧 **Flutter Best Practices**
- **Null Safety**: All nullable types handled with `??` operator
- **const Constructors**: Performance optimization for immutable widgets
- **super.key**: Proper widget key inheritance
- **Semantic Labels**: Accessibility support

### 📱 **Cross-Platform Considerations**
- **Units**: Metric/Imperial conversion support
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Offline Capability**: Local storage ensures functionality without network

---

## Testing Strategy

### 🧪 **Test Coverage**
```
test/
├── backend/
│   ├── supabase_repository_test.dart    # Repository integration
│   ├── calibration_resume_test.dart     # Cross-device calibration
│   └── training_state_test.dart         # Sticky day persistence
├── fortress/
│   └── engine/
│       └── workout_engine_test.dart     # Core business logic
└── integration/
    └── workout_flow_test.dart           # End-to-end scenarios
```

### 🎯 **Test Categories**
- **Unit Tests**: Core logic, calculations, state management
- **Integration Tests**: Repository interactions, RPC functions
- **Widget Tests**: UI components, user interactions
- **Performance Tests**: Query optimization, caching effectiveness

---

## Monitoring & Observability

### 📊 **Logging Strategy**
```dart
HWLog.event('workout_engine_calc_next_weight', data: {
  'currentWeight': currentWeight,
  'actualReps': actualReps,
  'multiplier': multiplier,
  'nextWeight': nextWeight,
});
```

### 🔍 **Debug Tools**
- **Status Screen**: Real-time app state inspection
- **Performance Metrics**: Query timing, cache hit rates
- **Error Tracking**: Graceful degradation monitoring

---

## Deployment & Scaling

### 🚀 **Release Strategy**
1. **Build Verification**: `flutter build ios --no-codesign`
2. **Test Suite**: Full test execution
3. **Performance Validation**: Assignment screen <1s load time
4. **Database Migrations**: Applied via Supabase migrations/

### 📈 **Scalability Considerations**
- **RPC Functions**: Handle increased user load efficiently
- **Caching**: Reduces database load as user base grows
- **Graceful Degradation**: Maintains functionality under load

---

## Future Enhancements

### 🎯 **Planned Features**
- Social features (post 1.0)
- Advanced analytics dashboard
- Exercise alternative recommendations
- Workout streak gamification

### 🔧 **Technical Debt**
- Migration to newer Flutter versions
- Enhanced error handling
- Advanced caching strategies
- Real-time synchronization

---

*Last Updated: 2025-09-15*
*Version: 1.0 Release Candidate*