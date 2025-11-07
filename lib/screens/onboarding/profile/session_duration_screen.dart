import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../components/layout/heavyweight_scaffold.dart';
import '../../../components/ui/command_button.dart';
import '../../../core/theme/heavyweight_theme.dart';
import '../../../providers/app_state_provider.dart';
import '../../../core/logging.dart';
import '../../../components/ui/hw_panel.dart';
import '../../../components/ui/hw_chip.dart';

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
    final existing =
        context.read<AppStateProvider>().appState.sessionDurationMin;
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
          HWPanel(
            child: Column(
              children: [
                Text(
                  'SET TRAINING SESSION DURATION\\nSELECT AVAILABLE TIME PER WORKOUT',
                  style: HeavyweightTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: HeavyweightTheme.spacingLg),

                // Duration options
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: HeavyweightTheme.spacingSm,
                  runSpacing: HeavyweightTheme.spacingSm,
                  children: options.map((m) {
                    final sel = _selected == m;
                    return HWChip(
                      label: '$m MIN',
                      selected: sel,
                      onSelected: (_) => setState(() => _selected = m),
                    );
                  }).toList(),
                ),

                const SizedBox(height: HeavyweightTheme.spacingLg),

                // Selected duration display
                Container(
                  padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                  decoration: BoxDecoration(
                    border: Border.all(color: HeavyweightTheme.primary),
                    color: HeavyweightTheme.primary.withValues(alpha: 0.05),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SESSION_LENGTH: $_selected MINUTES',
                        style: HeavyweightTheme.labelMedium.copyWith(
                          color: HeavyweightTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: HeavyweightTheme.spacingSm),
                      Text(
                        _getDurationDescription(_selected),
                        style: HeavyweightTheme.bodySmall.copyWith(
                          color: HeavyweightTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
            onPressed: () async {
              final appState = context.read<AppStateProvider>().appState;
              final router = GoRouter.of(context);
              await appState.setSessionDurationMin(_selected);
              if (!mounted) return;
              router.go('/profile/baseline');
            },
          ),
          const SizedBox(height: HeavyweightTheme.spacingLg),
        ],
      ),
    );
  }

  String _getDurationDescription(int minutes) {
    switch (minutes) {
      case 45:
        return 'COMPACT SESSION\\nHigh-intensity focused training';
      case 60:
        return 'STANDARD SESSION\\nBalanced workout duration';
      case 75:
        return 'EXTENDED SESSION\\nThorough training protocol';
      case 90:
        return 'MAXIMUM SESSION\\nComprehensive workout time';
      default:
        return '';
    }
  }
}
