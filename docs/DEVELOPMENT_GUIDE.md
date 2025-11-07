# HEAVYWEIGHT Development Guide

## Getting Started

### Prerequisites
- Flutter SDK 3.19+
- Dart 3.3+
- Xcode 15+ (iOS development)
- Android Studio (Android development)
- Supabase CLI (database operations)

### Setup
```bash
# Clone and setup
cd heavyweight-app
flutter pub get

# Environment setup
cp .env.example .env
# Edit .env with your Supabase credentials

# Build verification
flutter build ios --no-codesign
```

---

## Project Structure

```
lib/
├── backend/                     # Data layer
│   └── supabase/               # Supabase integration
│       ├── supabase.dart       # Client configuration
│       └── supabase_workout_repository.dart
├── components/                  # Reusable UI components
│   ├── layout/                 # Layout components
│   └── ui/                     # Basic UI elements
├── core/                       # Core utilities
│   ├── auth_service.dart       # Authentication
│   ├── logging.dart           # Logging utilities
│   ├── system_config.dart     # Configuration management
│   ├── training_state.dart    # Cross-device state
│   └── theme/                 # App theming
├── fortress/                   # Business logic
│   ├── calibration/           # Calibration system
│   ├── engine/               # Workout engine
│   │   ├── models/           # Data models
│   │   └── storage/          # Storage interfaces
│   └── viewmodels/           # Business ViewModels
├── providers/                  # Provider setup
├── screens/                   # UI screens
│   ├── auth/                 # Authentication screens
│   ├── dev/                  # Development tools
│   ├── onboarding/           # User onboarding
│   └── training/             # Workout screens
└── main.dart                  # App entry point

assets/
├── calibration_config.json    # Calibration settings
└── workout_config.json       # Workout configuration

test/
├── backend/                   # Repository tests
├── fortress/                  # Business logic tests
└── integration/               # End-to-end tests

docs/                          # Documentation
├── ARCHITECTURE.md           # System architecture
├── API_REFERENCE.md          # API documentation
└── DEVELOPMENT_GUIDE.md      # This file
```

---

## Development Workflow

### 1. Feature Development
```bash
# Create feature branch
git checkout -b feature/new-feature

# Write tests first (TDD)
flutter test test/path/to/feature_test.dart

# Implement feature
# Edit relevant files...

# Verify build
flutter build ios --no-codesign
flutter test

# Commit and push
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

### 2. Database Changes
```bash
# Create migration
cat > supabase/migrations/$(date +%Y-%m-%d)_migration_name.sql << 'EOF'
-- Migration content
EOF

# Apply migration
claude mcp supabase-apply-migration migration_name

# Test migration
flutter test test/backend/
```

### 3. Performance Testing
```bash
# Profile assignment screen load time
flutter run --profile
# Target: <1 second for assignment screen

# Monitor database queries
# Check Supabase dashboard for query performance
```

---

## Code Standards

### 1. File Organization
```dart
// File header order:
import 'package:flutter/material.dart';          // Flutter imports
import 'package:provider/provider.dart';        // Package imports
import '../core/logging.dart';                  // Relative imports

// Class organization:
class MyWidget extends StatefulWidget {
  // 1. Constants
  // 2. Final fields
  // 3. Constructor
  // 4. Static methods
  // 5. Instance methods
  // 6. Build method
  // 7. Private methods
}
```

### 2. Naming Conventions
```dart
// Files: snake_case
workout_engine.dart
training_state.dart

// Classes: PascalCase
class WorkoutEngine {}
class TrainingState {}

// Variables/Methods: camelCase
final nextWeight = 80.0;
Future<void> calculateNextWeight() {}

