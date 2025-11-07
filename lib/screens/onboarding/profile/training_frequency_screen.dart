import 'package:flutter/material.dart';
import '../../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/selector_wheel.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../components/layout/heavyweight_scaffold.dart';
import '../../../core/logging.dart';

class TrainingFrequencyScreen extends StatefulWidget {
  const TrainingFrequencyScreen({super.key});

  @override
  State<TrainingFrequencyScreen> createState() =>
      _TrainingFrequencyScreenState();
}

class _TrainingFrequencyScreenState extends State<TrainingFrequencyScreen> {
  @override
  void initState() {
    super.initState();
    HWLog.screen('Onboarding/Profile/Frequency');
    // Ensure default selection so the CTA is enabled immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      provider.setFrequency(provider.frequency ?? 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final isEditMode = state.uri.queryParameters['edit'] == '1';

    return HeavyweightScaffold(
      title: 'FREQUENCY CALIBRATION',
      showBackButton: isEditMode,
      fallbackRoute: isEditMode ? '/profile' : '/profile/experience',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          child: Column(
            children: [
              // Header
              Text(
                'SET PROTOCOL EXECUTION FREQUENCY\nDAYS PER WEEK AVAILABLE FOR TRAINING',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: HeavyweightTheme.spacingXl),

              // Frequency selector
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      SelectorWheel(
                        value: provider.frequency ?? 3,
                        min: 3,
                        max: 6,
                        suffix: 'DAYS',
                        onChanged: (v) {
                          HWLog.event('profile_frequency_select',
                              data: {'value': v});
                          provider.setFrequency(v);
                        },
                      ),
                      const SizedBox(height: HeavyweightTheme.spacingXl),
                      Container(
                        padding:
                            const EdgeInsets.all(HeavyweightTheme.spacingMd),
                        decoration: BoxDecoration(
                          border: Border.all(color: HeavyweightTheme.secondary),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'FREQUENCY: ${(provider.frequency ?? 3)}_DAYS',
                              style: HeavyweightTheme.labelMedium,
                            ),
                            const SizedBox(height: HeavyweightTheme.spacingSm),
                            Text(
                              _getFrequencyDescription(provider.frequency ?? 3),
                              textAlign: TextAlign.center,
                              style: HeavyweightTheme.bodySmall.copyWith(
                                  color: HeavyweightTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    isDisabled: provider.frequency == null,
                    onPressed: provider.frequency != null
                        ? () async {
                            HWLog.event('profile_frequency_continue');
                            // Mark frequency as set in AppState
                            final appState =
                                context.read<AppStateProvider>().appState;
                            await appState
                                .setFrequency(provider.frequency.toString());

                            if (!context.mounted) return;
                            if (isEditMode) {
                              context.pop();
                            } else {
                              // After frequency, next step is rest days
                              HWLog.event(
                                  'profile_frequency_navigate_to_rest_days');
                              GoRouter.of(context).go('/profile/rest-days');
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
