import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../components/layout/heavyweight_scaffold.dart';
import '../../../components/ui/command_button.dart';
import '../../../core/theme/heavyweight_theme.dart';
import '../../../providers/app_state_provider.dart';
import '../../../core/logging.dart';

class SessionDurationScreen extends StatefulWidget {
  const SessionDurationScreen({super.key});

  @override
  State<SessionDurationScreen> createState() => _SessionDurationScreenState();
}

class _SessionDurationScreenState extends State<SessionDurationScreen> {
  int _selected = 60;

  @override
  void initState() {
    super.initState();
    HWLog.screen('Onboarding/Profile/Duration');
    final existing = context.read<AppStateProvider>().appState.sessionDurationMin;
    if (existing != null) _selected = existing;
  }

  @override
  Widget build(BuildContext context) {
    final options = const [45, 60, 75, 90];
    return HeavyweightScaffold(
      title: 'SESSION DURATION',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: HeavyweightTheme.spacingLg),
          Text('HOW MUCH TIME DO YOU HAVE PER SESSION?', style: HeavyweightTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: HeavyweightTheme.spacingLg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: options.map((m) {
              final sel = _selected == m;
              return ChoiceChip(
                label: Text('$m MIN'),
                selected: sel,
                onSelected: (_) => setState(() => _selected = m),
              );
            }).toList(),
          ),
          const Spacer(),
          CommandButton(
            text: 'CONTINUE',
            variant: ButtonVariant.primary,
            onPressed: () async {
              await context.read<AppStateProvider>().appState.setSessionDurationMin(_selected);
              if (!mounted) return;
              context.go('/profile/baseline');
            },
          ),
          const SizedBox(height: HeavyweightTheme.spacingLg),
        ],
      ),
    );
  }
}

