# HEAVYWEIGHT Implementation Specification
## Complete File Structure & Technical Requirements

---

## 📊 OVERVIEW

- **Total Screens**: 32 (optimized from original 30+)
- **Architecture**: Clean Architecture with services layer
- **Navigation**: Go Router with guards
- **State**: Provider + local state
- **Database**: Supabase with real-time sync

---

## 📁 FILE STRUCTURE

```
lib/
├── screens/
│   ├── onboarding/
│   │   ├── splash_screen.dart                    # Screen 1
│   │   ├── legal_gate_screen.dart               # Screen 2 (NEW)
│   │   ├── manifesto_screen.dart                # Screen 3 (EXISTS - needs update)
│   │   ├── profile/
│   │   │   ├── training_experience_screen.dart   # Screen 4
│   │   │   ├── training_frequency_screen.dart    # Screen 5
│   │   │   ├── physical_stats_screen.dart        # Screen 6
│   │   │   ├── training_objective_screen.dart    # Screen 7
│   │   │   └── unit_selection_screen.dart        # Screen 8 (NEW)
│   │   ├── auth_screen.dart                     # Screen 9 (merged signup/login)
│   │   ├── safety_disclaimer_screen.dart        # Screen 10 (NEW)
│   │   └── notification_permission_screen.dart  # Screen 11 (NEW)
│   ├── calibration/
│   │   ├── calibration_session_screen.dart      # Screen 12
│   │   └── calibration_complete_screen.dart     # Screen 13
│   ├── training/
│   │   ├── assignment_screen.dart               # Screen 14 (main home)
│   │   ├── session_active_screen.dart           # Screen 15
│   │   ├── enforced_rest_screen.dart           # Screen 16
│   │   ├── session_complete_screen.dart         # Screen 17
│   │   └── training_log_screen.dart            # Screen 18
│   ├── settings/
│   │   ├── settings_screen.dart                # Screen 19 (merged profile)
│   │   └── subscription_status_screen.dart     # Screen 20
│   ├── paywall/
│   │   ├── trial_progress_screen.dart          # Screen 21
│   │   ├── paywall_screen.dart                 # Screen 22
│   │   ├── subscription_plans_screen.dart      # Screen 23
│   │   └── subscription_restore_screen.dart    # Screen 24 (NEW)
│   ├── errors/
│   │   ├── input_error_screen.dart             # Screen 25
│   │   ├── network_error_screen.dart           # Screen 26
│   │   ├── session_interrupted_screen.dart     # Screen 27
│   │   ├── auth_error_screen.dart              # Screen 28
│   │   ├── forgot_password_screen.dart         # Screen 29
│   │   ├── empty_state_screen.dart             # Screen 30
│   │   ├── data_export_screen.dart             # Screen 31
│   │   └── app_update_required_screen.dart     # Screen 32 (NEW)
├── components/
│   ├── ui/
│   │   ├── system_banner.dart                  # HEAVYWEIGHT header
│   │   ├── command_button.dart                 # Consistent buttons
│   │   ├── selector_wheel.dart                 # Number picker
│   │   ├── radio_selector.dart                 # Option picker
│   │   ├── log_panel.dart                      # Workout logs
│   │   ├── rest_timer.dart                     # Countdown timer
│   │   ├── progress_bar.dart                   # Progress indicators
│   │   ├── navigation_bar.dart                 # Bottom nav
│   │   └── error_card.dart                     # Error display
│   ├── forms/
│   │   ├── profile_form_widgets.dart           # Profile input components
│   │   └── auth_form_widgets.dart              # Auth components
│   └── workout/
│       ├── exercise_card.dart                  # Exercise display
│       ├── set_logger.dart                     # Rep logging
│       └── weight_display.dart                 # Weight visualization
├── services/
│   ├── auth_service.dart                       # Authentication
│   ├── profile_service.dart                    # Profile management
│   ├── workout_service.dart                    # Workout logic
│   ├── calibration_service.dart                # Calibration engine
│   ├── subscription_service.dart               # IAP/billing
│   ├── storage_service.dart                    # Local storage
│   └── analytics_service.dart                  # Event tracking
├── models/
│   ├── user/
│   │   ├── profile.dart                        # User profile data
│   │   └── subscription.dart                   # Subscription status
│   ├── workout/
│   │   ├── workout.dart                        # Workout session
│   │   ├── exercise.dart                       # Exercise definition
│   │   ├── set.dart                           # Individual set
│   │   └── assignment.dart                     # Daily assignment
│   └── calibration/
│       ├── calibration.dart                    # Calibration data
│       └── working_load.dart                   # Computed loads
├── utils/
│   ├── constants.dart                          # App constants
│   ├── copy_tokens.dart                        # UI text
│   ├── weight_calculator.dart                  # Load calculations
│   ├── validators.dart                         # Input validation
│   ├── formatters.dart                         # Data formatting
│   └── navigation_guards.dart                  # Route protection
├── providers/
│   ├── auth_provider.dart                      # Auth state
│   ├── profile_provider.dart                   # Profile state
│   ├── workout_provider.dart                   # Workout state
│   ├── subscription_provider.dart              # Subscription state
│   └── navigation_provider.dart                # Navigation state
├── config/
│   ├── routes.dart                             # Route definitions
│   ├── theme.dart                              # App theme
│   └── database.dart                           # Supabase config
└── main.dart                                   # App entry point
```

