import 'package:flutter/material.dart';
import '../../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/radio_selector.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../components/layout/heavyweight_scaffold.dart';
import '../../../core/logging.dart';

class TrainingObjectiveScreen extends StatelessWidget {
  const TrainingObjectiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HWLog.screen('Onboarding/Profile/Objective');
    final state = GoRouterState.of(context);
    final isEditMode = state.uri.queryParameters['edit'] == '1';
    return HeavyweightScaffold(
      title: 'MISSION PARAMETERS',
      showBackButton: isEditMode,
      fallbackRoute: isEditMode ? '/profile' : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          child: Column(
            children: [
              // Back removed for a simpler forward flow
              const SizedBox(height: HeavyweightTheme.spacingSm),
              
              // Header
              Text(
                'SELECT PRIMARY TRAINING DIRECTIVE\nCONFIGURE PROTOCOL OPTIMIZATION',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              
              // DEV navigation removed per product direction
              
              const SizedBox(height: HeavyweightTheme.spacingMd),
              
              // Objective options
              Consumer<ProfileProvider>(
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
                    onChanged: (val) {
                      HWLog.event('profile_objective_select', data: {'value': val.name});
                      provider.setObjective(val);
                    },
                  );
                },
              ),
              
              const SizedBox(height: HeavyweightTheme.spacingXl),
              
              // Continue button
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return CommandButton(
                    text: 'COMMAND: CONFIRM',
                    variant: ButtonVariant.primary,
                    isDisabled: provider.objective == null,
                    onPressed: provider.objective != null
                        ? () async {
                            HWLog.event('profile_objective_continue');
                            // Save training objective to AppState
                            final appState = context.read<AppStateProvider>().appState;
                            await appState.setTrainingObjective(provider.objective!.name);
                            
                            if (!context.mounted) return;
                            if (isEditMode) {
                              context.go('/profile');
                            } else {
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
}
