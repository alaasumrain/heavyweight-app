import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../screens/onboarding/splash_screen.dart';
import '../../screens/onboarding/legal_gate_screen.dart';
import '../../screens/onboarding/manifesto_screen.dart';
import '../../screens/onboarding/profile/training_experience_screen.dart';
import '../../screens/onboarding/profile/training_frequency_screen.dart';
import '../../screens/onboarding/profile/unit_preference_screen.dart';
import '../../screens/onboarding/profile/physical_stats_screen.dart';
import '../../screens/onboarding/profile/training_objective_screen.dart';
import '../../screens/onboarding/auth_screen.dart';
import 'main_app_shell.dart';
import '../../core/logging.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🌊🌊🌊 NAVIGATION SHELL BUILD() CALLED - SIMPLIFIED VERSION');
    debugPrint('🌊🌊🌊 NAV SHELL: NavigationShell should never be shown - Router should redirect');
    
    // NavigationShell is now only used as a fallback if routing fails
    // The router should handle all navigation decisions via redirects
    return Container(
      color: Colors.red,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'NAVIGATION ERROR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'NavigationShell should not be displayed.\nRouter redirects should handle navigation.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
