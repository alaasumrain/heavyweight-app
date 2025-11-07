import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/settings_widgets.dart';

WidgetbookComponent buildSettingsPremiumCardComponent() {
  return WidgetbookComponent(
    name: 'Settings Premium Card',
    useCases: [
      WidgetbookUseCase(
        name: 'Active Premium',
        builder: (_) => const _ActivePremiumDemo(),
      ),
      WidgetbookUseCase(
        name: 'Upgrade Prompt',
        builder: (_) => const _UpgradePromptDemo(),
      ),
      WidgetbookUseCase(
        name: 'Trial Period',
        builder: (_) => const _TrialPeriodDemo(),
      ),
      WidgetbookUseCase(
        name: 'Custom Icons',
        builder: (_) => const _CustomIconsDemo(),
      ),
    ],
  );
}

class _ActivePremiumDemo extends StatelessWidget {
  const _ActivePremiumDemo();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SettingsPremiumCard(
          title: 'Lift Pro',
          subtitle: 'Thanks for supporting Lift',
          leading: const _PremiumIcon(),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                color: Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpgradePromptDemo extends StatelessWidget {
  const _UpgradePromptDemo();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SettingsPremiumCard(
          title: 'Upgrade to Pro',
          subtitle: 'Unlock advanced analytics and features',
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.star,
              color: Colors.amber,
              size: 26,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'UPGRADE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrialPeriodDemo extends StatelessWidget {
  const _TrialPeriodDemo();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SettingsPremiumCard(
          title: 'Pro Trial',
          subtitle: '5 days remaining • Cancel anytime',
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.timer,
              color: Colors.blue,
              size: 26,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white70,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _CustomIconsDemo extends StatelessWidget {
  const _CustomIconsDemo();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SettingsPremiumCard(
              title: 'Team Plan',
              subtitle: 'Share with your gym buddies',
              leading: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.group,
                  color: Colors.purple,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SettingsPremiumCard(
              title: 'Coach Access',
              subtitle: 'Get personalized guidance',
              leading: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.orange,
                  size: 26,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumIcon extends StatelessWidget {
  const _PremiumIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.workspace_premium_outlined,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
