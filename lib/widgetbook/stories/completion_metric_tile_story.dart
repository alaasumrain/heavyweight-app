import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/completion_summary_sheet.dart';

WidgetbookComponent buildCompletionMetricTileComponent() {
  return WidgetbookComponent(
    name: 'Metric Tile',
    useCases: [
      WidgetbookUseCase(
        name: 'Individual Metrics',
        builder: (_) => const _IndividualMetrics(),
      ),
      WidgetbookUseCase(
        name: 'Different Value Types',
        builder: (_) => const _DifferentValueTypes(),
      ),
      WidgetbookUseCase(
        name: 'Metric Groups',
        builder: (_) => const _MetricGroups(),
      ),
      WidgetbookUseCase(
        name: 'Optional vs Required',
        builder: (_) => const _OptionalVsRequired(),
      ),
    ],
  );
}

class _IndividualMetrics extends StatelessWidget {
  const _IndividualMetrics();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Individual Metric Tiles',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '18', label: 'Sets'),
                ),
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '2.4 Tons', label: 'Volume'),
                ),
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '47 min', label: 'Time'),
                ),
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '2', label: 'PR'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DifferentValueTypes extends StatelessWidget {
  const _DifferentValueTypes();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Different Value Types',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Wrap(
              spacing: 20,
              runSpacing: 16,
              children: [
                // Numbers
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '0', label: 'Rest Days'),
                ),
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '142', label: 'Total Reps'),
                ),
                
                // Weights
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '85 Kg', label: 'Max Lift'),
                ),
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '1.2 T', label: 'Volume'),
                ),
                
                // Time
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '1h 23m', label: 'Duration'),
                ),
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '90s', label: 'Avg Rest'),
                ),
                
                // Percentages
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '94%', label: 'Completion'),
                ),
                _MetricTileWrapper(
                  metric: CompletionSummaryMetric(value: '+12%', label: 'Improvement'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricGroups extends StatelessWidget {
  const _MetricGroups();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Metric Groups',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Workout basics
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: const Column(
                children: [
                  Text(
                    'WORKOUT BASICS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(value: '16', label: 'Sets'),
                      ),
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(value: '52 min', label: 'Time'),
                      ),
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(value: '6', label: 'Exercises'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Performance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[900]?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[800]!),
              ),
              child: const Column(
                children: [
                  Text(
                    'PERFORMANCE',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(value: '3.2 T', label: 'Volume'),
                      ),
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(value: '3', label: 'PR'),
                      ),
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(value: '+8%', label: 'Gain'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionalVsRequired extends StatelessWidget {
  const _OptionalVsRequired();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Optional vs Required Metrics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Optional metrics can be hidden based on user preference',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            
            // Required metrics
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[900]?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[800]!),
              ),
              child: const Column(
                children: [
                  Text(
                    'ALWAYS SHOWN',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(value: '14', label: 'Sets'),
                      ),
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(value: '2.1 T', label: 'Volume'),
                      ),
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(value: '41 min', label: 'Time'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Optional metrics
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[900]?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[800]!),
              ),
              child: const Column(
                children: [
                  Text(
                    'OPTIONAL (CAN BE HIDDEN)',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(
                          value: '1',
                          label: 'PR',
                          isOptional: true,
                        ),
                      ),
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(
                          value: '95%',
                          label: 'Accuracy',
                          isOptional: true,
                        ),
                      ),
                      _MetricTileWrapper(
                        metric: CompletionSummaryMetric(
                          value: '142',
                          label: 'Total Reps',
                          isOptional: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper wrapper to display metric tiles in isolation
class _MetricTileWrapper extends StatelessWidget {
  const _MetricTileWrapper({required this.metric});

  final CompletionSummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: metric.isOptional ? Colors.orange[800]! : Colors.grey[700]!,
        ),
      ),
      child: SizedBox(
        width: 96,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              metric.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
