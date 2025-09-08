// ignore_for_file: unrelated_type_equality_checks



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '/providers/app_state_provider.dart';


import '/components/navigation/navigation_shell.dart';
import '/screens/onboarding/legal_gate_screen.dart';
import '/screens/profile/profile_screen.dart';
import '/screens/onboarding/profile/training_experience_screen.dart';
import '/screens/onboarding/profile/training_frequency_screen.dart';
import '/screens/onboarding/profile/unit_preference_screen.dart';
import '/screens/onboarding/profile/physical_stats_screen.dart';
import '/screens/onboarding/profile/training_objective_screen.dart';
import '/screens/onboarding/auth_screen.dart';
import '/screens/training/assignment_screen.dart';
import '/screens/training/session_active_screen.dart';
import '/screens/training/enforced_rest_screen.dart';
import '/screens/training/training_log_screen.dart';
import '/screens/training/exercise_intel_screen.dart';
import '/screens/training/session_detail_screen.dart';
import '/fortress/engine/models/set_data.dart';
import '/screens/settings/settings_main_screen.dart';
import '/screens/paywall/paywall_screen.dart';
import '/screens/paywall/subscription_plans_screen.dart';
import '/screens/error/error_screen.dart';
import '/fortress/manifesto/manifesto_screen.dart';
import '/fortress/daily_workout/daily_workout_screen.dart';
import '/fortress/protocol/protocol_screen.dart';
import '/fortress/session_complete/session_complete_screen.dart';
import '/fortress/engine/workout_engine.dart';
import '/core/page_transitions.dart';
import '/core/error_handler.dart';
import '/components/navigation/swipeable_screen.dart';



