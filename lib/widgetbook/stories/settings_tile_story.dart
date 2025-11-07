import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/settings_widgets.dart';

WidgetbookComponent buildSettingsTileComponent() {
  return WidgetbookComponent(
    name: 'Settings Tile',
    useCases: [
      WidgetbookUseCase(
        name: 'Navigation',
        builder: (_) => const _NavigationTileDemo(),
      ),
      WidgetbookUseCase(
        name: 'Toggle',
        builder: (_) => const _ToggleTileDemo(),
      ),
      WidgetbookUseCase(
        name: 'Custom Trailing',
        builder: (_) => const _CustomTileDemo(),
      ),
      WidgetbookUseCase(
        name: 'All Variants',
        builder: (_) => const _AllVariantsDemo(),
      ),
    ],
  );
}

class _NavigationTileDemo extends StatelessWidget {
  const _NavigationTileDemo();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsTile.navigation(
              icon: Icons.color_lens_outlined,
              label: 'Appearance',
              valueText: 'System',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            SettingsTile.navigation(
              icon: Icons.language_outlined,
              label: 'Language',
              valueText: 'English (US)',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            SettingsTile.navigation(
              icon: Icons.list_alt_outlined,
              label: 'Program',
              valueText: 'Get Strong',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTileDemo extends StatefulWidget {
  const _ToggleTileDemo();

  @override
  State<_ToggleTileDemo> createState() => _ToggleTileDemoState();
}

class _ToggleTileDemoState extends State<_ToggleTileDemo> {
  bool _notifications = true;
  bool _health = false;
  bool _analytics = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsTile.toggle(
              icon: Icons.notifications_none_outlined,
              label: 'Notifications',
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
            ),
            const SizedBox(height: 16),
            SettingsTile.toggle(
              icon: Icons.favorite_border,
              label: 'Apple Health',
              value: _health,
              onChanged: (value) => setState(() => _health = value),
            ),
            const SizedBox(height: 16),
            SettingsTile.toggle(
              icon: Icons.analytics_outlined,
              label: 'Analytics',
              value: _analytics,
              onChanged: (value) => setState(() => _analytics = value),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTileDemo extends StatelessWidget {
  const _CustomTileDemo();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsTile.custom(
              icon: Icons.badge_outlined,
              label: 'Name',
              trailing: const Text(
                'Alex',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            SettingsTile.custom(
              icon: Icons.star_outline,
              label: 'Premium Status',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _AllVariantsDemo extends StatefulWidget {
  const _AllVariantsDemo();

  @override
  State<_AllVariantsDemo> createState() => _AllVariantsDemoState();
}

class _AllVariantsDemoState extends State<_AllVariantsDemo> {
  bool _toggleValue = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Navigation tiles
            SettingsTile.navigation(
              icon: Icons.person_outline,
              label: 'Profile',
              valueText: 'Alex Smith',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            SettingsTile.navigation(
              icon: Icons.straighten,
              label: 'Units',
              valueText: 'Metric (Kg)',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            
            // Toggle tiles
            SettingsTile.toggle(
              icon: Icons.vibration,
              label: 'Haptic Feedback',
              value: _toggleValue,
              onChanged: (value) => setState(() => _toggleValue = value),
            ),
            const SizedBox(height: 16),
            
            // Custom tiles
            SettingsTile.custom(
              icon: Icons.workspace_premium_outlined,
              label: 'Subscription',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
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
