// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import '/providers/app_state_provider.dart';

import '/components/navigation/main_app_shell.dart';
import '/components/layout/heavyweight_scaffold.dart';
import '/screens/onboarding/splash_screen.dart';
import '/screens/onboarding/legal_gate_screen.dart';
import '/screens/profile/profile_screen.dart';
import '/screens/onboarding/profile/training_experience_screen.dart';
import '/screens/onboarding/profile/training_frequency_screen.dart';
import '/screens/onboarding/profile/unit_preference_screen.dart';
import '/screens/onboarding/profile/physical_stats_screen.dart';
import '/screens/onboarding/profile/training_objective_screen.dart';
import '/screens/onboarding/profile/starting_day_screen.dart';
import '/screens/onboarding/profile/baseline_strength_screen.dart';
import '/screens/onboarding/profile/rest_days_screen.dart';
import '/screens/onboarding/profile/session_duration_screen.dart';
import '/screens/onboarding/auth_screen.dart';
import '/screens/training/session_active_screen.dart';
import '/screens/training/enforced_rest_screen.dart';
import '/screens/training/exercise_intel_screen.dart';
import '/screens/training/session_detail_screen.dart';
import '/fortress/engine/models/set_data.dart';
import '/screens/paywall/paywall_screen.dart';
import '/screens/paywall/subscription_plans_screen.dart';
import '/screens/error/error_screen.dart';
import '/screens/onboarding/manifesto_screen.dart';
import '/screens/onboarding/terms_privacy_screen.dart';
import '/screens/training/daily_workout_screen.dart';
import '/screens/training/protocol_screen.dart';
import '/screens/training/session_complete_screen.dart';
import '/screens/dev/config_screen.dart';
import '/screens/dev/screen_index.dart';
import '/core/routes.dart';
import '/screens/dev/status_screen.dart';
import '/fortress/engine/workout_engine.dart';
import '/core/page_transitions.dart';
import '/core/error_handler.dart';
import '/core/logging.dart';
import '/core/nav_logging.dart';
import '/core/route_observer.dart';
import '/core/theme/heavyweight_theme.dart';

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  String? _previousRoute;
  static bool _splashShown = false;
  String? get previousRoute => _previousRoute;

  static void setSplashShown(bool value) {
    _splashShown = value;
  }

  void updateRoute(String route) {
    _previousRoute = route;
    // Avoid notifying listeners during the router's build phase.
    // Schedule the notification after the current frame to prevent
    // "setState() or markNeedsBuild() called during build" errors.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle ||
        SchedulerBinding.instance.schedulerPhase ==
            SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}

