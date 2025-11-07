import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../components/layout/heavyweight_scaffold.dart';
import '../../../core/theme/heavyweight_theme.dart';
import '../../../components/ui/command_button.dart';
import '../../../providers/app_state_provider.dart';
import '../../../components/ui/hw_panel.dart';
import '../../../components/ui/hw_chip.dart';
import '../../../core/logging.dart';

class RestDaysScreen extends StatefulWidget {
  const RestDaysScreen({super.key});

  @override
  State<RestDaysScreen> createState() => _RestDaysScreenState();
}

class _RestDaysScreenState extends State<RestDaysScreen> {
  final Set<int> _restDays = {};

  @override
  void initState() {
    super.initState();
    HWLog.screen('Onboarding/Profile/RestDays');
    final appState = context.read<AppStateProvider>().appState;
    final existing = appState.restDays;
    if (existing != null) {
      _restDays.addAll(existing);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = const ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final trainDays = 7 - _restDays.length;
    final valid = trainDays >= 3;

    return HeavyweightScaffold(
      title: 'REST DAYS',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: HeavyweightTheme.spacingLg),
          HWPanel(
            child: Column(
              children: [
                Text(
                  'SELECT DAYS YOU DO NOT TRAIN\\nMINIMUM 3 TRAINING DAYS REQUIRED',
                  style: HeavyweightTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: HeavyweightTheme.spacingLg),

                // Days grid
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: HeavyweightTheme.spacingSm,
                  runSpacing: HeavyweightTheme.spacingSm,
                  children: List.generate(7, (i) {
                    final selected = _restDays.contains(i);
                    return HWChip(
                      label: labels[i],
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _restDays.add(i);
                          } else {
                            _restDays.remove(i);
                          }
                        });
                      },
                    );
                  }),
                ),

                const SizedBox(height: HeavyweightTheme.spacingLg),

                // Status container
                Container(
                  padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: valid
                            ? HeavyweightTheme.primary
                            : HeavyweightTheme.danger),
                    color: valid
                        ? HeavyweightTheme.primary.withValues(alpha: 0.05)
                        : HeavyweightTheme.danger.withValues(alpha: 0.05),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TRAINING DAYS: $trainDays | REST DAYS: ${_restDays.length}',
                        style: HeavyweightTheme.labelMedium.copyWith(
                          color: valid
                              ? HeavyweightTheme.primary
                              : HeavyweightTheme.danger,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!valid) ...[
                        const SizedBox(height: HeavyweightTheme.spacingSm),
                        Text(
                          'MINIMUM 3 TRAINING DAYS REQUIRED',
                          style: HeavyweightTheme.bodySmall.copyWith(
                            color: HeavyweightTheme.danger,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          CommandButton(
            text: 'CONTINUE',
            variant: ButtonVariant.primary,
            isDisabled: !valid,
            onPressed: () async {
              final appState = context.read<AppStateProvider>().appState;
              final router = GoRouter.of(context);
              final messenger = ScaffoldMessenger.of(context);

              final ok = await appState.setRestDays(_restDays.toList());
              if (!ok) {
                if (!mounted) return;
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      backgroundColor: HeavyweightTheme.danger,
                      content: Text(
                        'NOT ENOUGH TRAINING DAYS CONFIGURED',
                        style: TextStyle(
                          color: HeavyweightTheme.onPrimary,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                return;
              }
              if (!mounted) return;
              router.go('/profile/duration');
            },
          ),
          const SizedBox(height: HeavyweightTheme.spacingLg),
        ],
      ),
    );
  }
}
