# HEAVYWEIGHT Codebase Structure Map

## Overview
This document maps out every part of the HEAVYWEIGHT app codebase (97 Dart files) and explains what each component does and how they connect.

## 📁 **Directory Structure**

```
lib/
├── 📱 main.dart                    # App entry point
├── 📋 index.dart                   # Barrel exports
├── 🧠 core/                        # Core utilities & services
├── 🏗️ fortress/                    # Business logic & workout engine
├── 🎨 components/                  # Reusable UI components
├── 📺 screens/                     # App screens/pages
├── 🔌 providers/                   # Provider pattern setup
├── 🗄️ backend/                     # Data layer (Supabase)
├── 🎯 viewmodels/                  # Presentation logic
├── ⚙️ services/                    # External services
├── 📚 lexicon/                     # Text strings/content
└── 🛠️ dev/                         # Development utilities
```

---

## 🧠 **Core (`lib/core/`)**
*Foundation services and utilities*

### **Authentication & State**
| File | Purpose | Key Exports |
|------|---------|-------------|
| `auth_service.dart` | Supabase authentication wrapper | `AuthService` class |
| `app_state.dart` | Global application state | `AppState`, `NextRouteDebug` |
| `training_state.dart` | Cross-device training persistence | `TrainingState` static methods |

### **Configuration & System**
| File | Purpose | Key Exports |
|------|---------|-------------|
| `system_config.dart` | JSON configuration loader | `SystemConfig.instance` |
| `system_metrics.dart` | Performance metrics calculation | `SystemMetricsService` |
| `supabase_config.dart` | Supabase client configuration | Supabase setup |

### **Navigation & Routing**
| File | Purpose | Key Exports |
|------|---------|-------------|
| `routes.dart` | GoRouter configuration | Route definitions |
| `page_transitions.dart` | Custom page animations | Transition builders |
| `nav_logging.dart` | Navigation event tracking | Navigation observers |
| `route_observer.dart` | Route change monitoring | `RouteObserver` |
| `router_refresh.dart` | Router state refresh logic | Refresh notifiers |

### **Utilities**
| File | Purpose | Key Exports |
|------|---------|-------------|
| `logging.dart` | Structured event logging | `HWLog.event()` |
| `log_config.dart` | Logging configuration | Log setup |
| `error_handler.dart` | Global error handling | Error widgets |
| `command.dart` | Command pattern implementation | `Command` classes |
| `result.dart` | Result type for error handling | `Result<T, E>` |
| `units.dart` | Unit conversion (kg/lbs) | Conversion functions |
| `strings.dart` | String constants | Static strings |

### **Theme**
| File | Purpose | Key Exports |
|------|---------|-------------|
| `theme/heavyweight_theme.dart` | App theme definitions | Colors, typography, spacing |

### **Models**
| File | Purpose | Key Exports |
|------|---------|-------------|
| `models/*.dart` | Core data models | Various model classes |

---

## 🏗️ **Fortress (`lib/fortress/`)**
*Business logic and workout engine*

### **Core Engine**
| File | Purpose | Key Components |
|------|---------|----------------|
| `engine/workout_engine.dart` | **CORE BUSINESS LOGIC** | `WorkoutEngine`, `DailyWorkout`, `PlannedExercise` |
| `engine/models/exercise.dart` | Exercise definitions | `Exercise` class, Big Six exercises |
| `engine/models/set_data.dart` | Workout set data model | `SetData` class |
| `engine/storage/workout_repository_interface.dart` | Repository contract | `WorkoutRepositoryInterface` |
| `engine/storage/workout_repository.dart` | Local storage implementation | `WorkoutRepository` |
| `engine/services/*.dart` | Engine service layer | Various engine services |

### **Calibration System**
| File | Purpose | Key Components |
|------|---------|----------------|
| `calibration/calibration_resume_store.dart` | **Cross-device calibration** | `CalibrationResumeStore`, `CalibrationAttemptRecord` |
| `calibration/calibration_service.dart` | Calibration configuration | `CalibrationService` |

