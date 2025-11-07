import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/analytics_card.dart';

const List<String> _rangeOptions = ['1M', '3M', '6M', '1Y'];

const Map<String, int> _rangeToMonths = {
  '1M': 1,
  '3M': 3,
  '6M': 6,
  '1Y': 12,
};

class _AnalyticsScenario {
  const _AnalyticsScenario({
    required this.metric,
    required this.graphPoints,
  });

  final AnalyticsMetric metric;
  final List<double> graphPoints;
}

const List<List<_AnalyticsScenario>> _scenarioMatrix = [
  [
    _AnalyticsScenario(
      metric: AnalyticsMetric(
        title: 'Total Volume',
        subtitle: 'All workouts',
        value: '6.2',
        unit: 'Tons',
        deltaPercent: 2.40,
      ),
      graphPoints: [5.3, 5.6, 6.0, 6.2],
    ),
    _AnalyticsScenario(
      metric: AnalyticsMetric(
        title: 'Total Volume',
        subtitle: 'All workouts',
        value: '17.8',
        unit: 'Tons',
        deltaPercent: 5.10,
      ),
      graphPoints: [4.9, 5.7, 6.4, 6.8, 7.2, 7.5],
    ),
    _AnalyticsScenario(
      metric: AnalyticsMetric(
        title: 'Total Volume',
        subtitle: 'All workouts',
        value: '35.9',
        unit: 'Tons',
        deltaPercent: 8.75,
      ),
      graphPoints: [3.5, 4.2, 4.9, 5.8, 6.4, 6.9, 7.6, 8.2, 8.9],
    ),
    _AnalyticsScenario(
      metric: AnalyticsMetric(
        title: 'Total Volume',
        subtitle: 'All workouts',
        value: '72.4',
        unit: 'Tons',
        deltaPercent: 12.40,
      ),
      graphPoints: [
        4.1,
        4.5,
        5.3,
        5.9,
        6.7,
        7.3,
        7.9,
        8.2,
        8.7,
        9.1,
        9.5,
        10.2,
      ],
    ),
  ],
  [
    _AnalyticsScenario(
      metric: AnalyticsMetric(
        title: 'Bench Press',
        subtitle: 'Barbell',
        value: '139',
        unit: 'Kg',
        deltaPercent: 2.80,
      ),
      graphPoints: [128, 130, 131, 134, 136, 139],
    ),
    _AnalyticsScenario(
      metric: AnalyticsMetric(
        title: 'Bench Press',
        subtitle: 'Barbell',
        value: '137',
        unit: 'Kg',
        deltaPercent: 5.60,
      ),
      graphPoints: [118, 122, 125, 129, 133, 135, 137],
    ),
    _AnalyticsScenario(
      metric: AnalyticsMetric(
        title: 'Bench Press',
        subtitle: 'Barbell',
        value: '134',
        unit: 'Kg',
        deltaPercent: 7.20,
      ),
      graphPoints: [110, 115, 119, 122, 126, 129, 132, 134],
    ),
    _AnalyticsScenario(
      metric: AnalyticsMetric(
        title: 'Bench Press',
        subtitle: 'Barbell',
        value: '131',
        unit: 'Kg',
        deltaPercent: 9.40,
      ),
      graphPoints: [102, 106, 110, 114, 119, 122, 125, 128, 130, 131],
    ),
  ],
];

WidgetbookComponent buildAnalyticsCardComponent() {
  return WidgetbookComponent(
    name: 'Analytics Card',
    useCases: [
      WidgetbookUseCase(
        name: 'Interactive',
        builder: (_) => const _InteractiveAnalyticsCard(),
      ),
    ],
  );
}

class _InteractiveAnalyticsCard extends StatefulWidget {
  const _InteractiveAnalyticsCard();

  @override
  State<_InteractiveAnalyticsCard> createState() =>
      _InteractiveAnalyticsCardState();
}

class _InteractiveAnalyticsCardState extends State<_InteractiveAnalyticsCard> {
  int _primaryIndex = 1;
  int _rangeIndex = 1;

  @override
  Widget build(BuildContext context) {
    final scenario = _scenarioMatrix[_primaryIndex][_rangeIndex];
    final rangeKey = _rangeOptions[_rangeIndex];
    final dateRangeLabel = _buildDateRangeLabel(rangeKey);

    return ExerciseAnalyticsCard(
      primarySegments: const [
        AnalyticsSegment(label: 'Global'),
        AnalyticsSegment(label: 'Exercises'),
      ],
      selectedPrimaryIndex: _primaryIndex,
      metric: scenario.metric,
      rangeLabels: _rangeOptions,
      selectedRangeIndex: _rangeIndex,
      graphPoints: scenario.graphPoints,
      onPrimarySegmentTap: (index) => setState(() => _primaryIndex = index),
      onSecondarySegmentTap: (index) => setState(() => _rangeIndex = index),
      dateRangeLabel: dateRangeLabel,
    );
  }
}

String _buildDateRangeLabel(String rangeKey) {
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day);
  final monthsBack = _rangeToMonths[rangeKey] ?? 1;
  final start = _subtractMonths(end, monthsBack);

  final dateFormat = DateFormat('MMM d');
  final startLabel = dateFormat.format(start);
  final endLabel = DateFormat('MMM d, yyyy').format(end);
  final hasDifferentYear = start.year != end.year;

  final startWithYear = hasDifferentYear
      ? '$startLabel, ${start.year}'
      : startLabel;

  return 'Past $rangeKey • $startWithYear – $endLabel';
}

DateTime _subtractMonths(DateTime date, int months) {
  var year = date.year;
  var month = date.month - months;

  while (month <= 0) {
    month += 12;
    year -= 1;
  }

  final day = math.min(date.day, _daysInMonth(year, month));
  return DateTime(year, month, day);
}

int _daysInMonth(int year, int month) {
  if (month == 12) {
    return DateTime(year + 1, 1, 0).day;
  }
  return DateTime(year, month + 1, 0).day;
}
