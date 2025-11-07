import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../components/layout/heavyweight_scaffold.dart';
import '../../../components/ui/command_button.dart';
import '../../../core/theme/heavyweight_theme.dart';
import '../../../core/logging.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../core/units.dart';
import '../../../components/ui/hw_text_field.dart';

class BaselineStrengthScreen extends StatefulWidget {
  const BaselineStrengthScreen({super.key});

  @override
  State<BaselineStrengthScreen> createState() => _BaselineStrengthScreenState();
}

class _BaselineStrengthScreenState extends State<BaselineStrengthScreen> {
  final _benchCtrl = TextEditingController();
  final _squatCtrl = TextEditingController();
  final _deadCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    HWLog.screen('Onboarding/Profile/Baseline');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppStateProvider>().appState;
      final unit = context.read<ProfileProvider>().unit == Unit.kg
          ? HWUnit.kg
          : HWUnit.lb;
      if (appState.baselineBenchKg != null) {
        _benchCtrl.text = formatWeightForUnit(appState.baselineBenchKg!, unit);
      }
      if (appState.baselineSquatKg != null) {
        _squatCtrl.text = formatWeightForUnit(appState.baselineSquatKg!, unit);
      }
      if (appState.baselineDeadKg != null) {
        _deadCtrl.text = formatWeightForUnit(appState.baselineDeadKg!, unit);
      }
    });
  }

  @override
  void dispose() {
    _benchCtrl.dispose();
    _squatCtrl.dispose();
    _deadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<ProfileProvider>().unit == Unit.kg
        ? HWUnit.kg
        : HWUnit.lb;
    final unitLabel = unit == HWUnit.kg ? 'KG' : 'LB';

    return HeavyweightScaffold(
      title: 'BASELINE STRENGTH (OPTIONAL)',
      showBackButton: true,
      fallbackRoute: '/profile',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DO YOU KNOW YOUR CURRENT NUMBERS?\n(SKIP IF UNKNOWN)',
                style: HeavyweightTheme.bodySmall,
              ),
              const SizedBox(height: HeavyweightTheme.spacingLg),

              HWTextField(
                label: 'BENCH PRESS',
                controller: _benchCtrl,
                suffix: unitLabel,
                hintText: unit == HWUnit.kg ? 'e.g. 100' : 'e.g. 225',
                numeric: true,
                min: 0,
                max: unit == HWUnit.kg ? 500 : kgToLb(500),
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              HWTextField(
                label: 'SQUAT',
                controller: _squatCtrl,
                suffix: unitLabel,
                hintText: unit == HWUnit.kg ? 'e.g. 140' : 'e.g. 315',
                numeric: true,
                min: 0,
                max: unit == HWUnit.kg ? 500 : kgToLb(500),
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              HWTextField(
                label: 'DEADLIFT',
                controller: _deadCtrl,
                suffix: unitLabel,
                hintText: unit == HWUnit.kg ? 'e.g. 160' : 'e.g. 405',
                numeric: true,
                min: 0,
                max: unit == HWUnit.kg ? 500 : kgToLb(500),
              ),

              const SizedBox(height: HeavyweightTheme.spacingXl),

              // Buttons with proper spacing
              Column(
                children: [
                  CommandButton(
                    text: 'SAVE & CONTINUE',
                    variant: ButtonVariant.primary,
                    onPressed: () async {
                      final appState =
                          context.read<AppStateProvider>().appState;
                      final benchKg = _benchCtrl.text.trim().isEmpty
                          ? null
                          : parseWeightInput(_benchCtrl.text, unit);
                      final squatKg = _squatCtrl.text.trim().isEmpty
                          ? null
                          : parseWeightInput(_squatCtrl.text, unit);
                      final deadKg = _deadCtrl.text.trim().isEmpty
                          ? null
                          : parseWeightInput(_deadCtrl.text, unit);
                      final router = GoRouter.of(context);
                      await appState.setBaseline(
                        benchKg: benchKg,
                        squatKg: squatKg,
                        deadKg: deadKg,
                      );
                      if (!mounted) return;
                      router.go('/manifesto');
                    },
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingMd),
                  CommandButton(
                    text: 'SKIP',
                    variant: ButtonVariant.secondary,
                    onPressed: () {
                      GoRouter.of(context).go('/manifesto');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TextField helper removed in favor of HWTextField
}