---

## 🎯 SCREEN SPECIFICATIONS

### 🚀 ONBOARDING SCREENS

#### **1. SplashScreen (`screens/onboarding/splash_screen.dart`)**
```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
}

// Features:
- HEAVYWEIGHT logo/title
- Loading animation
- Auto-redirect after 2 seconds
- Initialize services
```

#### **2. LegalGateScreen (`screens/onboarding/legal_gate_screen.dart`)**
```dart
class LegalGateScreen extends StatelessWidget {
  const LegalGateScreen({Key? key}) : super(key: key);
}

// UI:
TERMS_AND_PRIVACY
YOU MUST ACCEPT TO USE THIS SYSTEM.
[ VIEW_TERMS ] [ VIEW_PRIVACY ]
COMMAND: ACCEPT

// Logic:
- Links to external terms/privacy
- Store acceptance timestamp
- Proceed to manifesto
```

#### **3. ManifestoScreen (`screens/onboarding/manifesto_screen.dart`)** ✅ EXISTS
```dart
// UPDATE EXISTING FILE
- Keep I_COMMIT validation
- Remove animations (keep simple)
- Add proper navigation to profile flow
- Match terminal aesthetic
```

#### **4. TrainingExperienceScreen (`screens/onboarding/profile/training_experience_screen.dart`)**
```dart
class TrainingExperienceScreen extends StatelessWidget {
  const TrainingExperienceScreen({Key? key}) : super(key: key);
}

// Features:
- Radio buttons for BEGINNER | INTERMEDIATE | ADVANCED
- Store in ProfileProvider.experience
- Navigation: → TrainingFrequencyScreen
```

#### **5. TrainingFrequencyScreen (`screens/onboarding/profile/training_frequency_screen.dart`)**
```dart
// UI: Selector wheel for 3-6 days
// State: Store in ProfileProvider.frequency
// Navigation: → PhysicalStatsScreen
```

#### **6. PhysicalStatsScreen (`screens/onboarding/profile/physical_stats_screen.dart`)**
```dart
// Features:
- Age selector (16-80)
- Weight input with unit conversion
- Height input with unit conversion
- Store in ProfileProvider
// Navigation: → TrainingObjectiveScreen
```

#### **7. TrainingObjectiveScreen (`screens/onboarding/profile/training_objective_screen.dart`)**
```dart
// UI: Radio buttons for STRENGTH | SIZE | ENDURANCE | GENERAL
// State: Store in ProfileProvider.objective
// Navigation: → UnitSelectionScreen
// State: Store in ProfileProvider.daysPerWeek
// Navigation: → PhysicalStatsScreen
```

