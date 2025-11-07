import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/settings_widgets.dart';
import '../../core/theme/heavyweight_theme.dart';

WidgetbookComponent buildSettingsScreenComponent() {
  return WidgetbookComponent(
    name: 'Settings Screen',
    useCases: [
      WidgetbookUseCase(
        name: 'Preferences',
        builder: (_) => const _InteractiveSettingsScreen(),
      ),
    ],
  );
}

class _InteractiveSettingsScreen extends StatefulWidget {
  const _InteractiveSettingsScreen();

  @override
  State<_InteractiveSettingsScreen> createState() =>
      _InteractiveSettingsScreenState();
}

class _InteractiveSettingsScreenState
    extends State<_InteractiveSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _healthEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(
              horizontal: HeavyweightTheme.spacingXl,
              vertical: HeavyweightTheme.spacingXl,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: HeavyweightTheme.h2.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingXxl),
                  const SettingsPremiumCard(
                    title: 'Lift Pro',
                    subtitle: 'Thanks for supporting Lift',
                    leading: _PremiumIcon(),
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingXxl),
                  SettingsSection(
                    title: 'General',
                    tiles: [
                      SettingsTile.navigation(
                        icon: Icons.color_lens_outlined,
                        label: 'Appearance',
                        valueText: 'System',
                        onTap: () {},
                      ),
                      SettingsTile.toggle(
                        icon: Icons.notifications_none_outlined,
                        label: 'Notifications',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                        },
                      ),
                      SettingsTile.toggle(
                        icon: Icons.favorite_border,
                        label: 'Apple Health',
                        value: _healthEnabled,
                        onChanged: (value) {
                          setState(() => _healthEnabled = value);
                        },
                      ),
                      SettingsTile.navigation(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        valueText: 'English (US)',
                        onTap: () {},
                      ),
                      SettingsTile.navigation(
                        icon: Icons.list_alt_outlined,
                        label: 'Program',
                        valueText: 'Get',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingXxl),
                  SettingsSection(
                    title: 'Personal',
                    tiles: const [
                      SettingsTile.navigation(
                        icon: Icons.badge_outlined,
                        label: 'Name',
                        valueText: 'Alaa',
                        onTap: null,
                      ),
                      SettingsTile.navigation(
                        icon: Icons.straighten,
                        label: 'Units',
                        valueText: 'Kg',
                        onTap: null,
                      ),
                      SettingsTile.navigation(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Weight',
                        valueText: '101.0 Kg',
                        onTap: null,
                      ),
                      SettingsTile.navigation(
                        icon: Icons.cake_outlined,
                        label: 'Age',
                        valueText: '26 yo',
                        onTap: null,
                      ),
                      SettingsTile.navigation(
                        icon: Icons.calendar_view_week,
                        label: 'Weekly frequency',
                        valueText: '5 days',
                        onTap: null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