class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();
  
  String? _previousRoute;
  String? get previousRoute => _previousRoute;
  
  void updateRoute(String route) {
    _previousRoute = route;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/', 
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      errorBuilder: (context, state) => ErrorScreen(
        error: state.error,
        retryRoute: '/',
      ),
      redirect: (context, state) {
        // Only protect training routes that require authentication
        final protectedRoutes = ['/assignment', '/session-active', '/training-log'];
        final currentPath = state.matchedLocation;
        
        if (protectedRoutes.any((route) => currentPath.startsWith(route))) {
          try {
            final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
            if (appStateProvider.isInitialized && !appStateProvider.appState.isAuthenticated) {
              return '/auth';
            }
          } catch (e) {
            // If provider not available, let it through (will be handled by NavigationShell)
          }
        }
        
        return null; // Let everything else through
      },
      routes: [
        GoRoute(
          name: 'splash',
          path: '/',
          builder: (context, state) => const NavigationShell(),
        ),
        GoRoute(
          name: 'legal',
          path: '/legal',
          builder: (context, state) => const LegalGateScreen(),
        ),
        GoRoute(
          name: 'manifesto',
          path: '/manifesto',
          builder: (context, state) => const ManifestoScreen(),
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          name: 'profile_experience',
          path: '/profile/experience',
          builder: (context, state) => const TrainingExperienceScreen(),
        ),
        GoRoute(
          name: 'profile_frequency',
          path: '/profile/frequency',
          builder: (context, state) => const TrainingFrequencyScreen(),
        ),
        GoRoute(
          name: 'profile_units',
          path: '/profile/units',
          builder: (context, state) => const UnitPreferenceScreen(),
        ),
        GoRoute(
          name: 'profile_stats',
          path: '/profile/stats',
          builder: (context, state) => const PhysicalStatsScreen(),
        ),
        GoRoute(
          name: 'profile_objective',
          path: '/profile/objective',
          builder: (context, state) => const TrainingObjectiveScreen(),
        ),
        GoRoute(
          name: 'auth',
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          name: 'assignment',
          path: '/assignment',
          pageBuilder: (context, state) {
            final fromIndex = NavigationHelper.getRouteIndex(appStateNotifier.previousRoute ?? '');
            final toIndex = NavigationHelper.getRouteIndex('/assignment');
            appStateNotifier.updateRoute('/assignment');
            
            final swipeRoutes = SwipeNavigation.getRoutes('/assignment');
            final screen = SwipeableScreen(
              previousRoute: swipeRoutes?.previous,
              nextRoute: swipeRoutes?.next,
              child: ErrorBoundary(
                child: AssignmentScreen.withProvider(),
              ),
            );
            
            return HeavyweightPageTransitions.slideTransition(
              context,
              state,
              screen,
              fromIndex: fromIndex,
              toIndex: toIndex,
            );
          },
        ),
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
          builder: (context, state) => DailyWorkoutScreen.withProvider(),
        ),
        GoRoute(
          name: 'protocol',
          path: '/protocol',
          builder: (context, state) {
            final workout = state.extra as DailyWorkout?;
            return ProtocolScreen(workout: workout);
          },
        ),
        GoRoute(
          name: 'session_complete',
          path: '/session-complete',
          builder: (context, state) {
            final sessionData = state.extra as Map<String, dynamic>?;
            if (sessionData != null) {
              return SessionCompleteScreen.withProvider(
                sessionSets: sessionData['sessionSets'] as List<SetData>,
                mandateSatisfied: sessionData['mandateSatisfied'] as bool,
              );
            }
            // Fallback to empty session
            return SessionCompleteScreen.withProvider(
              sessionSets: const [],
              mandateSatisfied: false,
            );
          },
        ),
        GoRoute(
          name: 'training_log',
          path: '/training-log',
          pageBuilder: (context, state) {
            final fromIndex = NavigationHelper.getRouteIndex(appStateNotifier.previousRoute ?? '');
            final toIndex = NavigationHelper.getRouteIndex('/training-log');
            appStateNotifier.updateRoute('/training-log');
            
            final swipeRoutes = SwipeNavigation.getRoutes('/training-log');
            final screen = SwipeableScreen(
              previousRoute: swipeRoutes?.previous,
              nextRoute: swipeRoutes?.next,
              child: ErrorBoundary(
                child: TrainingLogScreen.withProvider(),
              ),
            );
            
            return HeavyweightPageTransitions.slideTransition(
              context,
              state,
              screen,
              fromIndex: fromIndex,
              toIndex: toIndex,
            );
          },
        ),
        GoRoute(
          name: 'settings',
          path: '/settings',
          pageBuilder: (context, state) {
            final fromIndex = NavigationHelper.getRouteIndex(appStateNotifier.previousRoute ?? '');
            final toIndex = NavigationHelper.getRouteIndex('/settings');
            appStateNotifier.updateRoute('/settings');
            
            final swipeRoutes = SwipeNavigation.getRoutes('/settings');
            final screen = SwipeableScreen(
              previousRoute: swipeRoutes?.previous,
              nextRoute: swipeRoutes?.next,
              child: ErrorBoundary(
                child: const SettingsMainScreen(),
              ),
            );
            
            return HeavyweightPageTransitions.slideTransition(
              context,
              state,
              screen,
              fromIndex: fromIndex,
              toIndex: toIndex,
            );
          },
        ),
        GoRoute(
          name: 'exercise_intel',
          path: '/exercise-intel',
          builder: (context, state) {
            final params = state.extra as Map<String, String>?;
            return ExerciseIntelScreen(
              exerciseId: params?['exerciseId'] ?? 'unknown',
              exerciseName: params?['exerciseName'] ?? 'Unknown Exercise',
            );
          },
        ),
        GoRoute(
          name: 'session_detail',
          path: '/session-detail',
          builder: (context, state) {
            final session = state.extra as WorkoutSession?;
            if (session == null) {
              return const ErrorScreen(
                errorMessage: 'SESSION_NOT_FOUND',
                retryRoute: '/training-log',
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
              retryRoute: '/assignment',
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
