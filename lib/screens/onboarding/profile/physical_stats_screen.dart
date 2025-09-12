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

class PhysicalStatsScreen extends StatelessWidget {
  const PhysicalStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HWLog.screen('Onboarding/Profile/PhysicalStats');
    final state = GoRouterState.of(context);
    final isEditMode = state.uri.queryParameters['edit'] == '1';
    return HeavyweightScaffold(
      title: 'OPERATOR SPECIFICATIONS',
      showBackButton: isEditMode,
      fallbackRoute: isEditMode ? '/profile' : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          child: Column(
            children: [
              // Header with proper spacing
              Text(
                'INPUT PHYSICAL PARAMETERS\nREQUIRED FOR LOAD CALCULATIONS',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: HeavyweightTheme.spacingLg),
              
              // Stats selectors
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                          // Age
                          _buildStatSection(
                            'OPERATOR_AGE',
                            SelectorWheel(
                              value: provider.age ?? 25,
                              min: 16,
                              max: 80,
                              suffix: 'YRS',
                              onChanged: (v) {
                                HWLog.event('profile_physical_age', data: {'value': v});
                                provider.setAge(v);
                              },
                            ),
                          ),
                          
                          const SizedBox(height: HeavyweightTheme.spacingLg),
                          
                          // Weight
                          _buildStatSection(
                            'MASS_SPECIFICATION',
                            Column(
                              children: [
                                SelectorWheel(
                                  value: provider.weight?.round() ?? 70,
                                  min: provider.unit == Unit.kg ? 40 : 88,
                                  max: provider.unit == Unit.kg ? 200 : 440,
                                  suffix: provider.unit == Unit.kg ? 'KG' : 'LBS',
                                  onChanged: (value) {
                                    HWLog.event('profile_physical_weight', data: {'value': value});
                                    provider.setWeight(value.toDouble());
                                  },
                                ),
                                const SizedBox(height: HeavyweightTheme.spacingSm),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        HWLog.event('profile_physical_unit', data: {'value': 'kg'});
                                        provider.setUnit(Unit.kg);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: HeavyweightTheme.spacingSm, vertical: HeavyweightTheme.spacingXs),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: HeavyweightTheme.primary),
                                          color: provider.unit == Unit.kg ? HeavyweightTheme.primary : Colors.transparent,
                                        ),
                                        child: Text(
                                          'KG',
                                          style: HeavyweightTheme.bodyMedium.copyWith(
                                            color: provider.unit == Unit.kg
                                                ? HeavyweightTheme.onPrimary
                                                : HeavyweightTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: HeavyweightTheme.spacingSm),
                                    GestureDetector(
                                      onTap: () {
                                        HWLog.event('profile_physical_unit', data: {'value': 'lb'});
                                        provider.setUnit(Unit.lb);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: HeavyweightTheme.spacingSm, vertical: HeavyweightTheme.spacingXs),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: HeavyweightTheme.primary),
                                          color: provider.unit == Unit.lb ? HeavyweightTheme.primary : Colors.transparent,
                                        ),
                                        child: Text(
                                          'LBS',
                                          style: HeavyweightTheme.bodyMedium.copyWith(
                                            color: provider.unit == Unit.lb
                                                ? HeavyweightTheme.onPrimary
                                                : HeavyweightTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: HeavyweightTheme.spacingLg),
                          
                          // Height
                          _buildStatSection(
                            'HEIGHT_PARAMETER',
                            SelectorWheel(
                              value: provider.height ?? 175,
                              min: 140,
                              max: 220,
                              suffix: 'CM',
                              onChanged: (v) {
                                HWLog.event('profile_physical_height', data: {'value': v});
                                provider.setHeight(v);
                              },
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
                  final isComplete = provider.age != null && 
                                   provider.weight != null && 
                                   provider.height != null;
                  
                  return CommandButton(
                    text: 'COMMAND: CONFIRM',
                    variant: ButtonVariant.primary,
                    isDisabled: !isComplete,
                    onPressed: isComplete
                        ? () async {
                            HWLog.event('profile_physical_continue');
                            // Save physical stats to AppState
                            final statsData = '${provider.age},${provider.weight},${provider.height}';
                            final appState = context.read<AppStateProvider>().appState;
                            await appState.setPhysicalStats(statsData);
                            
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
  
  Widget _buildStatSection(String title, Widget selector) {
    return Column(
      children: [
        Text(
          title,
          style: HeavyweightTheme.bodyMedium,
        ),
        const SizedBox(height: HeavyweightTheme.spacingMd),
        selector,
      ],
    );
  }
}
