// ignore_for_file: unrelated_type_equality_checks



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '/providers/app_state_provider.dart';


import '/screens/onboarding/splash_screen.dart';
import '/screens/onboarding/legal_gate_screen.dart';
import '/screens/onboarding/philosophy_screen.dart';
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
import '/screens/settings/settings_main_screen.dart';
import '/fortress/manifesto/manifesto_screen.dart';
import '/fortress/mandate/mandate_screen.dart';
import '/fortress/protocol/protocol_screen.dart';
import '/fortress/session_complete/session_complete_screen.dart';
import '/fortress/engine/mandate_engine.dart';



class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/', 
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      errorBuilder: (context, state) => const SplashScreen(),
      redirect: (context, state) {
        // Wait for AppState to be initialized
        try {
          final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
          if (!appStateProvider.isInitialized) {
            return null; // Show splash while loading
          }
          
          // Get redirect from AppState
          return appStateProvider.appState.getRedirectRoute(state.matchedLocation);
        } catch (e) {
          // If provider not available, continue to splash
          return null;
        }
      },
      routes: [
        GoRoute(
          name: '_initialize',
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          name: 'legal',
          path: '/legal',
          builder: (context, state) => const LegalGateScreen(),
        ),
        GoRoute(
          name: 'philosophy',
          path: '/philosophy',
          builder: (context, state) => const PhilosophyScreen(),
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
          builder: (context, state) => const AssignmentScreen(),
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
          name: 'mandate',
          path: '/mandate',
          builder: (context, state) => MandateScreen.withProvider(),
        ),
        GoRoute(
          name: 'protocol',
          path: '/protocol',
          builder: (context, state) {
            final mandate = state.extra as WorkoutMandate?;
            return ProtocolScreen(mandate: mandate);
          },
        ),
        GoRoute(
          name: 'session_complete',
          path: '/session-complete',
          builder: (context, state) {
            final sessionData = state.extra as Map<String, dynamic>?;
            if (sessionData != null) {
              return SessionCompleteScreen(
                sessionSets: sessionData['sessionSets'] as List<SetData>,
                mandateSatisfied: sessionData['mandateSatisfied'] as bool,
              );
            }
            // Fallback to empty session
            return const SessionCompleteScreen(
              sessionSets: [],
              mandateSatisfied: false,
            );
          },
        ),
        GoRoute(
          name: 'training_log',
          path: '/training-log',
          builder: (context, state) => const TrainingLogScreen(),
        ),
        GoRoute(
          name: 'settings',
          path: '/settings',
          builder: (context, state) => const SettingsMainScreen(),
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
