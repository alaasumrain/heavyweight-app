import 'package:flutter/material.dart';

import '../../core/theme/heavyweight_theme.dart';

/// Polished settings building blocks: premium hero, section cards, and tiles.
/// Shares spacing + typography with Heavyweight's core components.
class SettingsPremiumCard extends StatelessWidget {
  const SettingsPremiumCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB0B3BD), Color(0xFF6E6F79)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 24,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: HeavyweightTheme.spacingLg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: HeavyweightTheme.spacingXs),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: HeavyweightTheme.spacingLg),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.tiles,
  });

  final String title;
  final List<SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: HeavyweightTheme.labelMedium.copyWith(
            color: Colors.white70,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: HeavyweightTheme.spacingSm),
        Container(
          decoration: BoxDecoration(
            color: HeavyweightTheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++)
                Column(
                  children: [
                    if (i != 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    tiles[i],
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile.navigation({
    super.key,
    required this.icon,
    required this.label,
    this.valueText,
    this.onTap,
    this.trailing,
  })  : switchValue = null,
        onChanged = null;

  const SettingsTile.toggle({
    super.key,
    required this.icon,
    required this.label,
    required bool value,
    required this.onChanged,
  })  : switchValue = value,
        valueText = null,
        trailing = null,
        onTap = null;

  const SettingsTile.custom({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  })  : switchValue = null,
        valueText = null,
        onChanged = null;

  final IconData icon;
  final String label;
  final String? valueText;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool? switchValue;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isToggle = switchValue != null && onChanged != null;

    Widget trailingWidget;
    if (isToggle) {
      trailingWidget = Switch.adaptive(
        value: switchValue!,
        onChanged: onChanged,
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFF2BCB70)
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFF157A40)
              : Colors.white24,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.white24),
      );
    } else if (trailing != null) {
      trailingWidget = trailing!;
    } else {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (valueText != null)
            Text(
              valueText!,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          const SizedBox(width: HeavyweightTheme.spacingSm),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.45),
            size: 22,
          ),
        ],
      );
    }

    return InkWell(
      onTap: isToggle ? null : onTap,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HeavyweightTheme.spacingLg,
          vertical: HeavyweightTheme.spacingMd,
        ),
        child: Row(
          children: [
            _SettingsIcon(icon: icon),
            const SizedBox(width: HeavyweightTheme.spacingLg),
            Expanded(
              child: Text(
                label,
                style: HeavyweightTheme.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailingWidget,
          ],
        ),
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Icon(
        icon,
        size: 22,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }
}