// Constants: SCREAMING_SNAKE_CASE
static const String API_BASE_URL = '...';
```

### 3. Documentation Standards
```dart
/// Calculates the next prescribed weight based on performance.
/// 
/// Uses the 4-6 rep mandate system:
/// - 0 reps: Major reduction (0.8x)
/// - 1-3 reps: Minor reduction (0.95x)
/// - 4-6 reps: Maintain weight (1.0x)
/// - 7+ reps: Increase weight (1.025x)
/// 
/// Example:
/// ```dart
/// final nextWeight = engine.calculateNextWeight(80.0, 5);
/// print(nextWeight); // 80.0 (maintained)
/// ```
double calculateNextWeight(double currentWeight, int actualReps) {
  // Implementation...
}
```

### 4. Error Handling Pattern
```dart
Future<T> operationWithFallback<T>(T defaultValue) async {
  try {
    return await primaryOperation();
  } catch (e) {
    HWLog.event('operation_failed', data: {
      'operation': 'primary',
      'error': e.toString(),
    });
    
    try {
      return await fallbackOperation();
    } catch (e2) {
      HWLog.event('fallback_failed', data: {
        'operation': 'fallback',
        'error': e2.toString(),
      });
      return defaultValue;
    }
  }
}
```

---

## Testing Guidelines

### 1. Test Structure
```dart
void main() {
  group('FeatureName', () {
    late FeatureClass feature;
    
    setUp(() {
      feature = FeatureClass();
    });
    
    group('methodName', () {
      test('should return expected result when given valid input', () {
        // Arrange
        final input = validInput;
        final expected = expectedOutput;
        
        // Act
        final result = feature.methodName(input);
        
        // Assert
        expect(result, equals(expected));
      });
      
      test('should handle edge case appropriately', () {
        // Test edge cases...
      });
      
      test('should throw exception when given invalid input', () {
        // Test error cases...
      });
    });
  });
}
```

### 2. Test Categories

#### Unit Tests
```dart
// Test business logic in isolation
test('calculateNextWeight should increase weight when reps exceed mandate', () {
  final engine = WorkoutEngine();
  final result = engine.calculateNextWeight(80.0, 8);
  expect(result, equals(82.0)); // 80 * 1.025
});
```

#### Integration Tests
```dart
// Test repository interactions
test('repository should cache exercise IDs to avoid repeated queries', () async {
  final repo = SupabaseWorkoutRepository();
  
  // First call should hit database
  await repo.getExerciseDbId('bench');
  
  // Second call should use cache
  final cachedResult = await repo.getExerciseDbId('bench');
  
  // Verify cache was used (implementation specific)
});
```

#### Widget Tests
```dart
// Test UI components
testWidgets('AssignmentScreen should show loading indicator initially', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: AssignmentScreen()),
  );
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### 3. Mock Setup
```dart
class MockWorkoutRepository extends Mock implements WorkoutRepositoryInterface {}

void main() {
  late MockWorkoutRepository mockRepo;
  late WorkoutEngine engine;
  
  setUp(() {
    mockRepo = MockWorkoutRepository();
    engine = WorkoutEngine(repository: mockRepo);
  });
  
  test('should use repository when available', () async {
    when(() => mockRepo.getHistory()).thenAnswer((_) async => []);
    
    await engine.generateDailyWorkout([]);
    
    verify(() => mockRepo.getHistory()).called(1);
  });
}
```

---

## Performance Optimization

### 1. Database Query Optimization

#### Problem: N+1 Query Pattern
```dart
// BAD: Multiple individual queries (slow)
for (final exerciseId in exerciseIds) {
  final dbId = await getExerciseDbId(exerciseId);  // Query 1, 2, 3...
  final lastSet = await getLastSet(dbId);          // Query N+1, N+2...
}
```

#### Solution: Batch RPC
```dart
// GOOD: Single batch query (fast)
final lastSets = await supabase.rpc('hw_last_for_exercises_by_slug', {
  'slugs': exerciseIds.toList()
});
```

### 2. Caching Strategy
```dart
class ExerciseIdCache {
  static final Map<String, int> _cache = {};
  
  static Future<int?> getExerciseDbId(String slug) async {
    // Check cache first
    if (_cache.containsKey(slug)) {
      return _cache[slug];
    }
    
    // Fetch from database
    final dbId = await _fetchFromDatabase(slug);
    if (dbId != null) {
      _cache[slug] = dbId;  // Cache for next time
    }
    
    return dbId;
  }
}
```

### 3. Widget Performance
```dart
// Use const constructors
const Text('Static text');

// Extract expensive widgets
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ExpensiveCalculation();
  }
}

// Use Consumer for targeted rebuilds
Consumer<WorkoutViewModel>(
  builder: (context, viewModel, child) {
    return Text(viewModel.status);  // Only rebuilds when status changes
  },
)
```

