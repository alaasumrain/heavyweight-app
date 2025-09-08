import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../components/ui/system_banner.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/radio_selector.dart';

import '../../../providers/app_state_provider.dart';
import '../../../nav.dart';

enum WeightUnit { kg, lb }

class UnitPreferenceScreen extends StatefulWidget {
  const UnitPreferenceScreen({super.key});

  @override
  State<UnitPreferenceScreen> createState() => _UnitPreferenceScreenState();
}

class _UnitPreferenceScreenState extends State<UnitPreferenceScreen> {
  WeightUnit? _selectedUnit;

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
              context.go('/profile/frequency');
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
                'MEASUREMENT PROTOCOL',
                style: HeavyweightTheme.h3,
              ),
              const SizedBox(height: 10),
              Text(
                'SELECT LOAD MEASUREMENT STANDARD\nCONFIGURE SYSTEM DISPLAY UNITS',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              
              // Unit options
              Expanded(
                child: RadioSelector<WeightUnit>(
                  options: const [
                    RadioOption(
                      value: WeightUnit.kg,
                      label: 'KILOGRAMS (KG) - Metric load standard',
                    ),
                    RadioOption(
                      value: WeightUnit.lb,
                      label: 'POUNDS (LB) - Imperial load standard',
                    ),
                  ],
                  selectedValue: _selectedUnit,
                  onChanged: (unit) {
                    setState(() {
                      _selectedUnit = unit;
                    });
                  },
                ),
              ),
              
              // Continue button
              CommandButton(
                text: 'SET_UNITS',
                variant: ButtonVariant.primary,
                isDisabled: _selectedUnit == null,
                onPressed: _selectedUnit != null
                    ? () async {
                        // Mark unit preference as set in AppState
                        final appState = context.read<AppStateProvider>().appState;
                        await appState.setUnitPreference(_selectedUnit!.name);
                        
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