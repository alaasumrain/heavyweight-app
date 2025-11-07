import 'package:flutter/material.dart';

import '../../core/theme/heavyweight_theme.dart';

class ExerciseSetRowData {
  const ExerciseSetRowData({
    required this.weight,
    required this.unit,
    required this.reps,
    this.isCompleted = false,
    this.isDropset = false,
    this.isWarmup = false,
  });

  final String weight;
  final String unit;
  final String reps;
  final bool isCompleted;
  final bool isDropset;
  final bool isWarmup;
}

class ExerciseSheet extends StatelessWidget {
  const ExerciseSheet({
    super.key,
    required this.title,
    this.variant,
    required this.sets,
    this.note,
    this.onAddSet,
    this.onSwap,
    this.onMore,
  });

  final String title;
  final String? variant;
  final List<ExerciseSetRowData> sets;
  final String? note;
  final VoidCallback? onAddSet;
  final VoidCallback? onSwap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: HeavyweightTheme.spacingLg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: HeavyweightTheme.spacingSm),
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (variant != null) ...[
                            const SizedBox(width: HeavyweightTheme.spacingSm),
                            Text(
                              variant!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (note != null) ...[
                        const SizedBox(height: HeavyweightTheme.spacingSm),
                        Text(
                          note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onMore,
                  icon: const Icon(Icons.more_horiz, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: HeavyweightTheme.spacingLg),
            Column(
              children: [
                for (var data in sets) ...[
                  ExerciseSetRow(data: data),
                  const SizedBox(height: HeavyweightTheme.spacingSm),
                ],
              ],
            ),
            if (onAddSet != null || onSwap != null) ...[
              const SizedBox(height: HeavyweightTheme.spacingLg),
              Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.note_add_outlined,
                    onPressed: onAddSet,
                  ),
                  const SizedBox(width: HeavyweightTheme.spacingLg),
                  Expanded(
                    child: TextButton(
                      onPressed: onAddSet,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: HeavyweightTheme.spacingSm,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Icon(Icons.add, size: 24),
                    ),
                  ),
                  const SizedBox(width: HeavyweightTheme.spacingLg),
                  _CircleIconButton(
                    icon: Icons.swap_vert,
                    onPressed: onSwap,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ExerciseSetRow extends StatelessWidget {
  const ExerciseSetRow({
    super.key,
    required this.data,
  });

  final ExerciseSetRowData data;

  @override
  Widget build(BuildContext context) {
    final highlightColor = data.isCompleted
        ? Colors.white12
        : data.isDropset
            ? const Color(0x26FFA500)
            : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: highlightColor,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: HeavyweightTheme.spacingMd,
        vertical: HeavyweightTheme.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _MetricBlock(
                  label: 'Kg',
                  value: data.weight,
                  highlight: data.isWarmup,
                ),
                const SizedBox(width: HeavyweightTheme.spacingXl),
                _MetricBlock(
                  label: 'reps',
                  value: data.reps,
                  highlight: data.isDropset,
                ),
              ],
            ),
          ),
          _Checkbox(isChecked: data.isCompleted),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: highlight ? HeavyweightTheme.accentNeon : Colors.white38,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isChecked ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isChecked ? Colors.white : Colors.white30,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isChecked
          ? const Icon(Icons.check, size: 16, color: Colors.black)
          : const SizedBox.shrink(),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.white10,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(12),
      ),
      child: Icon(icon, size: 20),
    );
  }
}
