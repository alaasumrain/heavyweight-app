import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../components/ui/system_banner.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/selector_wheel.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../nav.dart';

class TrainingFrequencyScreen extends StatelessWidget {
  const TrainingFrequencyScreen({Key? key}) : super(key: key);

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
              context.go('/profile/experience');
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
                'FREQUENCY CALIBRATION',
                style: HeavyweightTheme.h3,
              ),
              const SizedBox(height: 10),
              Text(
                'SET PROTOCOL EXECUTION FREQUENCY\nDAYS PER WEEK AVAILABLE FOR TRAINING',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: 60),
              
              // Frequency selector
              Expanded(
                child: Consumer<ProfileProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SelectorWheel(
                          value: provider.frequency ?? 3,
                          min: 3,
                          max: 6,
                          suffix: 'DAYS',
                          onChanged: provider.setFrequency,
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: HeavyweightTheme.secondary.shade800),
                          ),
                          child: Text(
                            _getFrequencyDescription(provider.frequency ?? 3),
                            textAlign: TextAlign.center,
                            style: HeavyweightTheme.bodyMedium,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              // Continue button
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return CommandButton(
                    text: 'SET_FREQUENCY',
                    variant: ButtonVariant.primary,
                    isDisabled: provider.frequency == null,
                    onPressed: provider.frequency != null
                        ? () async {
                            // Mark frequency as set in AppState
                            final appState = context.read<AppStateProvider>().appState;
                            await appState.setFrequency(provider.frequency.toString());
                            
                            if (context.mounted) {
                              context.go('/profile/units');
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
  
  String _getFrequencyDescription(int days) {
    switch (days) {
      case 3:
        return 'MINIMUM EFFECTIVE PROTOCOL\nFull-body execution pattern';
      case 4:
        return 'OPTIMAL CONFIGURATION\nUpper/lower protocol split';
      case 5:
        return 'HIGH INTENSITY SCHEDULE\nSpecialized protocol focus';
      case 6:
        return 'MAXIMUM SUSTAINABLE LOAD\nAdvanced recovery required';
      default:
        return '';
    }
  }
}