**PhysicalStatsScreen**
```dart
// UI: Three selector wheels (age/weight/height)
// State: Store in ProfileProvider
// Navigation: → TrainingObjectiveScreen
```

**TrainingObjectiveScreen**
```dart
// UI: Radio buttons for STRENGTH | SIZE | DISCIPLINE
// State: Store in ProfileProvider.objective
// Navigation: → UnitSelectionScreen
```

#### **8. UnitSelectionScreen (`screens/onboarding/unit_selection_screen.dart`)**
```dart
// UI: Toggle between KG | LB
// State: Store in ProfileProvider.unit
// Logic: Affects all weight calculations
// Navigation: → AuthScreen
```

#### **9. AuthScreen (`screens/onboarding/auth_screen.dart`)**
```dart
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
}

// Features:
- Toggle between SIGNUP | LOGIN
- Email/password fields
- On signup: save ProfileProvider data to Supabase
- Forgot password link
- Navigation: → SafetyDisclaimerScreen
```

#### **10. SafetyDisclaimerScreen (`screens/onboarding/safety_disclaimer_screen.dart`)**
```dart
// UI:
DISCLAIMER
YOU ARE RESPONSIBLE FOR YOUR FORM AND SAFETY.
THIS SYSTEM PRESCRIBES LOADS; YOU DECIDE TO EXECUTE.
COMMAND: ACKNOWLEDGE

// Navigation: → CalibrationSessionScreen
```

---

### ⚙️ CALIBRATION SCREENS

#### **12. CalibrationSessionScreen (`screens/calibration/calibration_session_screen.dart`)**
```dart
class CalibrationSessionScreen extends StatefulWidget {
  const CalibrationSessionScreen({Key? key}) : super(key: key);
}

// Features:
- Exercise progression (bench → squat → deadlift)
- Weight/rep selectors
- Target: 8-12 reps validation
- Progress indicator
- Save to calibrations table
```

#### **13. CalibrationCompleteScreen (`screens/calibration/calibration_complete_screen.dart`)**
```dart
// UI: Show computed working loads for all exercises
// Logic: Calculate 4-6 rep weights from calibration
// Navigation: → AssignmentScreen (main app)
```

---

### 💪 TRAINING SCREENS

#### **14. AssignmentScreen (`screens/training/assignment_screen.dart`)**
```dart
class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({Key? key}) : super(key: key);
}

// Features:
- Today's workout display
- Exercise list with weights
- Start session button
- Last session summary
- Bottom navigation visible
- Main home screen after login
```

#### **15. SessionActiveScreen (`screens/training/session_active_screen.dart`)**
```dart
// Features:
- Current exercise/set display
- Rep logger component
- Weight display
- Inline feedback panel (after LOG_SET)
- Progress through workout
- Log panel at bottom
```

#### **16. EnforcedRestScreen (`screens/training/enforced_rest_screen.dart`)**
```dart
// Features:
- Full screen countdown timer
- Lock all commands during rest
- Next set preview
- Skip button (disabled until timer ends)
```

#### **17. SessionCompleteScreen (`screens/training/session_complete_screen.dart`)**
```dart
// Features:
- Performance summary
- Duration display
- Sets completed count
- Performance breakdown (on target/above/below)
- Navigation: → TrialProgressScreen
```

#### **18. TrainingLogScreen (`screens/training/training_log_screen.dart`)**
```dart
// Features:
- Scrollable workout history
- Date | Assignment | Performance
- Expandable set details
- Export options
- Bottom navigation visible
```

---

### ⚙️ SETTINGS SCREENS

#### **19. SettingsScreen (`screens/settings/settings_screen.dart`)**
```dart
// Features:
- Account info
- Inline profile editing (selectors)
- Subscription status
- Data export
- Logout
- Bottom navigation visible
```

#### **20. SubscriptionStatusScreen (`screens/settings/subscription_status_screen.dart`)**
```dart
// Features:
- Current plan display
- Renewal date
- Manage subscription
- Restore purchase
- Cancel/modify options
```

