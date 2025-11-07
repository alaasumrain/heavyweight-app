import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/completion_summary_sheet.dart';

WidgetbookComponent buildCompletionSummaryCardComponent() {
  return WidgetbookComponent(
    name: 'Summary Card',
    useCases: [
      WidgetbookUseCase(
        name: 'Standard Workout',
        builder: (_) => const _StandardWorkoutCard(),
      ),
      WidgetbookUseCase(
        name: 'Personal Record',
        builder: (_) => const _PersonalRecordCard(),
      ),
      WidgetbookUseCase(
        name: 'Quick Session',
        builder: (_) => const _QuickSessionCard(),
      ),
      WidgetbookUseCase(
        name: 'With/Without PR Toggle',
        builder: (_) => const _InteractiveCard(),
      ),
    ],
  );
}

class _StandardWorkoutCard extends StatelessWidget {
  const _StandardWorkoutCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CompletionSummarySheet(
          summary: const CompletionSummaryData(
            dayLabel: 'Tuesday',
            dateLabel: '28 September',
            caption: 'Week 39 session',
            metrics: [
              CompletionSummaryMetric(value: '18', label: 'Sets'),
              CompletionSummaryMetric(value: '2.4 Tons', label: 'Volume'),
              CompletionSummaryMetric(value: '47 min', label: 'Time'),
              CompletionSummaryMetric(
                value: '1',
                label: 'PR',
                isOptional: true,
              ),
            ],
            brandLabel: 'Heavyweight',
            secondaryLabel: 'Push Day Complete',
          ),
          title: 'Workout Complete',
          message: 'Great session today',
          showPersonalRecord: true,
          blurBackground: false,
          onCopy: () {},
          onClose: () {},
        ),
      ),
    );
  }
}

class _PersonalRecordCard extends StatelessWidget {
  const _PersonalRecordCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CompletionSummarySheet(
          summary: const CompletionSummaryData(
            dayLabel: 'Friday',
            dateLabel: '1 October',
            caption: 'New personal best!',
            metrics: [
              CompletionSummaryMetric(value: '22', label: 'Sets'),
              CompletionSummaryMetric(value: '3.1 Tons', label: 'Volume'),
              CompletionSummaryMetric(value: '62 min', label: 'Time'),
              CompletionSummaryMetric(
                value: '3',
                label: 'PR',
                isOptional: true,
              ),
            ],
            brandLabel: 'Lift',
            secondaryLabel: 'Beast Mode Activated',
          ),
          title: 'Personal Records!',
          message: 'You crushed it today - 3 new PRs!',
          showPersonalRecord: true,
          blurBackground: false,
          onCopy: () {},
          onClose: () {},
        ),
      ),
    );
  }
}

class _QuickSessionCard extends StatelessWidget {
  const _QuickSessionCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CompletionSummarySheet(
          summary: const CompletionSummaryData(
            dayLabel: 'Sunday',
            dateLabel: '3 October',
            caption: 'Quick session',
            metrics: [
              CompletionSummaryMetric(value: '8', label: 'Sets'),
              CompletionSummaryMetric(value: '0.9 Tons', label: 'Volume'),
              CompletionSummaryMetric(value: '23 min', label: 'Time'),
              CompletionSummaryMetric(
                value: '0',
                label: 'PR',
                isOptional: true,
              ),
            ],
            brandLabel: 'Fortress',
            secondaryLabel: 'Recovery Session',
          ),
          title: 'Session Complete',
          message: 'Perfect recovery workout',
          showPersonalRecord: false,
          blurBackground: false,
          onCopy: () {},
          onClose: () {},
        ),
      ),
    );
  }
}

class _InteractiveCard extends StatefulWidget {
  const _InteractiveCard();

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> {
  bool _showPR = true;
  bool _blurBackground = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CompletionSummarySheet(
          summary: const CompletionSummaryData(
            dayLabel: 'Wednesday',
            dateLabel: '29 September',
            caption: 'Leg day conquered',
            metrics: [
              CompletionSummaryMetric(value: '16', label: 'Sets'),
              CompletionSummaryMetric(value: '4.2 Tons', label: 'Volume'),
              CompletionSummaryMetric(value: '58 min', label: 'Time'),
              CompletionSummaryMetric(
                value: '2',
                label: 'PR',
                isOptional: true,
              ),
            ],
            brandLabel: 'Heavyweight',
            secondaryLabel: 'Legs Destroyed',
          ),
          title: 'Share Your Victory',
          message: 'Show off your leg day domination',
          showPersonalRecord: _showPR,
          blurBackground: _blurBackground,
          onShowPersonalRecordChanged: (value) => setState(() => _showPR = value),
          onBlurBackgroundChanged: (value) => setState(() => _blurBackground = value),
          onCopy: () {},
          onClose: () {},
        ),
      ),
    );
  }
}
