import 'package:flutter/material.dart';

import '../../core/theme/heavyweight_theme.dart';
import 'hw_badge.dart';

class AssignmentSet {
  const AssignmentSet({
    required this.weight,
    required this.unit,
    required this.reps,
    this.isCompleted = false,
    this.onToggle,
  });

  final String weight;
  final String unit;
  final String reps;
  final bool isCompleted;
  final ValueChanged<bool>? onToggle;
}

class AssignmentEntry {
  const AssignmentEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sets,
    this.note,
    this.orderLabel,
    this.completedSets,
    this.totalSets,
    this.lastPerformance,
    this.primaryLabel,
    this.alternativeSelected = false,
    this.needsCalibration = false,
    this.onTap,
    this.onSwap,
    this.onAddNote,
    this.onAddSet,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<AssignmentSet> sets;
  final String? note;
  final String? orderLabel;
  final int? completedSets;
  final int? totalSets;
  final String? lastPerformance;
  final String? primaryLabel;
  final bool alternativeSelected;
  final bool needsCalibration;
  final VoidCallback? onTap;
  final VoidCallback? onSwap;
  final VoidCallback? onAddNote;
  final VoidCallback? onAddSet;
}

class WorkoutAssignmentList extends StatelessWidget {
  const WorkoutAssignmentList({
    super.key,
    required this.entries,
    this.isScrollable = false,
    this.padding,
  });

  final List<AssignmentEntry> entries;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final physics = isScrollable
        ? const BouncingScrollPhysics()
        : const NeverScrollableScrollPhysics();

    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      physics: physics,
      padding: padding ?? EdgeInsets.zero,
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(
        height: HeavyweightTheme.spacingLg,
      ),
      itemBuilder: (context, index) {
        return _AssignmentCard(entry: entries[index]);
      },
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.entry});

  final AssignmentEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final totalSets = entry.totalSets ?? entry.sets.length;
    final completedSets = entry.completedSets ??
        entry.sets.where((set) => set.isCompleted).length;
    final progressSymbols = totalSets > 0
        ? List.generate(totalSets, (index) => index < completedSets ? '■' : '□')
            .join(' ')
        : '';

    final borderColor =
        entry.alternativeSelected ? HeavyweightTheme.primary : Colors.white10;
    final borderWidth = entry.alternativeSelected ? 2.0 : 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: entry.onTap,
        borderRadius: BorderRadius.circular(32),
        highlightColor: HeavyweightTheme.primary.withValues(alpha: 0.08),
        splashColor: HeavyweightTheme.primary.withValues(alpha: 0.12),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Padding(
            padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.orderLabel != null) ...[
                      Text(
                        entry.orderLabel!,
                        style: textTheme.labelMedium?.copyWith(
                          color: HeavyweightTheme.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: HeavyweightTheme.spacingSm),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                              Expanded(
                                child: Text(
                                  entry.title,
                                  style: textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (entry.needsCalibration)
                                const Padding(
                                  padding: EdgeInsets.only(
                                      left: HeavyweightTheme.spacingXs),
                                  child: HWBadge('CAL',
                                      variant: HWBadgeVariant.danger),
                                ),
                              if (entry.alternativeSelected)
                                const Padding(
                                  padding: EdgeInsets.only(
                                      left: HeavyweightTheme.spacingXs),
                                  child: HWBadge('ALT',
                                      variant: HWBadgeVariant.muted),
                                ),
                            ],
                          ),
                          const SizedBox(height: HeavyweightTheme.spacingXs),
                          Text(
                            entry.subtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                          if (entry.primaryLabel != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: HeavyweightTheme.spacingXs),
                              child: Text(
                                'ALT OF ${entry.primaryLabel!}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white38,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (progressSymbols.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: HeavyweightTheme.spacingSm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              progressSymbols,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: HeavyweightTheme.spacingXs),
                            Text(
                              '${completedSets.toString().padLeft(2, '0')}/${totalSets.toString().padLeft(2, '0')}',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white38,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (entry.lastPerformance != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: HeavyweightTheme.spacingSm),
                    child: Text(
                      entry.lastPerformance!,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white38,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                if (entry.note != null && entry.note!.trim().isNotEmpty)
                  Container(
                    margin:
                        const EdgeInsets.only(top: HeavyweightTheme.spacingMd),
                    padding: const EdgeInsets.all(HeavyweightTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      entry.note!,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                const SizedBox(height: HeavyweightTheme.spacingMd),
                Column(
                  children: [
                    for (var i = 0; i < entry.sets.length; i++) ...[
                      _AssignmentSetRow(
                        index: i,
                        total: entry.sets.length,
                        set: entry.sets[i],
                      ),
                      if (i != entry.sets.length - 1)
                        const SizedBox(height: HeavyweightTheme.spacingSm),
                    ],
                  ],
                ),
                if (entry.onAddNote != null ||
                    entry.onAddSet != null ||
                    entry.onSwap != null) ...[
                  const SizedBox(height: HeavyweightTheme.spacingMd),
                  Row(
                    children: [
                      _CircularActionButton(
                        icon: Icons.note_add_outlined,
                        onPressed: entry.onAddNote,
                      ),
                      const SizedBox(width: HeavyweightTheme.spacingLg),
                      Expanded(
                        child: _SecondaryActionButton(
                          label: 'Add set',
                          onPressed: entry.onAddSet,
                        ),
                      ),
                      const SizedBox(width: HeavyweightTheme.spacingLg),
                      _CircularActionButton(
                        icon: Icons.swap_vert,
                        onPressed: entry.onSwap,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignmentSetRow extends StatelessWidget {
  const _AssignmentSetRow({
    required this.index,
    required this.total,
    required this.set,
  });

  final int index;
  final int total;
  final AssignmentSet set;

  @override
  Widget build(BuildContext context) {
    final setLabel = 'SET ${(index + 1).toString().padLeft(2, '0')}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                setLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white38,
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingXs),
              Row(
                children: [
                  _SetMetric(value: set.weight, label: set.unit),
                  const SizedBox(width: HeavyweightTheme.spacingXl),
                  _SetMetric(value: set.reps, label: 'reps'),
                ],
              ),
            ],
          ),
        ),
        _Checkbox(
          isChecked: set.isCompleted,
          onChanged: set.onToggle,
        ),
      ],
    );
  }
}

class _SetMetric extends StatelessWidget {
  const _SetMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white54,
                letterSpacing: 1.5,
              ),
        ),
      ],
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({
    required this.isChecked,
    this.onChanged,
  });

  final bool isChecked;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isInteractive = onChanged != null;
    final borderRadius = BorderRadius.circular(8);
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isChecked ? Colors.white : Colors.transparent,
        borderRadius: borderRadius,
        border: Border.all(
          color: isChecked ? Colors.white : Colors.white30,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isChecked
          ? const Icon(Icons.check, size: 16, color: Colors.black)
          : null,
    );

    if (!isInteractive) {
      return box;
    }

    return InkWell(
      onTap: () => onChanged?.call(!isChecked),
      borderRadius: borderRadius,
      child: box,
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  const _CircularActionButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final backgroundColor = isEnabled ? Colors.white10 : Colors.white12;
    final iconColor = isEnabled ? Colors.white70 : Colors.white30;
    final radius = BorderRadius.circular(22);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: radius,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final backgroundColor = isEnabled ? Colors.white10 : Colors.white12;
    final textColor = isEnabled ? Colors.white : Colors.white38;
    final radius = BorderRadius.circular(26);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: radius,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                ),
          ),
        ),
      ),
    );
  }
}
