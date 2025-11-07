import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/heavyweight_theme.dart';
import 'command_button.dart';

class CompletionSummaryMetric {
  const CompletionSummaryMetric({
    required this.value,
    required this.label,
    this.isOptional = false,
  });

  final String value;
  final String label;
  final bool isOptional;
}

class CompletionSummaryData {
  const CompletionSummaryData({
    required this.dayLabel,
    required this.dateLabel,
    required this.metrics,
    this.brandLabel,
    this.secondaryLabel,
    this.caption,
  });

  final String dayLabel;
  final String dateLabel;
  final List<CompletionSummaryMetric> metrics;
  final String? brandLabel;
  final String? secondaryLabel;
  final String? caption;
}

class CompletionSummarySheet extends StatelessWidget {
  const CompletionSummarySheet({
    super.key,
    required this.summary,
    required this.title,
    required this.message,
    required this.showPersonalRecord,
    required this.blurBackground,
    this.currentCardIndex = 0,
    this.cardCount = 1,
    this.onShowPersonalRecordChanged,
    this.onBlurBackgroundChanged,
    this.onCopy,
    this.onClose,
    this.onCardSelected,
  }) : assert(cardCount > 0, 'cardCount must be greater than zero');

  final CompletionSummaryData summary;
  final String title;
  final String message;
  final bool showPersonalRecord;
  final bool blurBackground;
  final int currentCardIndex;
  final int cardCount;
  final ValueChanged<bool>? onShowPersonalRecordChanged;
  final ValueChanged<bool>? onBlurBackgroundChanged;
  final VoidCallback? onCopy;
  final VoidCallback? onClose;
  final ValueChanged<int>? onCardSelected;

  @override
  Widget build(BuildContext context) {
    final background = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE6121212), Color(0xF0101010)],
        ),
      ),
    );

    return Stack(
      children: [
        Positioned.fill(child: background),
        if (blurBackground)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ),
        Positioned.fill(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompactHeight = constraints.maxHeight < 740;
                    final double outerVerticalPadding = isCompactHeight
                        ? HeavyweightTheme.spacingLg
                        : HeavyweightTheme.spacingXxl;
                    final double innerPadding = isCompactHeight
                        ? HeavyweightTheme.spacingLg
                        : HeavyweightTheme.spacingXl;
                    final double gapLarge = isCompactHeight
                        ? HeavyweightTheme.spacingLg
                        : HeavyweightTheme.spacingXl;
                    final double gapMedium = isCompactHeight
                        ? HeavyweightTheme.spacingSm
                        : HeavyweightTheme.spacingMd;
                    final double gapSmall = HeavyweightTheme.spacingSm;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: HeavyweightTheme.spacingLg,
                        vertical: outerVerticalPadding,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(innerPadding),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: _CloseButton(onPressed: onClose),
                                      ),
                                      SizedBox(height: gapLarge),
                                      Text(
                                        title,
                                        textAlign: TextAlign.center,
                                        style: HeavyweightTheme.h2.copyWith(
                                          fontSize: isCompactHeight ? 24 : 28,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: gapSmall),
                                      Text(
                                        message,
                                        textAlign: TextAlign.center,
                                        style: HeavyweightTheme.bodyMedium
                                            .copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      SizedBox(height: gapLarge),
                                      _SummaryCard(
                                        summary: summary,
                                        showPersonalRecord: showPersonalRecord,
                                        isCompact: isCompactHeight,
                                      ),
                                      if (cardCount > 1)
                                        Padding(
                                          padding:
                                              EdgeInsets.only(top: gapMedium),
                                          child: _PageIndicators(
                                            activeIndex: currentCardIndex,
                                            count: cardCount,
                                            onSelected: onCardSelected,
                                          ),
                                        ),
                                      SizedBox(height: gapLarge),
                                      _ToggleRow(
                                        label: 'Show PR',
                                        value: showPersonalRecord,
                                        onChanged: onShowPersonalRecordChanged,
                                      ),
                                      SizedBox(height: gapMedium),
                                      _ToggleRow(
                                        label: 'Blur Background',
                                        value: blurBackground,
                                        onChanged: onBlurBackgroundChanged,
                                      ),
                                      SizedBox(height: gapMedium),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: gapLarge),
                              CommandButton(
                                text: 'Copy',
                                onPressed: onCopy,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.showPersonalRecord,
    required this.isCompact,
  });

  final CompletionSummaryData summary;
  final bool showPersonalRecord;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final visibleMetrics = summary.metrics
        .where((metric) => showPersonalRecord || !metric.isOptional)
        .toList();

    final double cardPadding =
        isCompact ? HeavyweightTheme.spacingLg : HeavyweightTheme.spacingXl;
    final double gapLarge =
        isCompact ? HeavyweightTheme.spacingLg : HeavyweightTheme.spacingXl;
    final double gapMedium =
        isCompact ? HeavyweightTheme.spacingSm : HeavyweightTheme.spacingSm;
    final double metricsSpacing =
        isCompact ? HeavyweightTheme.spacingMd : HeavyweightTheme.spacingXl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: cardPadding,
        vertical: cardPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F1F1F), Color(0xFF141414)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            summary.dayLabel,
            style: HeavyweightTheme.labelMedium.copyWith(
              color: Colors.white60,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: gapMedium),
          Text(
            summary.dateLabel,
            textAlign: TextAlign.center,
            style: HeavyweightTheme.h1.copyWith(
              fontSize: isCompact ? 32 : 36,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          if (summary.caption != null) ...[
            SizedBox(height: gapMedium),
            Text(
              summary.caption!,
              style: HeavyweightTheme.bodySmall.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
          SizedBox(height: gapLarge),
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: metricsSpacing,
            spacing: metricsSpacing,
            children: [
              for (final metric in visibleMetrics) _MetricTile(metric: metric),
            ],
          ),
          SizedBox(height: gapLarge),
          if (summary.brandLabel != null)
            Text(
              summary.brandLabel!,
              style: HeavyweightTheme.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (summary.secondaryLabel != null) ...[
            SizedBox(height: gapMedium),
            Text(
              summary.secondaryLabel!,
              style: HeavyweightTheme.bodySmall.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final CompletionSummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.value,
            textAlign: TextAlign.center,
            style: HeavyweightTheme.h3.copyWith(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingXs),
          Text(
            metric.label,
            textAlign: TextAlign.center,
            style: HeavyweightTheme.bodySmall.copyWith(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: HeavyweightTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xFF2BCB70)
                : Colors.white,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xFF157A40)
                : Colors.white24,
          ),
          trackOutlineColor: WidgetStateProperty.all(Colors.white24),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.close, color: Colors.white70),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.06),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(HeavyweightTheme.spacingSm),
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  const _PageIndicators({
    required this.activeIndex,
    required this.count,
    this.onSelected,
  });

  final int activeIndex;
  final int count;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++)
          GestureDetector(
            onTap: onSelected == null ? null : () => onSelected!(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(
                horizontal: HeavyweightTheme.spacingXs,
              ),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == activeIndex ? Colors.white : Colors.white24,
              ),
            ),
          ),
      ],
    );
  }
}
