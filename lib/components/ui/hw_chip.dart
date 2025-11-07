import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/heavyweight_theme.dart';

class HWChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const HWChip(
      {super.key,
      required this.label,
      required this.selected,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: () {
          try {
            HapticFeedback.selectionClick();
            onSelected(!selected);
          } catch (error) {
            debugPrint('HWChip error: $error');
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: HeavyweightTheme.spacingMd,
            vertical: HeavyweightTheme.spacingSm,
          ),
          constraints:
              const BoxConstraints(minHeight: 44), // Accessibility minimum
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? HeavyweightTheme.primary
                  : HeavyweightTheme.secondary,
              width: selected ? 2 : 1,
            ),
            color: selected ? HeavyweightTheme.surface : Colors.transparent,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: HeavyweightTheme.primary.withValues(alpha: 0.08),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selected ? '[X]' : '[ ]',
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: selected
                      ? HeavyweightTheme.primary
                      : HeavyweightTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: HeavyweightTheme.spacingSm),
              Text(
                label.toUpperCase(),
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: selected
                      ? HeavyweightTheme.primary
                      : HeavyweightTheme.textSecondary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
