import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/settings_widgets.dart';

WidgetbookComponent buildSettingsSectionComponent() {
  return WidgetbookComponent(
    name: 'Settings Section',
    useCases: [
      WidgetbookUseCase(
        name: 'General Section',
        builder: (_) => const _GeneralSectionDemo(),
      ),
      WidgetbookUseCase(
        name: 'Personal Section',
        builder: (_) => const _PersonalSectionDemo(),
      ),
      WidgetbookUseCase(
        name: 'Mixed Section',
        builder: (_) => const _MixedSectionDemo(),
      ),
      WidgetbookUseCase(
        name: 'Single Item',
        builder: (_) => const _SingleItemDemo(),
      ),
    ],
  );
}

class _GeneralSectionDemo extends StatefulWidget {
  const _GeneralSectionDemo();

  @override
  State<_GeneralSectionDemo> createState() => _GeneralSectionDemoState();
}

class _GeneralSectionDemoState extends State<_GeneralSectionDemo> {
  bool _notifications = true;
  bool _health = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SettingsSection(
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
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
            ),
            SettingsTile.toggle(
              icon: Icons.favorite_border,
              label: 'Apple Health',
              value: _health,
              onChanged: (value) => setState(() => _health = value),
            ),
            SettingsTile.navigation(
              icon: Icons.language_outlined,
              label: 'Language',
              valueText: 'English (US)',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalSectionDemo extends StatelessWidget {
  const _PersonalSectionDemo();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SettingsSection(
          title: 'Personal',
          tiles: const [
            SettingsTile.navigation(
              icon: Icons.badge_outlined,
              label: 'Name',
              valueText: 'Alex',
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
      ),
    );
  }
}

class _MixedSectionDemo extends StatefulWidget {
  const _MixedSectionDemo();

  @override
  State<_MixedSectionDemo> createState() => _MixedSectionDemoState();
}

class _MixedSectionDemoState extends State<_MixedSectionDemo> {
  bool _autoRest = true;
  bool _haptics = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SettingsSection(
          title: 'Workout',
          tiles: [
            SettingsTile.navigation(
              icon: Icons.timer_outlined,
              label: 'Default Rest Time',
              valueText: '90 seconds',
              onTap: () {},
            ),
            SettingsTile.toggle(
              icon: Icons.play_circle_outline,
              label: 'Auto-start Rest Timer',
              value: _autoRest,
              onChanged: (value) => setState(() => _autoRest = value),
            ),
            SettingsTile.toggle(
              icon: Icons.vibration,
              label: 'Haptic Feedback',
              value: _haptics,
              onChanged: (value) => setState(() => _haptics = value),
            ),
            SettingsTile.custom(
              icon: Icons.music_note_outlined,
              label: 'Workout Playlist',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Spotify',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                    size: 22,
                  ),
                ],
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleItemDemo extends StatelessWidget {
  const _SingleItemDemo();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SettingsSection(
          title: 'Account',
          tiles: const [
            SettingsTile.navigation(
              icon: Icons.logout,
              label: 'Sign Out',
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }
}
