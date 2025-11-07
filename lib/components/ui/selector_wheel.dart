import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/heavyweight_theme.dart';
import 'dart:async';

class SelectorWheel extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final Function(int) onChanged;
  final String suffix;
  final String? semanticLabel;

  const SelectorWheel({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix = '',
    this.semanticLabel,
  });

  @override
  State<SelectorWheel> createState() => _SelectorWheelState();
}

class _SelectorWheelState extends State<SelectorWheel> {
  Timer? _timer;
  bool _isIncrementing = false;
  bool _isDecrementing = false;
  int _counter = 0;

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _isIncrementing = false;
    _isDecrementing = false;
    _counter = 0;
  }

  void _startIncrement() {
    if (widget.value >= widget.max) return;

    _isIncrementing = true;
    _counter = 0;

    // First increment immediately
    widget.onChanged(widget.value + 1);

    // Start timer for continuous increments
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isIncrementing || widget.value >= widget.max) {
        _cancelTimer();
        return;
      }

      _counter++;
      widget.onChanged(widget.value + 1);

      // Speed up after 10 increments
      if (_counter > 10 && timer.tick % 2 == 0) {
        // Skip every other tick to speed up
        return;
      }
    });
  }

  void _startDecrement() {
    if (widget.value <= widget.min) return;

    _isDecrementing = true;
    _counter = 0;

    // First decrement immediately
    widget.onChanged(widget.value - 1);

    // Start timer for continuous decrements
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isDecrementing || widget.value <= widget.min) {
        _cancelTimer();
        return;
      }

      _counter++;
      widget.onChanged(widget.value - 1);

      // Speed up after 10 decrements
      if (_counter > 10 && timer.tick % 2 == 0) {
        // Skip every other tick to speed up
        return;
      }
    });
  }

  void _handleSingleDecrement() {
    if (widget.value > widget.min) {
      try {
        HapticFeedback.selectionClick();
        widget.onChanged(widget.value - 1);
      } catch (error) {
        debugPrint('SelectorWheel decrement error: $error');
      }
    }
  }

  void _handleSingleIncrement() {
    if (widget.value < widget.max) {
      try {
        HapticFeedback.selectionClick();
        widget.onChanged(widget.value + 1);
      } catch (error) {
        debugPrint('SelectorWheel increment error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? 'Value selector',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left arrow (minus)
          Semantics(
            button: true,
            enabled: widget.value > widget.min,
            label:
                'Decrease ${widget.suffix.isEmpty ? 'value' : widget.suffix}',
            child: InkWell(
              onTap: widget.value > widget.min ? _handleSingleDecrement : null,
              onLongPress: widget.value > widget.min
                  ? () {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) _startDecrement();
                      });
                    }
                  : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.value > widget.min
                        ? HeavyweightTheme.primary
                        : HeavyweightTheme.textDisabled,
                  ),
                  color: widget.value > widget.min
                      ? (_isDecrementing
                          ? HeavyweightTheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent)
                      : HeavyweightTheme.surface,
                ),
                child: Icon(
                  Icons.remove,
                  color: widget.value > widget.min
                      ? HeavyweightTheme.primary
                      : HeavyweightTheme.textDisabled,
                  size: 24,
                ),
              ),
            ),
          ),

          const SizedBox(width: HeavyweightTheme.spacingMd),

          // Value display
          Semantics(
            value: '${widget.value} ${widget.suffix}',
            child: Container(
              width: 120,
              padding: const EdgeInsets.symmetric(
                  horizontal: HeavyweightTheme.spacingMd,
                  vertical: HeavyweightTheme.spacingSm),
              decoration: BoxDecoration(
                border: Border.all(color: HeavyweightTheme.primary, width: 2),
                color: HeavyweightTheme.primary.withValues(alpha: 0.05),
              ),
              child: Text(
                '${widget.value} ${widget.suffix}',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.h3.copyWith(
                  fontSize: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: HeavyweightTheme.spacingMd),

          // Right arrow (plus)
          Semantics(
            button: true,
            enabled: widget.value < widget.max,
            label:
                'Increase ${widget.suffix.isEmpty ? 'value' : widget.suffix}',
            child: InkWell(
              onTap: widget.value < widget.max ? _handleSingleIncrement : null,
              onLongPress: widget.value < widget.max
                  ? () {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) _startIncrement();
                      });
                    }
                  : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.value < widget.max
                        ? HeavyweightTheme.primary
                        : HeavyweightTheme.textDisabled,
                  ),
                  color: widget.value < widget.max
                      ? (_isIncrementing
                          ? HeavyweightTheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent)
                      : HeavyweightTheme.surface,
                ),
                child: Icon(
                  Icons.add,
                  color: widget.value < widget.max
                      ? HeavyweightTheme.primary
                      : HeavyweightTheme.textDisabled,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