### **Feature Modules**
| Directory | Purpose | Key Components |
|-----------|---------|----------------|
| `daily_workout/` | Daily workout generation | Workout planning logic |
| `protocol/` | Workout execution protocol | Protocol screens and widgets |
| `protocol/widgets/` | Protocol UI components | Exercise widgets, timers |
| `session_complete/` | Post-workout summary | Completion logic |
| `manifesto/` | App philosophy/onboarding | Manifesto content |

### **ViewModels**
| File | Purpose | Key Exports |
|------|---------|-------------|
| `viewmodels/workout_viewmodel.dart` | **Workout screen state** | `WorkoutViewModel` |
| `viewmodels/logbook_viewmodel.dart` | Training log state | `LogbookViewModel` |

---

## 🎨 **Components (`lib/components/`)**
*Reusable UI building blocks*

### **Layout Components**
| File | Purpose | Usage |
|------|---------|--------|
| `layout/heavyweight_scaffold.dart` | **Base app layout** | All screens use this |
| `layout/*.dart` | Layout helpers | Various layout utilities |

### **Navigation**
| File | Purpose | Usage |
|------|---------|--------|
| `navigation/*.dart` | Navigation components | Bottom tabs, app bars |

### **UI Components**
| File | Purpose | Usage |
|------|---------|--------|
| `ui/command_button.dart` | **Primary action button** | Used throughout app |
| `ui/hw_text_field.dart` | Custom text input | Forms and data entry |
| `ui/hw_badge.dart` | Status badges | Training status indicators |
| `ui/exercise_alternatives_widget.dart` | Exercise selection UI | Exercise picker |
| `ui/*.dart` | Other UI components | Various reusable widgets |

---

## 📺 **Screens (`lib/screens/`)**
*Application pages and user interfaces*

### **Training Flow**
| File | Purpose | Navigation Path |
|------|---------|----------------|
| `training/assignment_screen.dart` | **Today's workout assignment** | `/app` (main tab) |
| `training/daily_workout_screen.dart` | Workout details view | From assignment |
| `training/protocol_screen.dart` | **Active workout execution** | Core training flow |
| `training/session_active_screen.dart` | Live workout tracking | During training |
| `training/session_complete_screen.dart` | **Post-workout summary** | After completion |
| `training/training_log_screen.dart` | Historical workout data | `/app?tab=1` |
| `training/session_detail_screen.dart` | Individual session details | From log |
| `training/exercise_intel_screen.dart` | Exercise information | Exercise details |
| `training/enforced_rest_screen.dart` | Rest day enforcement | Rest periods |

### **User Management**
| File | Purpose | Navigation Path |
|------|---------|----------------|
| `profile/profile_screen.dart` | User profile & settings | `/profile` |
| `settings/settings_main_screen.dart` | App settings | From profile |

### **Onboarding Flow**
| Directory | Purpose | Flow |
|-----------|---------|------|
| `onboarding/manifesto_screen.dart` | App philosophy intro | First-time users |
| `onboarding/profile/` | Profile setup screens | Multi-step onboarding |
| `onboarding/profile/physical_stats_screen.dart` | Height/weight/age | Onboarding step |
| `onboarding/profile/session_duration_screen.dart` | Workout time preference | Onboarding step |
| `onboarding/profile/starting_day_screen.dart` | Day preference | Onboarding step |

### **Calibration**
| File | Purpose | Usage |
|------|---------|--------|
| `calibration/*.dart` | Exercise calibration flow | Find user's 5RM |

### **Business Features**
| File | Purpose | Usage |
|------|---------|--------|
| `paywall/paywall_screen.dart` | Subscription prompt | Premium features |
| `paywall/subscription_plans_screen.dart` | Plan selection | From paywall |

### **Development & Debug**
| File | Purpose | Usage |
|------|---------|--------|
| `dev/status_screen.dart` | **Debug information** | `/dev/status` |
| `dev/config_screen.dart` | Configuration viewer | Debug mode |
| `dev/screen_index.dart` | Dev screen navigation | Debug tools |

### **Error Handling**
| File | Purpose | Usage |
|------|---------|--------|
| `error/error_screen.dart` | Error page display | When errors occur |

---

## 🔌 **Providers (`lib/providers/`)**
*Provider pattern for dependency injection*

