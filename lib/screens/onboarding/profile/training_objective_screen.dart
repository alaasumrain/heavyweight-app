import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../components/ui/system_banner.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/radio_selector.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../nav.dart';

class TrainingObjectiveScreen extends StatelessWidget {
  const TrainingObjectiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if we're in profile editing mode (not onboarding)
    final isEditMode = GoRouterState.of(context).matchedLocation.contains('/profile/');
    
    return Scaffold(
      backgroundColor: HeavyweightTheme.background,
      appBar: AppBar(
        backgroundColor: HeavyweightTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HeavyweightTheme.primary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/profile/stats');
            }
          },
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SystemBanner(),
              const SizedBox(height: 40),
              
              // Header
              Text(
                'MISSION PARAMETERS',
                style: HeavyweightTheme.h3,
              ),
              const SizedBox(height: 10),
              Text(
                'SELECT PRIMARY TRAINING DIRECTIVE\nCONFIGURE PROTOCOL OPTIMIZATION',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              
              // DEV: Quick navigation buttons
              if (true) // Set to false to hide in production
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellow.shade700),
                    color: Colors.yellow.shade900.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'DEV NAVIGATION',
                        style: HeavyweightTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _devButton(context, 'EXPERIENCE', '/profile'),
                          _devButton(context, 'FREQUENCY', '/profile/frequency'),
                          _devButton(context, 'STATS', '/profile/stats'),
                          _devButton(context, 'ASSIGNMENT', '/assignment'),
                        ],
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Objective options
              Expanded(
                child: Consumer<ProfileProvider>(
                  builder: (context, provider, child) {
                    return RadioSelector<TrainingObjective>(
                      options: const [
                        RadioOption(
                          value: TrainingObjective.strength,
                          label: 'STRENGTH PROTOCOL - Maximum force development',
                        ),
                        RadioOption(
                          value: TrainingObjective.size,
                          label: 'HYPERTROPHY PROTOCOL - Muscle mass optimization',
                        ),
                        RadioOption(
                          value: TrainingObjective.endurance,
                          label: 'ENDURANCE PROTOCOL - Work capacity enhancement',
                        ),
                        RadioOption(
                          value: TrainingObjective.general,
                          label: 'GENERAL PROTOCOL - Comprehensive conditioning',
                        ),
                      ],
                      selectedValue: provider.objective,
                      onChanged: provider.setObjective,
                    );
                  },
                ),
              ),
              
              // Continue button
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return CommandButton(
                    text: 'LOCK_PARAMETERS',
                    variant: ButtonVariant.primary,
                    isDisabled: provider.objective == null,
                    onPressed: provider.objective != null
                        ? () async {
                            // Save training objective to AppState
                            final appState = context.read<AppStateProvider>().appState;
                            await appState.setTrainingObjective(provider.objective!.name);
                            
                            if (context.mounted) {
                              // Let the centralized flow controller decide where to go next
                              final nextRoute = appState.nextRoute;
                              context.go(nextRoute);
                            }
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _devButton(BuildContext context, String label, String route) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow.shade700),
          color: Colors.yellow.shade800.withOpacity(0.2),
        ),
        child: Text(
          label,
          style: HeavyweightTheme.bodyMedium,
        ),
      ),
    );
  }
}