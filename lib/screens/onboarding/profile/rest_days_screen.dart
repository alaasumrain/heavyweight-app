import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../components/layout/heavyweight_scaffold.dart';
import '../../../core/theme/heavyweight_theme.dart';
import '../../../components/ui/command_button.dart';
import '../../../providers/app_state_provider.dart';
import '../../../core/logging.dart';

class RestDaysScreen extends StatefulWidget {
  const RestDaysScreen({super.key});

  @override
  State<RestDaysScreen> createState() => _RestDaysScreenState();
}

class _RestDaysScreenState extends State<RestDaysScreen> {
  final Set<int> _restDays = {};
  String? _error;

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
    final labels = const ['SUN','MON','TUE','WED','THU','FRI','SAT'];
    final trainDays = 7 - _restDays.length;
    final valid = trainDays >= 3;

    return HeavyweightScaffold(
      title: 'REST DAYS',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: HeavyweightTheme.spacingLg),
          Text('PICK WHICH DAYS YOU DO NOT TRAIN', style: HeavyweightTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: HeavyweightTheme.spacingLg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (i) {
              final selected = _restDays.contains(i);
              return ChoiceChip(
                label: Text(labels[i]),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _restDays.add(i);
                    } else {
                      _restDays.remove(i);
                    }
                    _error = null;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: HeavyweightTheme.spacingMd),
          Text('Training days: $trainDays', textAlign: TextAlign.center, style: HeavyweightTheme.bodySmall),
          if (!valid || _error != null) ...[
            const SizedBox(height: HeavyweightTheme.spacingSm),
            Text(_error ?? 'NOT ENOUGH TRAINING DAYS CONFIGURED', textAlign: TextAlign.center, style: TextStyle(color: HeavyweightTheme.danger)),
          ],
          const Spacer(),
          CommandButton(
            text: 'CONTINUE',
            variant: ButtonVariant.primary,
            isDisabled: !valid,
            onPressed: () async {
              final ok = await context.read<AppStateProvider>().appState.setRestDays(_restDays.toList());
              if (!ok) {
                setState(() => _error = 'NOT ENOUGH TRAINING DAYS CONFIGURED');
                return;
              }
              if (!mounted) return;
              context.go('/profile/duration');
            },
          ),
          const SizedBox(height: HeavyweightTheme.spacingLg),
        ],
      ),
    );
  }
}

