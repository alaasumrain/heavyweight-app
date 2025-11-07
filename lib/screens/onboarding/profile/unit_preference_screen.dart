import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/heavyweight_theme.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/radio_selector.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../components/layout/heavyweight_scaffold.dart';
import '../../../core/logging.dart';

class UnitPreferenceScreen extends StatefulWidget {
  const UnitPreferenceScreen({super.key});

  @override
  State<UnitPreferenceScreen> createState() => _UnitPreferenceScreenState();
}

class _UnitPreferenceScreenState extends State<UnitPreferenceScreen> {
  Unit? _selectedUnit;

  @override
  void initState() {
    super.initState();
    // Pre-select current unit so CTA is enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      setState(() {
        _selectedUnit = provider.unit;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    HWLog.screen('Onboarding/Profile/Units');
    final state = GoRouterState.of(context);
    final isEditMode = state.uri.queryParameters['edit'] == '1';

    return HeavyweightScaffold(
      title: 'MEASUREMENT PROTOCOL',
      showBackButton: isEditMode,
      fallbackRoute: isEditMode ? '/profile' : '/profile/frequency',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          child: Column(
            children: [
              // Header
              Text(
                'SELECT LOAD MEASUREMENT STANDARD\nCONFIGURE SYSTEM DISPLAY UNITS',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: HeavyweightTheme.spacingXl),

              // Unit options
              Consumer<ProfileProvider>(
                builder: (context, provider, _) {
                  _selectedUnit ??= provider.unit;
                  return RadioSelector<Unit>(
                    options: const [
                      RadioOption(
                        value: Unit.kg,
                        label: 'KILOGRAMS (KG) - Metric load standard',
                      ),
                      RadioOption(
                        value: Unit.lb,
                        label: 'POUNDS (LB) - Imperial load standard',
                      ),
                    ],
                    selectedValue: _selectedUnit,
                    onChanged: (unit) {
                      HWLog.event('profile_units_select',
                          data: {'value': unit.name});
                      setState(() {
                        _selectedUnit = unit;
                      });
                      provider.setUnit(unit);
                    },
                  );
                },
              ),

              const SizedBox(height: HeavyweightTheme.spacingXl),

              // Continue button
              CommandButton(
                text: 'CONTINUE',
                variant: ButtonVariant.primary,
                isDisabled: _selectedUnit == null,
                onPressed: _selectedUnit != null
                    ? () async {
                        HWLog.event('profile_units_continue');
                        // Persist unit preference in AppState as well
                        final appState =
                            context.read<AppStateProvider>().appState;
                        await appState.setUnitPreference(_selectedUnit!.name);

                        if (!context.mounted) return;
                        if (isEditMode) {
                          context.pop();
                        } else {
                          GoRouter.of(context).go('/profile/stats');
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