GoRouter createRouter(
  AppStateNotifier appStateNotifier, {
  required Listenable refresh,
  String initialLocation = '/',
}) {
  debugPrint('🧭 createRouter(): initialLocation=$initialLocation');
  // Ensure screen registry has entries
  registerScreens();
  return GoRouter(
    // Diagnostic line to verify initial location
    // (go_router will also log initial location later)
    initialLocation: initialLocation,
    debugLogDiagnostics: false,
    navigatorKey: NavLogging.navigatorKey,
    observers: [HWRouteObserver()],
    refreshListenable: refresh,
    redirectLimit: 10,
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error,
      retryRoute: '/',
    ),
    redirect: (context, state) {
      // Only handle legacy redirects at top level
      final currentPath = state.matchedLocation;
      if (currentPath == '/assignment') return '/app?tab=0';
      if (currentPath == '/training-log') return '/app?tab=1';
      if (currentPath == '/settings') return '/app?tab=2';
      return null;
    },
    routes: [
      GoRoute(
        name: 'root',
        path: '/',
        redirect: (context, state) {
          debugPrint('🔀🔀🔀 ROOT REDIRECT DISPATCHER CALLED');
          try {
            // Always show splash screen first on app startup
            if (!AppStateNotifier._splashShown) {
              debugPrint(
                  '🔀🔀🔀 ROOT: Splash not shown yet, redirecting to splash');
              return '/splash';
            }

            final appStateProvider =
                Provider.of<AppStateProvider>(context, listen: false);
            if (!appStateProvider.isInitialized) {
              debugPrint(
                  '🔀🔀🔀 ROOT: App not initialized, redirecting to splash');
              return '/splash';
            }

            final appState = appStateProvider.appState;
            debugPrint('🔀🔀🔀 ROOT: App initialized, using nextRoute');
            final next = appState.nextRoute;
            debugPrint('🔀🔀🔀 ROOT: nextRoute => $next');
            return next;
          } catch (e) {
            debugPrint(
                '🔀🔀🔀 ROOT: Error in redirect, falling back to splash: $e');
            return '/splash';
          }
        },
        // NO BUILDER - redirect only
      ),

      // Dedicated splash screen route
      GoRoute(
        name: 'splash',
        path: '/splash',
        redirect: (context, state) {
          debugPrint('💫💫💫 SPLASH REDIRECT DISPATCHER CALLED');
          try {
            if (!AppStateNotifier._splashShown) {
              debugPrint('💫💫💫 SPLASH: first show -> stay');
              return null; // show splash once
            }
            final appStateProvider =
                Provider.of<AppStateProvider>(context, listen: false);
            if (!appStateProvider.isInitialized) {
              debugPrint('💫💫💫 SPLASH: app not initialized -> stay');
              return null;
            }
            final next = appStateProvider.appState.nextRoute;
            debugPrint('💫💫💫 SPLASH: redirecting to $next');
            return next;
          } catch (e) {
            debugPrint('💫💫💫 SPLASH: redirect error: $e');
            return null;
          }
        },
        builder: (context, state) => const SplashScreen(),
      ),

      // Unified app shell with tabs controlled via query param `tab`
      GoRoute(
        name: 'app_shell',
        path: '/app',
        pageBuilder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialIndex = int.tryParse(tabStr ?? '0') ?? 0;
          appStateNotifier.updateRoute('/app');
          return HeavyweightPageTransitions.fadeTransition(
            context,
            state,
            ErrorBoundary(
              child: MainAppShell(
                  key: ValueKey('app_shell_$initialIndex'),
                  initialIndex: initialIndex),
            ),
          );
        },
      ),
      GoRoute(
        name: 'legal',
        path: '/legal',
        builder: (context, state) => const LegalGateScreen(),
      ),
      GoRoute(
        name: 'terms_privacy',
        path: '/legal/terms',
        builder: (context, state) => const TermsPrivacyScreen(),
      ),
      GoRoute(
        name: 'manifesto',
        path: '/manifesto',
        builder: (context, state) => const ManifestoScreen(),
      ),
      GoRoute(
        name: 'profile',
        path: '/profile',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideUpTransition(
          context,
          state,
          const ProfileScreen(),
        ),
      ),
      GoRoute(
        name: 'profile_experience',
        path: '/profile/experience',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideHorizontalTransition(
          context,
          state,
          const TrainingExperienceScreen(),
        ),
      ),
      GoRoute(
        name: 'profile_frequency',
        path: '/profile/frequency',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideHorizontalTransition(
          context,
          state,
          const TrainingFrequencyScreen(),
        ),
      ),
      GoRoute(
        name: 'profile_units',
        path: '/profile/units',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideHorizontalTransition(
          context,
          state,
          const UnitPreferenceScreen(),
        ),
      ),
      GoRoute(
        name: 'profile_stats',
        path: '/profile/stats',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideHorizontalTransition(
          context,
          state,
          const PhysicalStatsScreen(),
        ),
      ),
      GoRoute(
        name: 'profile_objective',
        path: '/profile/objective',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideHorizontalTransition(
          context,
          state,
          const TrainingObjectiveScreen(),
        ),
      ),
      GoRoute(
        name: 'profile_starting_day',
        path: '/profile/starting-day',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideHorizontalTransition(
          context,
          state,
          const StartingDayScreen(),
        ),
      ),
      GoRoute(
        name: 'profile_rest_days',
        path: '/profile/rest-days',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideHorizontalTransition(
          context,
          state,
          const RestDaysScreen(),
        ),
      ),
      GoRoute(
        name: 'profile_duration',
        path: '/profile/duration',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideHorizontalTransition(
          context,
          state,
          const SessionDurationScreen(),
        ),
      ),
      GoRoute(
        name: 'profile_baseline',
        path: '/profile/baseline',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideHorizontalTransition(
          context,
          state,
          const BaselineStrengthScreen(),
        ),
      ),
      GoRoute(
        name: 'auth',
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      // legacy tab routes are redirected in `redirect`
      GoRoute(
        name: 'session_active',
        path: '/session-active',
        builder: (context, state) => const SessionActiveScreen(),
      ),
      GoRoute(
        name: 'enforced_rest',
        path: '/enforced-rest',
        builder: (context, state) => const EnforcedRestScreen(),
      ),
      GoRoute(
        name: 'daily_workout',
        path: '/daily-workout',
        pageBuilder: (context, state) =>
            HeavyweightPageTransitions.slideUpTransition(
          context,
          state,
          ErrorBoundary(
            child: DailyWorkoutScreen.withProvider(),
          ),
        ),
      ),
      GoRoute(
        name: 'protocol',
        path: '/protocol',
        pageBuilder: (context, state) {
          final extra = state.extra;
          DailyWorkout? workout;
          if (extra is DailyWorkout) {
            workout = extra;
          } else if (extra is Map) {
            try {
              final map = extra is Map<String, dynamic>
                  ? extra
                  : Map<String, dynamic>.from(extra);
              if (map.containsKey('dayName') && map.containsKey('exercises')) {
                workout = DailyWorkout.fromJson(map);
              } else if (map['workout'] is Map<String, dynamic>) {
                workout = DailyWorkout.fromJson(
                    map['workout'] as Map<String, dynamic>);
              }
            } catch (e) {
              HWLog.event('daily_workout_json_parse_failed', data: {
                'error': e.toString(),
                'type': extra.runtimeType.toString(),
              });
            }
          } else if (extra != null) {
            try {
              final dynamic dynExtra = extra;
              final dynamic maybeWorkout = dynExtra.workout;
              if (maybeWorkout is DailyWorkout) {
                workout = maybeWorkout;
              }
            } catch (_) {
              // Ignore - handled by mismatch log
            }
          }
          if (workout == null) {
            return HeavyweightPageTransitions.slideUpTransition(
              context,
              state,
              HeavyweightScaffold(
                title: 'TRAINING',
                showBackButton: true,
                fallbackRoute: '/app?tab=0',
                body: const Center(
                  child: Text(
                    'ROUTE DATA INVALID · RETURNING TO ASSIGNMENT',
                    style: TextStyle(color: HeavyweightTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          return HeavyweightPageTransitions.slideUpTransition(
            context,
            state,
            ErrorBoundary(
              child: ProtocolScreen(workout: workout),
            ),
          );
        },
      ),
      GoRoute(
        name: 'session_complete',
        path: '/session-complete',
        pageBuilder: (context, state) {
          final extra = state.extra;
          Widget screen;
          if (extra is Map<String, dynamic>) {
            final sets = extra['sessionSets'];
            final okSets = sets is List<SetData> ? sets : const <SetData>[];
            final okFlag = extra['mandateSatisfied'] is bool
                ? extra['mandateSatisfied'] as bool
                : false;
            screen = SessionCompleteScreen.withProvider(
              sessionSets: okSets,
              mandateSatisfied: okFlag,
            );
          } else {
            // Fallback to empty session
            screen = SessionCompleteScreen.withProvider(
              sessionSets: const [],
              mandateSatisfied: false,
            );
          }
          return HeavyweightPageTransitions.fadeTransition(
            context,
            state,
            ErrorBoundary(
              child: screen,
            ),
          );
        },
      ),
      // other content routes remain
      GoRoute(
        name: 'exercise_intel',
        path: '/exercise-intel',
        builder: (context, state) {
          final extra = state.extra;
          String exerciseId = 'unknown';
          String exerciseName = 'Unknown Exercise';

          if (extra is Map) {
            final idValue = extra['exerciseId'];
            final nameValue = extra['exerciseName'];
            if (idValue is String && idValue.isNotEmpty) {
              exerciseId = idValue;
            }
            if (nameValue is String && nameValue.isNotEmpty) {
              exerciseName = nameValue;
            }
          }

          return ExerciseIntelScreen(
            exerciseId: exerciseId,
            exerciseName: exerciseName,
          );
        },
      ),
      // Hidden dev route: Effective config panel
      GoRoute(
        name: 'dev_config',
        path: '/dev/config',
        builder: (context, state) => const DevConfigScreen(),
      ),
      // Hidden dev route: Screen index
      GoRoute(
        name: 'dev_screens',
        path: '/dev/screens',
        builder: (context, state) => const ScreenIndex(),
      ),
      // Hidden dev route: Status flags
      GoRoute(
        name: 'dev_status',
        path: '/dev/status',
        builder: (context, state) => const DevStatusScreen(),
      ),
      GoRoute(
        name: 'session_detail',
        path: '/session-detail',
        builder: (context, state) {
          final session = state.extra as WorkoutSession?;
          if (session == null) {
            return const ErrorScreen(
              errorMessage: 'SESSION_NOT_FOUND',
              retryRoute: '/app?tab=1',
            );
          }
          return ErrorBoundary(
            child: SessionDetailScreen(session: session),
          );
        },
      ),

      // Paywall routes
      GoRoute(
        name: 'paywall',
        path: '/paywall',
        builder: (context, state) => ErrorBoundary(
          child: const PaywallScreen(),
        ),
      ),
      GoRoute(
        name: 'subscription_plans',
        path: '/subscription-plans',
        builder: (context, state) => ErrorBoundary(
          child: const SubscriptionPlansScreen(),
        ),
      ),

      // Error routes
      GoRoute(
        name: 'error',
        path: '/error',
        builder: (context, state) {
          final error = state.extra;
          return ErrorScreen(
            error: error,
            retryRoute: '/app?tab=0',
          );
        },
      ),
      GoRoute(
        name: 'network_error',
        path: '/network-error',
        builder: (context, state) => const NetworkErrorScreen(),
      ),
      GoRoute(
        name: 'auth_error',
        path: '/auth-error',
        builder: (context, state) => const AuthErrorScreen(),
      ),
    ],
  );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}
