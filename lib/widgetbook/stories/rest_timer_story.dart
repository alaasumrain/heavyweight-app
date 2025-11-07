import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/rest_timer_header.dart';

WidgetbookComponent buildRestTimerComponent() {
  return WidgetbookComponent(
    name: 'Rest Timer Header',
    useCases: [
      WidgetbookUseCase(
        name: 'Interactive',
        builder: (_) => const _InteractiveRestTimer(),
      ),
    ],
  );
}

class _InteractiveRestTimer extends StatefulWidget {
  const _InteractiveRestTimer();

  @override
  State<_InteractiveRestTimer> createState() => _InteractiveRestTimerState();
}

class _InteractiveRestTimerState extends State<_InteractiveRestTimer> {
  Duration _remaining = const Duration(minutes: 1, seconds: 30);
  final Duration _elapsed = const Duration(minutes: 6, seconds: 20);
  bool _paused = false;
  int _stepIndex = 2;

  void _adjust(int seconds) {
    setState(() {
      final newSeconds = (_remaining.inSeconds + seconds).clamp(0, 9999);
      _remaining = Duration(seconds: newSeconds);
    });
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
  }

  @override
  Widget build(BuildContext context) {
    return RestTimerHeader(
      remaining: _remaining,
      elapsed: _elapsed,
      stepIndex: _stepIndex,
      totalSteps: 17,
      isPaused: _paused,
      onSubtractTime: () => _adjust(-15),
      onAddTime: () => _adjust(15),
      onSkip: _togglePause,
      onBack: () {
        if (_stepIndex > 1) {
          setState(() => _stepIndex--);
        }
      },
      onFinish: () {
        setState(() {
          _stepIndex = 17;
          _remaining = Duration.zero;
        });
      },
      onMenu: () {},
    );
  }
}