---

## Debugging & Monitoring

### 1. Logging Strategy
```dart
// Event logging with structured data
HWLog.event('workout_completed', data: {
  'dayName': 'CHEST',
  'exerciseCount': 3,
  'totalSets': 9,
  'adherencePercent': 85,
  'duration_seconds': 2400,
});

// Error logging with context
HWLog.event('repository_error', data: {
  'operation': 'getLastForExercises',
  'exerciseIds': exerciseIds,
  'error': e.toString(),
  'fallback_used': true,
});
```

### 2. Debug Tools

#### Status Screen (`/dev/status`)
```dart
// Shows real-time app state
- Database connection status
- Cache hit rates
- Current training state
- Onboarding completion status
```

#### Performance Monitoring
```dart
// Measure critical operations
final stopwatch = Stopwatch()..start();
final result = await expensiveOperation();
stopwatch.stop();

HWLog.event('performance_measurement', data: {
  'operation': 'assignment_screen_load',
  'duration_ms': stopwatch.elapsedMilliseconds,
  'target_ms': 1000,
  'performance_met': stopwatch.elapsedMilliseconds < 1000,
});
```

### 3. Error Recovery
```dart
// Graceful degradation pattern
class RobustService {
  Future<T> performOperation<T>(T fallbackValue) async {
    try {
      return await primaryMethod();
    } catch (primaryError) {
      _logError('primary_failed', primaryError);
      
      try {
        return await secondaryMethod();
      } catch (secondaryError) {
        _logError('secondary_failed', secondaryError);
        
        // Return safe fallback
        return fallbackValue;
      }
    }
  }
}
```

---

## Deployment Checklist

### Pre-Release
```bash
# 1. Run full test suite
flutter test

# 2. Performance verification
flutter run --profile
# Verify assignment screen loads in <1 second

# 3. Build verification
flutter build ios --no-codesign
flutter build apk --release

# 4. Database migration check
# Ensure all migrations are applied

# 5. Configuration review
# Verify all environment variables are set
```

### Release Process
```bash
# 1. Version bump
# Update pubspec.yaml version

# 2. Generate changelog
# Document new features and fixes

# 3. Create release build
flutter build ios --release
flutter build appbundle --release

# 4. Deploy to app stores
# Follow platform-specific deployment guides
```

---

## Common Issues & Solutions

### 1. Build Failures

#### Missing Dependencies
```bash
flutter clean
flutter pub get
flutter pub deps
```

#### iOS Build Issues
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter build ios --no-codesign
```

### 2. Database Connection Issues

#### Supabase Timeout
```dart
// Increase timeout in supabase client
final supabase = SupabaseClient(
  url, 
  anonKey,
  httpClient: http.Client()..timeout = Duration(seconds: 30),
);
```

#### RPC Function Missing
```sql
-- Check if function exists
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name = 'hw_last_for_exercises_by_slug';
```

### 3. Performance Issues

#### Slow Assignment Screen
1. Check database query performance in Supabase dashboard
2. Verify exercise ID cache is populated
3. Ensure RPC functions are being used instead of individual queries

#### Memory Leaks
```dart
// Always dispose controllers
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// Remove listeners properly
@override
void dispose() {
  viewModel.removeListener(_onViewModelChange);
  super.dispose();
}
```

---

## Contributing Guidelines

### 1. Code Review Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Performance impact considered
- [ ] Error handling implemented
- [ ] Logging added for key operations
- [ ] Build passes
- [ ] No breaking changes to API

### 2. Commit Message Format
```
type(scope): description

feat(workout): add progressive overload calculation
fix(auth): handle expired token gracefully
docs(api): update repository interface documentation
perf(db): implement batch RPC for exercise queries
```

### 3. Pull Request Template
```markdown
## Changes
- Brief description of changes

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Performance Impact
- Assignment screen load time: <1s
- Database queries: Optimized with RPC

## Breaking Changes
- None / List any breaking changes
```

---

*Last Updated: 2025-09-15*
*For questions, see #development channel*