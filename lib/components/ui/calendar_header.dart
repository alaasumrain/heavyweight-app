import 'package:flutter/material.dart';

import '../../core/theme/heavyweight_theme.dart';

class CalendarDay {
  const CalendarDay({
    required this.label,
    required this.day,
    this.isToday = false,
    this.isCompleted = false,
  });

  final String label;
  final int day;
  final bool isToday;
  final bool isCompleted;
}

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.username,
    required this.days,
    required this.completedWorkouts,
    required this.weekTarget,
  });

  final String username;
  final List<CalendarDay> days;
  final int completedWorkouts;
  final int weekTarget;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hey $username!',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: HeavyweightTheme.spacingLg),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(
              width: HeavyweightTheme.spacingSm,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              return _DayPill(day: day);
            },
          ),
        ),
        const SizedBox(height: HeavyweightTheme.spacingLg),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 12),
                blurRadius: 24,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: weekTarget == 0
                              ? 0
                              : (completedWorkouts / weekTarget).clamp(0, 1),
                          strokeWidth: 8,
                          backgroundColor: HeavyweightTheme.stroke,
                          valueColor: const AlwaysStoppedAnimation(
                            HeavyweightTheme.accentNeon,
                          ),
                        ),
                      ),
                      Text(
                        '$completedWorkouts/$weekTarget',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: HeavyweightTheme.spacingLg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly progress',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: HeavyweightTheme.spacingXs),
                    Text(
                      '$completedWorkouts of $weekTarget workouts completed',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({required this.day});

  final CalendarDay day;

  @override
  Widget build(BuildContext context) {
    final isToday = day.isToday;
    final bgColor = isToday
        ? Colors.black
        : day.isCompleted
            ? Colors.white
            : Colors.white;
    final textColor = isToday ? Colors.white : Colors.black;
    final badgeColor = day.isCompleted ? HeavyweightTheme.accentNeon : null;

    return Container(
      width: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isToday
              ? Colors.transparent
              : day.isCompleted
                  ? const Color(0x665FFB7F)
                  : HeavyweightTheme.stroke,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: HeavyweightTheme.spacingSm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isToday ? Colors.white60 : Colors.black45,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (badgeColor != null) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
