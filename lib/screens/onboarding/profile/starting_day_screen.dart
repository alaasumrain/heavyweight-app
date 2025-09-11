import 'package:flutter/material.dart';
import '../../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/radio_selector.dart';
import '../../../providers/app_state_provider.dart';
import '../../../components/layout/heavyweight_scaffold.dart';
import '../../../core/logging.dart';

enum StartingDay {
  chest,
  back, 
  arms,
  shoulders,
  legs,
}

class StartingDayScreen extends StatefulWidget {
  const StartingDayScreen({Key? key}) : super(key: key);

  @override
  State<StartingDayScreen> createState() => _StartingDayScreenState();
}

class _StartingDayScreenState extends State<StartingDayScreen> {
  StartingDay? selectedDay;

  @override
  Widget build(BuildContext context) {
    HWLog.screen('Onboarding/Profile/StartingDay');
    return HeavyweightScaffold(
      title: 'STARTING POINT',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          child: Column(
            children: [
              const SizedBox(height: HeavyweightTheme.spacingSm),
              
              // Header
              Text(
                'WHICH MUSCLE GROUP DO YOU\nWANT TO FOCUS ON FIRST?',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: HeavyweightTheme.spacingSm),
              
              Text(
                'The system will start your protocol here\nand rotate through the full 5-day cycle.',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodySmall.copyWith(
                  color: HeavyweightTheme.textSecondary,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              
              // Starting day options
              RadioSelector<StartingDay>(
                options: const [
                  RadioOption(
                    value: StartingDay.chest,
                    label: 'CHEST',
                  ),
                  RadioOption(
                    value: StartingDay.back,
                    label: 'BACK',
                  ),
                  RadioOption(
                    value: StartingDay.arms,
                    label: 'ARMS',
                  ),
                  RadioOption(
                    value: StartingDay.shoulders,
                    label: 'SHOULDERS',
                  ),
                  RadioOption(
                    value: StartingDay.legs,
                    label: 'LEGS',
                  ),
                ],
                selectedValue: selectedDay,
                onChanged: (val) {
                  HWLog.event('profile_starting_day_select', data: {'value': val.name});
                  setState(() {
                    selectedDay = val;
                  });
                },
              ),
              
              const SizedBox(height: HeavyweightTheme.spacingXl),
              
              // Continue button
              CommandButton(
                text: 'LOCK_STARTING_POINT',
                variant: ButtonVariant.primary,
                isDisabled: selectedDay == null,
                onPressed: selectedDay != null
                    ? () async {
                        HWLog.event('profile_starting_day_continue');
                        // Save starting day to AppState
                        final appState = context.read<AppStateProvider>().appState;
                        await appState.setPreferredStartingDay(selectedDay!.name);
                        
                        if (context.mounted) {
                          // Let the centralized flow controller decide where to go next
                          final nextRoute = appState.nextRoute;
                          context.go(nextRoute);
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}