---

### 💰 PAYWALL SCREENS

#### **21. TrialProgressScreen (`screens/paywall/trial_progress_screen.dart`)**
```dart
// Features:
- Sessions completed: X/5
- Progress bar
- Continue button
- Show after each session
```

#### **22. PaywallScreen (`screens/paywall/paywall_screen.dart`)**
```dart
// Features:
- Trial expired message
- Benefits of subscription
- View plans button
- Block further access
```

#### **23. SubscriptionPlansScreen (`screens/paywall/subscription_plans_screen.dart`)**
```dart
// Features:
- Monthly/yearly options
- Price display
- Feature comparison
- Purchase buttons
- RevenueCat integration
```

#### **11. DataExportScreen (`screens/settings/data_export_screen.dart`)**
```dart
// Features:
- Export training data as CSV/JSON
- Email export functionality
- Data privacy options
- Backup to cloud storage
```

---

## 🧩 SHARED COMPONENTS

### **SystemBanner (`components/ui/system_banner.dart`)**
```dart
class SystemBanner extends StatelessWidget {
  const SystemBanner({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'HEAVYWEIGHT',
        textAlign: TextAlign.center,
        style: GoogleFonts.ibmPlexMono(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    );
  }
}
```

### **CommandButton (`components/ui/command_button.dart`)**
```dart
class CommandButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isInverse;
  final bool isDisabled;
  
  const CommandButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isInverse = false,
    this.isDisabled = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 60,
        color: isInverse ? Colors.white : Colors.transparent,
        decoration: isInverse ? null : BoxDecoration(
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.ibmPlexMono(
              color: isInverse ? Colors.black : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
```

### **SelectorWheel (`components/ui/selector_wheel.dart`)**
```dart
class SelectorWheel extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final Function(int) onChanged;
  final String suffix;
  
  const SelectorWheel({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix = '',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.chevron_left, color: Colors.white),
        ),
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
          ),
          child: Text(
            '$value $suffix',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.chevron_right, color: Colors.white),
        ),
      ],
    );
  }
}
```

### **RadioSelector (`components/ui/radio_selector.dart`)**
```dart
class RadioSelector<T> extends StatelessWidget {
  final List<RadioOption<T>> options;
  final T? selectedValue;
  final Function(T) onChanged;
  
  const RadioSelector({
    Key? key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = option.value == selectedValue;
        return GestureDetector(
          onTap: () => onChanged(option.value),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.circle,
                  ),
                  child: isSelected ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ) : null,
                ),
                const SizedBox(width: 16),
                Text(
                  option.label,
                  style: GoogleFonts.ibmPlexMono(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class RadioOption<T> {
  final T value;
  final String label;
  
  const RadioOption({required this.value, required this.label});
}
```

### **NavigationBar (`components/ui/navigation_bar.dart`)**
```dart
class HeavyweightNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const HeavyweightNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    const tabs = ['ASSIGNMENT', 'TRAINING_LOG', 'SETTINGS'];
    
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white)),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = index == currentIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                color: isSelected ? Colors.white : Colors.transparent,
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.ibmPlexMono(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

### **CountdownTimer (`components/ui/countdown_timer.dart`)**
```dart
class CountdownTimer extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback? onComplete;
  final bool autoStart;
  
  const CountdownTimer({
    Key? key,
    required this.durationSeconds,
    this.onComplete,
    this.autoStart = true,
  }) : super(key: key);
  
  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingSeconds;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    if (widget.autoStart) {
      _startTimer();
    }
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          widget.onComplete?.call();
        }
      });
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedTime,
      style: GoogleFonts.ibmPlexMono(
        color: _remainingSeconds <= 10 ? Colors.red : Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }
}
```

### **LoadingIndicator (`components/ui/loading_indicator.dart`)**
```dart
class LoadingIndicator extends StatelessWidget {
  final String? message;
  
