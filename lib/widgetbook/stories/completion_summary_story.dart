import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/completion_summary_sheet.dart';

WidgetbookComponent buildCompletionSummaryComponent() {
  return WidgetbookComponent(
    name: 'Completion Summary',
    useCases: [
      WidgetbookUseCase(
        name: 'Share Sheet',
        builder: (_) => const _InteractiveCompletionSummary(),
      ),
    ],
  );
}

class _InteractiveCompletionSummary extends StatefulWidget {
  const _InteractiveCompletionSummary();

  @override
  State<_InteractiveCompletionSummary> createState() =>
      _InteractiveCompletionSummaryState();
}

class _InteractiveCompletionSummaryState
    extends State<_InteractiveCompletionSummary> {
  bool _showPersonalRecord = true;
  bool _blurBackground = false;
  int _cardIndex = 0;

  static const List<CompletionSummaryData> _cards = [
    CompletionSummaryData(
      dayLabel: 'Saturday',
      dateLabel: '27 September',
      caption: 'Week 38 session',
      metrics: [
        CompletionSummaryMetric(value: '4', label: 'Sets'),
        CompletionSummaryMetric(value: '0 Kg', label: 'Volume'),
        CompletionSummaryMetric(value: '0 min', label: 'Time'),
        CompletionSummaryMetric(
          value: '0',
          label: 'PR',
          isOptional: true,
        ),
      ],
      brandLabel: 'Lift.',
      secondaryLabel: 'Heavyweight Training',
    ),
    CompletionSummaryData(
      dayLabel: 'Highlights',
      dateLabel: 'Top Efforts',
      caption: 'Your best sets today',
      metrics: [
        CompletionSummaryMetric(value: '110 Kg', label: 'Deadlift'),
        CompletionSummaryMetric(value: '18', label: 'Sets'),
        CompletionSummaryMetric(value: '57 min', label: 'Session'),
        CompletionSummaryMetric(
          value: '2',
          label: 'PR',
          isOptional: true,
        ),
      ],
      brandLabel: 'Heavyweight',
      secondaryLabel: 'Mandate complete',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _cards[_cardIndex];

    return Material(
      color: Colors.black,
      child: CompletionSummarySheet(
        summary: current,
        title: 'Share your workout',
        message:
            'Celebrate your workout wins. Copy this card and post it anywhere',
        showPersonalRecord: _showPersonalRecord,
        blurBackground: _blurBackground,
        currentCardIndex: _cardIndex,
        cardCount: _cards.length,
        onShowPersonalRecordChanged: (value) {
          setState(() => _showPersonalRecord = value);
        },
        onBlurBackgroundChanged: (value) {
          setState(() => _blurBackground = value);
        },
        onCardSelected: (index) {
          setState(() => _cardIndex = index);
        },
        onCopy: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout card copied to clipboard')),
          );
        },
        onClose: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Close tapped')),
          );
        },
      ),
    );
  }
}
