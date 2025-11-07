import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';

enum HWBadgeVariant { accent, danger, muted }

class HWBadge extends StatelessWidget {
  final String text;
  final HWBadgeVariant variant;

  const HWBadge(this.text, {super.key, this.variant = HWBadgeVariant.accent});

  @override
  Widget build(BuildContext context) {
    Color border;
    Color fill;
    Color fg;
    switch (variant) {
      case HWBadgeVariant.danger:
        border = HeavyweightTheme.danger;
        fill = HeavyweightTheme.danger.withValues(alpha: 0.15);
        fg = HeavyweightTheme.danger;
        break;
      case HWBadgeVariant.muted:
        border = HeavyweightTheme.secondary;
        fill = HeavyweightTheme.secondary.withValues(alpha: 0.15);
        fg = HeavyweightTheme.textSecondary;
        break;
      default:
        border = HeavyweightTheme.accent;
        fill = HeavyweightTheme.accent.withValues(alpha: 0.15);
        fg = HeavyweightTheme.accent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
