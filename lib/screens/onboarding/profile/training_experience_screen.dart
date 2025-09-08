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

class TrainingExperienceScreen extends StatelessWidget {
  const TrainingExperienceScreen({Key? key}) : super(key: key);

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
              context.go('/manifesto');
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
                'SYSTEM CALIBRATION',
                style: HeavyweightTheme.h3,
              ),
              const SizedBox(height: 10),
              Text(
                'CALIBRATING LOAD PARAMETERS\nSELECT TRAINING PROTOCOL EXPERIENCE LEVEL',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              
              // Experience options
              Expanded(
                child: Consumer<ProfileProvider>(
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
                      onChanged: provider.setExperience,
                    );
                  },
                ),
              ),
              
              // Continue button
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return CommandButton(
                    text: 'CALIBRATE',
                    variant: ButtonVariant.primary,
                    isDisabled: provider.experience == null,
                    onPressed: provider.experience != null
                        ? () async {
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