  const LoadingIndicator({Key? key, this.message}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
            if (message != null) ..[
              const SizedBox(height: 16),
              Text(
                message!,
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### **SaveIndicator (`components/ui/save_indicator.dart`)**
```dart
class SaveIndicator extends StatelessWidget {
  final bool isVisible;
  
  const SaveIndicator({Key? key, required this.isVisible}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade800,
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              'SAVED',
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### **ErrorBanner (`components/ui/error_banner.dart`)**
```dart
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  
  const ErrorBanner({
    Key? key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.red.shade900,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
          if (onRetry != null) ..[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'RETRY',
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          if (onDismiss != null) ..[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 🔄 STATE MANAGEMENT

### **AuthProvider (`providers/auth_provider.dart`)**
```dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  
  Future<void> signUp(String email, String password, Profile profile) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _user = response.user;
        await ProfileService.saveProfile(profile.copyWith(userId: _user!.id));
      }
    } catch (e) {
      throw AuthException(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### **ProfileProvider (`providers/profile_provider.dart`)**
```dart
class ProfileProvider extends ChangeNotifier {
  Profile _profile = Profile.empty();
  
  Profile get profile => _profile;
  bool get isComplete => _profile.isComplete;
  
  void updateExperience(ExperienceLevel experience) {
    _profile = _profile.copyWith(experience: experience);
    notifyListeners();
  }
  
  void updateDaysPerWeek(int days) {
    _profile = _profile.copyWith(daysPerWeek: days);
    notifyListeners();
  }
  
  void updatePhysicalStats(int age, double weight, int height) {
    _profile = _profile.copyWith(
      age: age,
      weight: weight,
      height: height,
    );
    notifyListeners();
  }
  
  void updateObjective(TrainingObjective objective) {
    _profile = _profile.copyWith(objective: objective);
    notifyListeners();
  }
  
  void updateUnit(WeightUnit unit) {
    _profile = _profile.copyWith(unit: unit);
    notifyListeners();
  }
  
  void reset() {
    _profile = Profile.empty();
    notifyListeners();
  }
}
```

---

## 🛣️ NAVIGATION & ROUTING

### **Routes (`config/routes.dart`)**
```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/legal',
      builder: (context, state) => const LegalGateScreen(),
    ),
    GoRoute(
      path: '/manifesto',
      builder: (context, state) => const ManifestoScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const TrainingExperienceScreen(),
      routes: [
        GoRoute(
          path: '/frequency',
          builder: (context, state) => const TrainingFrequencyScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const PhysicalStatsScreen(),
        ),
        GoRoute(
          path: '/objective',
          builder: (context, state) => const TrainingObjectiveScreen(),
        ),
        GoRoute(
          path: '/units',
          builder: (context, state) => const UnitSelectionScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/disclaimer',
      builder: (context, state) => const SafetyDisclaimerScreen(),
    ),
    GoRoute(
      path: '/calibration',
      builder: (context, state) => const CalibrationSessionScreen(),
      routes: [
        GoRoute(
          path: '/complete',
          builder: (context, state) => const CalibrationCompleteScreen(),
        ),
      ],
    ),
    // Protected routes (require auth)
    GoRoute(
      path: '/assignment',
      builder: (context, state) => const AssignmentScreen(),
      redirect: _requireAuth,
    ),
    GoRoute(
      path: '/session',
      builder: (context, state) => const SessionActiveScreen(),
      redirect: _requireAuth,
    ),
    GoRoute(
      path: '/rest',
      builder: (context, state) => const EnforcedRestScreen(),
      redirect: _requireAuth,
    ),
    GoRoute(
      path: '/complete',
      builder: (context, state) => const SessionCompleteScreen(),
      redirect: _requireAuth,
    ),
    GoRoute(
      path: '/log',
      builder: (context, state) => const TrainingLogScreen(),
      redirect: _requireAuth,
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      redirect: _requireAuth,
    ),
    GoRoute(
      path: '/trial',
      builder: (context, state) => const TrialProgressScreen(),
      redirect: _requireAuth,
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
      redirect: _requireAuth,
    ),
    // Error routes
    GoRoute(
      path: '/error/input',
      builder: (context, state) => const InputErrorScreen(),
    ),
    GoRoute(
      path: '/error/network',
      builder: (context, state) => const NetworkErrorScreen(),
    ),
    GoRoute(
      path: '/error/interrupted',
      builder: (context, state) => const SessionInterruptedScreen(),
    ),
  ],
);

String? _requireAuth(BuildContext context, GoRouterState state) {
  final authProvider = context.read<AuthProvider>();
  if (!authProvider.isAuthenticated) {
    return '/auth';
  }
  
  final profileProvider = context.read<ProfileProvider>();
  if (!profileProvider.isComplete) {
    return '/profile';
  }
  
  // Check calibration status
  final calibrationProvider = context.read<CalibrationProvider>();
  if (!calibrationProvider.isComplete) {
    return '/calibration';
  }
  
  return null; // Allow access
}
```

---

## 📊 DATABASE SCHEMA

### **Profiles Table**
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  experience_level TEXT CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
  days_per_week INTEGER CHECK (days_per_week BETWEEN 3 AND 6),
  age INTEGER CHECK (age BETWEEN 13 AND 100),
  weight DECIMAL(5,2),
  height INTEGER,
  objective TEXT CHECK (objective IN ('strength', 'size', 'discipline')),
  unit TEXT CHECK (unit IN ('kg', 'lb')) DEFAULT 'kg',
  terms_accepted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = user_id);
```

### **Calibrations Table**
```sql
CREATE TABLE calibrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise TEXT NOT NULL,
  baseline_weight DECIMAL(5,2) NOT NULL,
  baseline_reps INTEGER NOT NULL,
  computed_working_load DECIMAL(5,2) NOT NULL,
  calibrated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS policies
ALTER TABLE calibrations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own calibrations" ON calibrations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own calibrations" ON calibrations FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### **Workouts Table** 
```sql
CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  assignment_type TEXT NOT NULL,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  total_sets INTEGER DEFAULT 0
);

-- RLS policies
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own workouts" ON workouts USING (auth.uid() = user_id);
```

### **Sets Table**
```sql
CREATE TABLE sets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE,
  exercise TEXT NOT NULL,
  weight DECIMAL(5,2) NOT NULL,
  target_reps INTEGER,
  actual_reps INTEGER NOT NULL,
  rest_seconds INTEGER,
  logged_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS policies  
ALTER TABLE sets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage sets for own workouts" ON sets 
  USING (EXISTS (
    SELECT 1 FROM workouts 
    WHERE workouts.id = sets.workout_id 
    AND workouts.user_id = auth.uid()
  ));
```

---

## 🎨 THEME & CONSTANTS

### **Theme (`config/theme.dart`)**
```dart
class HeavyweightTheme {
  static const Color backgroundColor = Color(0xFF111111);
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Color(0xFF444444);
  static const Color accent = Colors.white;
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: accent,
    textTheme: GoogleFonts.ibmPlexMonoTextTheme(
      ThemeData.dark().textTheme.apply(
        bodyColor: primaryText,
        displayColor: primaryText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
      ),
    ),
  );
}
```

### **Constants (`utils/constants.dart`)**
```dart
class HeavyweightConstants {
  // App info
  static const String appName = 'HEAVYWEIGHT';
  static const String version = '1.0.0';
  
  // Workout constants
  static const int targetRepsMin = 4;
  static const int targetRepsMax = 6;
  static const int calibrationRepsMin = 8;
  static const int calibrationRepsMax = 12;
  static const int restSeconds = 180;
  
  // Weight calculations
  static const double weightDecreasePercent = 0.925; // -7.5%
  static const double weightIncreasePercent = 1.025; // +2.5%
  static const double kgIncrement = 2.5;
  static const double lbIncrement = 5.0;
  
  // Trial limits
  static const int freeSessionsLimit = 5;
  
  // Exercises
  static const List<String> exercises = [
    'BENCH_PRESS',
    'SQUAT',
    'DEADLIFT',
    'OVERHEAD_PRESS',
    'ROW',
    'PULL_UP',
    'INCLINE_PRESS',
    'DIPS',
  ];
}
```

### **Copy Tokens (`utils/copy_tokens.dart`)**
```dart
class CopyTokens {
  // Commands
  static const String startSession = 'COMMAND: START_SESSION';
  static const String logSet = 'COMMAND: LOG_SET';
  static const String beginRest = 'COMMAND: BEGIN_ENFORCED_REST';
  static const String confirm = 'COMMAND: CONFIRM';
  static const String authenticate = 'COMMAND: AUTHENTICATE';
  static const String accept = 'COMMAND: ACCEPT';
  static const String acknowledge = 'COMMAND: ACKNOWLEDGE';
  static const String retry = 'COMMAND: RETRY';
  static const String continueCommand = 'COMMAND: CONTINUE';
  
  // Status messages
  static const String onTarget = 'STATUS: ON_TARGET';
  static const String belowMandate = 'STATUS: BELOW_MANDATE';
  static const String targetExceeded = 'STATUS: TARGET_EXCEEDED';
  static const String inputInvalid = 'STATUS: INPUT_INVALID';
  static const String accessDenied = 'STATUS: ACCESS_DENIED';
  static const String systemFault = 'STATUS: SYSTEM_FAULT';
  static const String connectionLost = 'STATUS: CONNECTION_LOST';
  static const String syncPending = 'STATUS: SYNC_PENDING';
  
  // Notes
  static const String increaseLoad = 'NOTE: INCREASE_LOAD (+2.5%)';
  static const String decreaseLoad = 'NOTE: DECREASE_LOAD (-7.5%)';
  static const String maintainLoad = 'NOTE: MAINTAIN_LOAD';
  static const String loadComputed = 'NOTE: LOAD_COMPUTED';
  
  // Manifesto text
  static const String manifestoText = '''THIS IS NOT A FITNESS APP.
THIS IS A SYSTEM.
YOU WILL EXECUTE THE 4-6 REP MANDATE.
REST IS ENFORCED.
PROGRESS IS NOT A CHOICE.

TO ENTER: TYPE EXACTLY → I_COMMIT''';
  
  // Error messages
  static const String wrongCommit = 'EXPECTED: I_COMMIT';
  static const String invalidCalibration = 'EXPECTED: 8-12 REPS WITH REASONABLE LOAD';
  static const String networkError = 'SYNC_FAILED. DATA_CACHED_LOCALLY.';
  static const String authError = 'INVALID_CREDENTIALS.';
  
  // Success messages
  static const String setLogged = 'SET_LOGGED';
  static const String sessionComplete = 'SESSION_COMPLETE';
  static const String calibrationComplete = 'CALIBRATION_COMPLETE';
}
```

---

## ⚡ BEST PRACTICES

### **1. Component Reusability**
- Every UI element should be a reusable component
- Components should be stateless when possible
- Use composition over inheritance

### **2. State Management**
- Use Provider for app-wide state
- Keep local state for UI-only concerns
- Separate business logic into services

### **3. File Organization**
- One screen per file
- Group related screens in folders
- Shared components in `components/`
- Business logic in `services/`

### **4. Error Handling**
```dart
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  
  Result.success(this.data) : error = null, isSuccess = true;
  Result.error(this.error) : data = null, isSuccess = false;
}

// Usage in services
Future<Result<Profile>> getProfile() async {
  try {
    final profile = await supabase.from('profiles').select();
    return Result.success(Profile.fromMap(profile));
  } catch (e) {
    return Result.error(e.toString());
  }
}
```

### **5. Validation**
```dart
class InputValidator {
  static String? validateCommit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Your commitment is required';
    }
    if (value.trim().toUpperCase() != 'I_COMMIT') {
      return 'Type exactly: I_COMMIT';
    }
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  static String? validateCalibration(int weight, int reps) {
    if (reps < 8 || reps > 12) {
      return 'Expected: 8-12 reps';
    }
    if (weight < 10 || weight > 300) {
      return 'Weight must be reasonable';
    }
    return null;
  }
}
```

### **6. Weight Calculations**
```dart
class WeightCalculator {
  static double calculateNextWeight(double currentWeight, int actualReps, WeightUnit unit) {
    double multiplier;
    
    if (actualReps <= 3) {
      multiplier = HeavyweightConstants.weightDecreasePercent; // -7.5%
    } else if (actualReps >= 7) {
      multiplier = HeavyweightConstants.weightIncreasePercent; // +2.5%
    } else {
      multiplier = 1.0; // maintain
    }
    
    final newWeight = currentWeight * multiplier;
    return roundToIncrement(newWeight, unit);
  }
  
  static double roundToIncrement(double weight, WeightUnit unit) {
    final increment = unit == WeightUnit.kg 
        ? HeavyweightConstants.kgIncrement 
        : HeavyweightConstants.lbIncrement;
    return (weight / increment).round() * increment;
  }
  
  static double convertWeight(double weight, WeightUnit from, WeightUnit to) {
    if (from == to) return weight;
    
    if (from == WeightUnit.kg && to == WeightUnit.lb) {
      return weight * 2.20462;
    } else if (from == WeightUnit.lb && to == WeightUnit.kg) {
      return weight / 2.20462;
    }
    
    return weight;
  }
}
```

### **7. Analytics**
```dart
class AnalyticsService {
  static Future<void> trackEvent(String event, {Map<String, dynamic>? properties}) async {
    // Only track essential events
    final allowedEvents = [
      'manifesto_committed',
      'calibration_completed',
      'session_completed',
      'paywall_viewed',
      'purchase_started',
      'purchase_succeeded'
    ];
    
    if (!allowedEvents.contains(event)) return;
    
    // Implement with your analytics provider
    print('Analytics: $event ${properties ?? ''}');
  }
}
```

---

## 🚀 IMPLEMENTATION CHECKLIST

### **Phase 1: Foundation (Week 1)**
- [ ] Setup file structure
- [ ] Create theme and constants
- [ ] Build shared components (SystemBanner, CommandButton, etc.)
- [ ] Setup routing with guards
- [ ] Implement basic state management (providers)

### **Phase 2: Onboarding Flow (Week 2)**
- [ ] Splash screen
- [ ] Legal gate
- [ ] Update existing Manifesto screen
- [ ] Build profile input screens (4 screens)
- [ ] Unit selection
- [ ] Unified auth screen
- [ ] Safety disclaimer

### **Phase 3: Calibration & Training (Week 3)**
- [ ] Calibration session screen
- [ ] Calibration complete screen
- [ ] Assignment screen (main home)
- [ ] Session active screen with inline feedback
- [ ] Enforced rest screen
- [ ] Session complete screen
- [ ] Training log screen

### **Phase 4: Settings & Polish (Week 4)**
- [ ] Settings screen with inline editing
- [ ] Subscription status screen
- [ ] Trial progress tracking
- [ ] Paywall screens
- [ ] Error handling screens
- [ ] Final testing and optimization

### **Phase 5: App Store Prep (Week 5)**
- [ ] Data export functionality
- [ ] Subscription integration (RevenueCat)
- [ ] Offline support
- [ ] Analytics integration
- [ ] App store compliance
- [ ] Final QA testing

---

## 🎯 SUCCESS METRICS

After implementation, the app should achieve:
- ✅ **One-tap navigation** between core screens
- ✅ **Zero text inputs** except I_COMMIT and auth
- ✅ **Consistent terminal aesthetic** throughout
- ✅ **Instant set logging** with optimistic UI
- ✅ **Enforced rest periods** with locked UI
- ✅ **Automatic weight adjustments** based on performance
- ✅ **5 free sessions** then paywall
- ✅ **Offline support** for uninterrupted training
- ✅ **Clean, maintainable codebase** following Flutter best practices

---

**READY TO BUILD? This is your complete implementation bible. 🏗️**