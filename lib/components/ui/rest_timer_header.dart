import 'package:flutter/material.dart';

import '../../core/theme/heavyweight_theme.dart';

class RestTimerHeader extends StatelessWidget {
  const RestTimerHeader({
    super.key,
    required this.remaining,
    required this.elapsed,
    required this.stepIndex,
    required this.totalSteps,
    this.isPaused = false,
    this.statusLabel,
    this.onBack,
    this.onMenu,
    this.onFinish,
    this.onSkip,
    this.onAddTime,
    this.onSubtractTime,
  });

  final Duration remaining;
  final Duration elapsed;
  final int stepIndex;
  final int totalSteps;
  final bool isPaused;
  final String? statusLabel;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final VoidCallback? onFinish;
  final VoidCallback? onSkip;
  final VoidCallback? onAddTime;
  final VoidCallback? onSubtractTime;

  @override
  Widget build(BuildContext context) {
    final statusText = statusLabel ?? (isPaused ? 'Paused' : 'Resting');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HeavyweightTheme.spacingXl,
          vertical: HeavyweightTheme.spacingXxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    _CircleControlButton(
                      icon: Icons.chevron_left,
                      onPressed: onBack,
                    ),
                    const SizedBox(width: HeavyweightTheme.spacingSm),
                    _CircleControlButton(
                      icon: Icons.more_horiz,
                      onPressed: onMenu,
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$stepIndex / $totalSteps',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: HeavyweightTheme.spacingXs),
                    Text(
                      _formatDuration(elapsed),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white38,
                            letterSpacing: 2,
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                _FinishButton(onPressed: onFinish),
              ],
            ),
            const SizedBox(height: HeavyweightTheme.spacingXl),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Text(
                _formatDuration(remaining),
                key: ValueKey<int>(remaining.inSeconds),
                style: HeavyweightTheme.timerDisplay,
              ),
            ),
            const SizedBox(height: HeavyweightTheme.spacingMd),
            Text(
              statusText.toUpperCase(),
              style: HeavyweightTheme.caption.copyWith(color: Colors.white60),
            ),
            const SizedBox(height: HeavyweightTheme.spacingXl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AdjustRestButton(
                  label: '-15',
                  icon: Icons.rotate_left,
                  onPressed: onSubtractTime,
                ),
                const SizedBox(width: HeavyweightTheme.spacingXl),
                _SkipButton(
                  label: isPaused ? 'Resume' : 'Skip',
                  onPressed: onSkip,
                ),
                const SizedBox(width: HeavyweightTheme.spacingXl),
                _AdjustRestButton(
                  label: '+15',
                  icon: Icons.rotate_right,
                  onPressed: onAddTime,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration value) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(value.inMinutes.remainder(60));
    final seconds = twoDigits(value.inSeconds.remainder(60));
    final hours = value.inHours;
    if (hours > 0) {
      return '${twoDigits(hours)}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _CircleControlButton extends StatelessWidget {
  const _CircleControlButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        backgroundColor: Colors.white12,
        foregroundColor: Colors.white,
      ),
      child: Icon(icon, size: 22),
    );
  }
}

class _FinishButton extends StatelessWidget {
  const _FinishButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.white12,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: HeavyweightTheme.spacingXl,
          vertical: HeavyweightTheme.spacingSm,
        ),
        shape: const StadiumBorder(),
      ),
      child: Text(
        'Finish',
        style: HeavyweightTheme.labelMedium.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}

class _AdjustRestButton extends StatelessWidget {
  const _AdjustRestButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(14),
            backgroundColor: Colors.white12,
            foregroundColor: Colors.white,
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: HeavyweightTheme.spacingXs),
        Text(
          label,
          style: HeavyweightTheme.labelSmall.copyWith(
            color: Colors.white70,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: HeavyweightTheme.spacingXl,
          vertical: HeavyweightTheme.spacingSm,
        ),
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: HeavyweightTheme.labelMedium.copyWith(
          color: Colors.black,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
