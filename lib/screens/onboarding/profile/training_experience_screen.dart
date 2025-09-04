import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../components/ui/system_banner.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/radio_selector.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/app_state_provider.dart';

class TrainingExperienceScreen extends StatelessWidget {
  const TrainingExperienceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if we're in profile editing mode (not onboarding)
    final isEditMode = GoRouterState.of(context).matchedLocation.contains('/profile/');
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isEditMode ? AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ) : null,
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
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'CALIBRATING LOAD PARAMETERS\nSELECT TRAINING PROTOCOL EXPERIENCE LEVEL',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  height: 1.5,
                  letterSpacing: 1,
                ),
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