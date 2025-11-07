import 'package:flutter/material.dart';

import '../../core/theme/heavyweight_theme.dart';

class AnalyticsSegment {
  const AnalyticsSegment({required this.label});

  final String label;
}

class AnalyticsMetric {
  const AnalyticsMetric({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.unit,
    this.deltaPercent,
  });

  final String title;
  final String subtitle;
  final String value;
  final String unit;
  final double? deltaPercent;
}

class ExerciseAnalyticsCard extends StatelessWidget {
  const ExerciseAnalyticsCard({
    super.key,
    required this.primarySegments,
    required this.selectedPrimaryIndex,
    required this.metric,
    required this.rangeLabels,
    required this.selectedRangeIndex,
    required this.graphPoints,
    this.onPrimarySegmentTap,
    this.onSecondarySegmentTap,
    this.dateRangeLabel,
  });

  final List<AnalyticsSegment> primarySegments;
  final int selectedPrimaryIndex;
  final AnalyticsMetric metric;
  final List<String> rangeLabels;
  final int selectedRangeIndex;
  final List<double> graphPoints;
  final ValueChanged<int>? onPrimarySegmentTap;
  final ValueChanged<int>? onSecondarySegmentTap;
  final String? dateRangeLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 16),
            blurRadius: 24,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SegmentedToggle(
                  labels: primarySegments.map((s) => s.label).toList(),
                  selectedIndex: selectedPrimaryIndex,
                  onTap: onPrimarySegmentTap,
                ),
              ],
            ),
            const SizedBox(height: HeavyweightTheme.spacingLg),
            _RangeSelector(
              labels: rangeLabels,
              selectedIndex: selectedRangeIndex,
              onTap: onSecondarySegmentTap,
            ),
            if (dateRangeLabel != null) ...[
              const SizedBox(height: HeavyweightTheme.spacingXs),
              Text(
                dateRangeLabel!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black45,
                    ),
              ),
            ],
            const SizedBox(height: HeavyweightTheme.spacingXl),
            Text(
              metric.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: HeavyweightTheme.spacingXs),
            Text(
              metric.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black45,
                  ),
            ),
            const SizedBox(height: HeavyweightTheme.spacingLg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  metric.value,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(width: HeavyweightTheme.spacingXs),
                Text(
                  metric.unit,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black45,
                      ),
                ),
                if (metric.deltaPercent != null) ...[
                  const SizedBox(width: HeavyweightTheme.spacingSm),
                  _DeltaChip(delta: metric.deltaPercent!),
                ],
              ],
            ),
            const SizedBox(height: HeavyweightTheme.spacingXl),
            _LineChart(points: graphPoints),
            const SizedBox(height: HeavyweightTheme.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _MetricPill(label: '1RM'),
                _MetricPill(label: 'Max Weight', isDisabled: true),
                _MetricPill(label: 'Volume', isDisabled: true),
                _MetricPill(label: 'Total Reps', isDisabled: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.labels,
    required this.selectedIndex,
    this.onTap,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: HeavyweightTheme.surfaceLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => onTap?.call(i),
              child: Container(
                decoration: BoxDecoration(
                  color: i == selectedIndex ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: HeavyweightTheme.spacingLg,
                  vertical: HeavyweightTheme.spacingSm,
                ),
                child: Text(
                  labels[i],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            i == selectedIndex ? Colors.black : Colors.black45,
                        fontWeight: i == selectedIndex
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.labels,
    required this.selectedIndex,
    this.onTap,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          GestureDetector(
            onTap: () => onTap?.call(i),
            child: Container(
              decoration: BoxDecoration(
                color: i == selectedIndex ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: HeavyweightTheme.spacingLg,
                vertical: HeavyweightTheme.spacingSm,
              ),
              child: Text(
                labels[i],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: i == selectedIndex ? Colors.white : Colors.black26,
                    ),
              ),
            ),
          ),
          if (i != labels.length - 1)
            const SizedBox(width: HeavyweightTheme.spacingSm),
        ],
      ],
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    final isPositive = delta >= 0;
    final color = isPositive ? HeavyweightTheme.accentNeon : Colors.redAccent;
    final Color backgroundColor =
        isPositive ? const Color(0x265FFB7F) : const Color(0x26FF1744);
    final icon = isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: HeavyweightTheme.spacingSm,
        vertical: HeavyweightTheme.spacingXs,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          Text(
            '${delta.abs().toStringAsFixed(2)}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, this.isDisabled = false});

  final String label;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isDisabled ? Colors.black26 : Colors.black,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.points});

  final List<double> points;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: CustomPaint(
          painter: _LineChartPainter(points: points),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.points});

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    final paintLine = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintPoints = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    final maxValue = points.reduce((a, b) => a > b ? a : b);
    final minValue = points.reduce((a, b) => a < b ? a : b);
    final double range =
        (maxValue - minValue).abs() < 0.001 ? 1 : (maxValue - minValue);

    for (var i = 0; i < points.length; i++) {
      final normalized = (points[i] - minValue) / range;
      final x = i / (points.length - 1) * size.width;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, paintPoints);
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
