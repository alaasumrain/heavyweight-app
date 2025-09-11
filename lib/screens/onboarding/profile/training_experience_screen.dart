import 'package:flutter/material.dart';
import '../../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/radio_selector.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../nav.dart';
import '../../../components/layout/heavyweight_scaffold.dart';
import '../../../core/logging.dart';

class TrainingExperienceScreen extends StatelessWidget {
  const TrainingExperienceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HWLog.screen('Onboarding/Profile/Experience');
    // Determine if we're in profile editing mode (not onboarding)
    final isEditMode = GoRouterState.of(context).matchedLocation.contains('/profile/');
    
    return HeavyweightScaffold(
      title: 'SYSTEM CALIBRATION',
      showBackButton: isEditMode,
      fallbackRoute: '/manifesto',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          child: Column(
            children: [
              // Header with proper spacing
              Text(
                'CALIBRATING LOAD PARAMETERS\nSELECT TRAINING PROTOCOL EXPERIENCE LEVEL',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: HeavyweightTheme.spacingLg),
              
              // Experience options
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return RadioSelector<ExperienceLevel>(
                      options: const [
                        RadioOption(
                          value: ExperienceLevel.beginner,
                          label: 'NOVICE OPERATOR - Establishing base protocols',
                        ),
                        RadioOption(
                          value: ExperienceLevel.intermediate,
                          label: 'TRAINED OPERATOR - 1-3 years system experience',
                        ),
                        RadioOption(
                          value: ExperienceLevel.advanced,
                          label: 'VETERAN OPERATOR - Advanced protocol execution',
                        ),
                      ],
                      selectedValue: provider.experience,
                      onChanged: (val) {
                        HWLog.event('profile_experience_select', data: {'value': val.name});
                        provider.setExperience(val);
                      },
                    );
                },
              ),
              
              const SizedBox(height: HeavyweightTheme.spacingXl),
              
              // Continue button
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return CommandButton(
                    text: 'CONTINUE',
                    variant: ButtonVariant.primary,
                    isDisabled: provider.experience == null,
                    onPressed: provider.experience != null
                        ? () async {
                          HWLog.event('profile_experience_continue');
                          // Mark experience as set in AppState
                            final appState = context.read<AppStateProvider>().appState;
                            await appState.setExperience(provider.experience!.name);
                            
                            if (context.mounted) {
                              context.go('/profile/frequency');
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
