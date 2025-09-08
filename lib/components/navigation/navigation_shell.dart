import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../screens/onboarding/splash_screen.dart';
import '../../screens/onboarding/legal_gate_screen.dart';
import '../../fortress/manifesto/manifesto_screen.dart';
import '../../screens/onboarding/profile/training_experience_screen.dart';
import '../../screens/onboarding/profile/training_frequency_screen.dart';
import '../../screens/onboarding/profile/unit_preference_screen.dart';
import '../../screens/onboarding/profile/physical_stats_screen.dart';
import '../../screens/onboarding/profile/training_objective_screen.dart';
import '../../screens/onboarding/auth_screen.dart';
import '../../screens/training/assignment_screen.dart';
import 'main_app_shell.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, provider, child) {
        // Show splash while initializing
        if (!provider.isInitialized) {
          return const SplashScreen();
        }

        final appState = provider.appState;

        // Show screens based on completion state
        if (!appState.legalAccepted) {
          return const LegalGateScreen();
        }
        
        if (!appState.manifestoCommitted) {
          return const ManifestoScreen();
        }
        
        if (appState.trainingExperience == null) {
          return const TrainingExperienceScreen();
        }
        
        if (appState.trainingFrequency == null) {
          return const TrainingFrequencyScreen();
        }
        
        if (appState.unitPreference == null) {
          return const UnitPreferenceScreen();
        }
        
        if (appState.physicalStats == null) {
          return const PhysicalStatsScreen();
        }
        
        if (appState.trainingObjective == null) {
          return const TrainingObjectiveScreen();
        }
        
        if (!appState.isAuthenticated) {
          return const AuthScreen();
        }

        // All onboarding complete - show main app
        return const MainAppShell();
      },
    );
  }
}