| File | Purpose | Provides |
|------|---------|----------|
| `app_state_provider.dart` | **Global app state** | `AppState` |
| `workout_engine_provider.dart` | **Workout engine singleton** | `WorkoutEngine` |
| `workout_viewmodel_provider.dart` | Workout screen state | `WorkoutViewModel` |
| `logbook_viewmodel_provider.dart` | Log screen state | `LogbookViewModel` |
| `repository_provider.dart` | **Data repository** | `SupabaseWorkoutRepository` |
| `profile_provider.dart` | Profile management | Profile state |

---

## 🗄️ **Backend (`lib/backend/`)**
*Data persistence and API integration*

| File | Purpose | Key Features |
|------|---------|-------------|
| `supabase/supabase.dart` | **Supabase client setup** | Authentication, database config |
| `supabase/supabase_workout_repository.dart` | **Main data repository** | All database operations, RPC calls, caching |

### **Repository Features**
- **Performance Optimization**: Exercise ID caching, batch RPC calls
- **Cross-Device Sync**: Calibration and training state
- **Graceful Fallbacks**: Multiple query strategies
- **Security**: RLS policy compliance

---

## 🎯 **ViewModels (`lib/viewmodels/`)**
*Presentation logic and state management*

| File | Purpose | Manages |
|------|---------|---------|
| `exercise_viewmodel.dart` | Exercise data and alternatives | Exercise selection state |

---

## ⚙️ **Services (`lib/services/`)**
*External service integrations*

| File | Purpose | Integration |
|------|---------|-------------|
| `*.dart` | External APIs and services | Third-party integrations |

---

## 📚 **Lexicon (`lib/lexicon/`)**
*Content and text management*

| File | Purpose | Contains |
|------|---------|----------|
| `*.dart` | App text and content | Strings, copy, messaging |

---

## 🛠️ **Dev (`lib/dev/`)**
*Development utilities*

| File | Purpose | Usage |
|------|---------|--------|
| `*.dart` | Development tools | Debug utilities |

---

## 🔗 **Key Connections & Data Flow**

### **Main User Flow**
```
main.dart
  ↓
App with Providers
  ↓
Assignment Screen (shows today's workout)
  ↓
Protocol Screen (executes workout)
  ↓
Session Complete Screen (summarizes results)
```

### **Data Flow**
```
User Action → Screen → ViewModel → Repository → Supabase
                ↓
          Local Cache ← SharedPreferences
```

### **Critical Files for Core Functionality**
1. **`workout_engine.dart`** - All business logic
2. **`supabase_workout_repository.dart`** - All data operations
3. **`assignment_screen.dart`** - Main user interface
4. **`protocol_screen.dart`** - Workout execution
5. **`training_state.dart`** - Cross-device persistence
6. **`calibration_resume_store.dart`** - Calibration sync

### **Provider Dependency Chain**
```
App
├── AppStateProvider
├── RepositoryProvider (SupabaseWorkoutRepository)
├── WorkoutEngineProvider
└── WorkoutViewModelProvider (depends on engine + repository)
```

### **Configuration Flow**
```
system_config.dart loads assets/system_config.json
       ↓
WorkoutEngine uses config for multipliers, rotation
       ↓
All calculations use config-driven values
```

---

## 🎯 **Entry Points by Feature**

### **Add New Exercise**
1. `fortress/engine/models/exercise.dart` - Add to Big Six
2. `SUPABASE_SCHEMA_UPDATE.sql` - Add to database
3. `calibration_resume_store.dart` - Update slug mapping

### **Modify Workout Logic**  
1. `fortress/engine/workout_engine.dart` - Core algorithms
2. `assets/system_config.json` - Configuration values

### **Add New Screen**
1. Create in appropriate `screens/` subdirectory
2. Add route in `core/routes.dart`
3. Add provider if needed in `providers/`

### **Modify UI Components**
1. `components/ui/` - Reusable components
2. `core/theme/heavyweight_theme.dart` - Styling

### **Database Changes**
1. Create migration in `supabase/migrations/`
2. Update `supabase_workout_repository.dart`
3. Update models if needed

---

*This map covers all 97 files in your codebase and shows exactly how everything connects!*

**Next**: Want me to create detailed data flow documentation showing how information moves through these components?