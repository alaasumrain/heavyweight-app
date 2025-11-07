import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/heavyweight_theme.dart';
import '../../../components/ui/warning_stripes.dart';
import '../../../core/logging.dart';

/// Flexible Rest Timer - Smart skip/extend based on context
/// Recovery is important, but so is practical training flow
class RestTimer extends StatefulWidget {
  final int restSeconds;
  final VoidCallback onComplete;
  final bool canSkip; // Allow early skip based on conditions
  final bool canExtend; // Allow extending rest time
  final String?
      lastSetPerformance; // 'below_mandate', 'within_mandate', 'above_mandate'

  const RestTimer({
    super.key,
    required this.restSeconds,
    required this.onComplete,
    this.canSkip = true, // Default to flexible
    this.canExtend = true,
    this.lastSetPerformance,
  });

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Timer _timer;
  late int _remainingSeconds;
  late int _originalRestSeconds; // Track original time for extend calculations
  bool _isExtended = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.restSeconds;
    _originalRestSeconds = widget.restSeconds;

    HWLog.event('rest_timer_init', data: {
      'restSeconds': widget.restSeconds,
      'canSkip': widget.canSkip,
      'canExtend': widget.canExtend,
      'lastSetPerformance': widget.lastSetPerformance ?? 'unknown',
    });

    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Pulse animation for urgency
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start countdown
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        HWLog.event('rest_timer_complete', data: {
          'originalSeconds': _originalRestSeconds,
          'wasExtended': _isExtended,
        });
        _timer.cancel();
        _pulseController.stop();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background - pause timer
        _pauseTimer();
        break;
      case AppLifecycleState.resumed:
        // App returning to foreground - resume timer
        _resumeTimer();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App being terminated or hidden
        _pauseTimer();
        break;
    }
  }

  void _pauseTimer() {
    if (_timer.isActive) {
      HWLog.event('rest_timer_pause', data: {
        'remainingSeconds': _remainingSeconds,
        'pausedAt': DateTime.now().toIso8601String(),
      });
      _timer.cancel();
      _pausedAt = DateTime.now();
      _pulseController.stop();
    }
  }

  void _resumeTimer() {
    if (_pausedAt != null) {
      // Calculate time elapsed while paused
      final timeElapsed = DateTime.now().difference(_pausedAt!).inSeconds;
      final oldRemaining = _remainingSeconds;

      // Subtract elapsed time from remaining seconds
      _remainingSeconds =
          (_remainingSeconds - timeElapsed).clamp(0, _originalRestSeconds);
      _pausedAt = null;

      HWLog.event('rest_timer_resume', data: {
        'timeElapsedWhilePaused': timeElapsed,
        'remainingBefore': oldRemaining,
        'remainingAfter': _remainingSeconds,
        'timerCompleted': _remainingSeconds <= 0,
      });

      // Restart timer if time remaining
      if (_remainingSeconds > 0) {
        _startTimer();
        if (_remainingSeconds <= 10) {
          _pulseController.repeat(reverse: true);
        }
      } else {
        // Timer completed while away
        HWLog.event('rest_timer_completed_while_paused');
        widget.onComplete();
      }

      if (mounted) {
        setState(() {});
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _progress => 1 - (_remainingSeconds / widget.restSeconds);

  /// Skip rest early (with conditions)
  void _skipRest() {
    HWLog.event('rest_timer_skip', data: {
      'remainingSeconds': _remainingSeconds,
      'originalSeconds': _originalRestSeconds,
      'skippedSeconds': _remainingSeconds,
      'reason': _getSkipReason(),
      'lastSetPerformance': widget.lastSetPerformance ?? 'unknown',
    });
    _timer.cancel();
    _pulseController.stop();
    widget.onComplete();
  }

  /// Extend rest time by 30 seconds
  void _extendRest() {
    HWLog.event('rest_timer_extend', data: {
      'remainingSeconds': _remainingSeconds,
      'extendedBy': 30,
      'newTotal': _remainingSeconds + 30,
      'lastSetPerformance': widget.lastSetPerformance ?? 'unknown',
    });
    setState(() {
      _remainingSeconds += 30;
      _isExtended = true;
    });
  }

  /// Check if skip is allowed based on conditions
  bool get _canSkipNow {
    if (!widget.canSkip) return false;

    // Always allow skip if more than half the time is left and performance was good
    if (_remainingSeconds > (_originalRestSeconds * 0.5) &&
        widget.lastSetPerformance == 'within_mandate') {
      return true;
    }

    // Allow skip in final 30 seconds regardless of performance
    if (_remainingSeconds <= 30) return true;

    // Allow skip if last set exceeded mandate (feeling strong)
    if (widget.lastSetPerformance == 'above_mandate' &&
        _remainingSeconds > 15) {
      return true;
    }

    return false;
  }

  /// Check if extend is recommended based on last performance
  bool get _shouldRecommendExtend {
    if (!widget.canExtend || _isExtended) return false;

    // Recommend extend if last set was below mandate
    return widget.lastSetPerformance == 'below_mandate';
  }

  Color _getTimerColor() {
    if (_remainingSeconds <= 10) {
      return Colors.white; // White - ready
    } else if (_remainingSeconds <= 30) {
      return Colors.amber; // Warning
    } else {
      return Colors.red; // Rest required
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerColor = _getTimerColor();

    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Warning stripes when timer is complete or in final countdown
          if (_remainingSeconds <= 0 || _remainingSeconds <= 30)
            WarningStripes.warning(
              height: 50,
              text: _remainingSeconds <= 0
                  ? 'READY TO CONTINUE'
                  : _remainingSeconds <= 10
                      ? 'LOCK IN'
                      : 'ALMOST THERE',
              animated: _remainingSeconds <= 0,
            ),

          if (_remainingSeconds <= 0 || _remainingSeconds <= 30)
            const SizedBox(height: 20),

          // REST MANDATORY text
          Text(
            _remainingSeconds <= 0 ? 'REST COMPLETE' : 'REST IN PROGRESS',
            style: TextStyle(
              color: _remainingSeconds <= 0 ? Colors.white : Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 40),

          // Circular timer
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 8,
                  backgroundColor: HeavyweightTheme.secondary,
                  valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                ),
              ),

              // Timer display
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        _remainingSeconds <= 10 ? _pulseAnimation.value : 1.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatTime(_remainingSeconds),
                            style: HeavyweightTheme.h1.copyWith(
                              fontSize: 64,
                              color: timerColor,
                              letterSpacing: 4,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        Text(
                          'TIME LEFT',
                          style: TextStyle(
                            color: HeavyweightTheme.textSecondary,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recovery message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _getRecoveryMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Smart controls based on context
          Column(
            children: [
              // Skip button - appears when conditions are met
              if (_canSkipNow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _skipRest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.skip_next, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _getSkipReason(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              // Extend button - appears when recommended
              if (_shouldRecommendExtend)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: OutlinedButton(
                    onPressed: _extendRest,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_alarm, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'ADD +30s (COACH SAYS REST)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Status indicator
              if (_isExtended)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade800),
                      color: Colors.orange.shade900.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'REST EXTENDED +30s',
                      style: TextStyle(
                        color: Colors.orange.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

              // Rigid mode indicator
              if (!widget.canSkip && !widget.canExtend)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade900, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: Colors.red.shade900, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'RECOVERY LOCKED IN',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRecoveryMessage() {
    if (_remainingSeconds > 120) {
      return 'Deep breaths. Let your muscles reload energy so the next set moves with authority.';
    } else if (_remainingSeconds > 60) {
      return 'Reset your stance, chalk up, and stay loose. Quality reps live in this window.';
    } else if (_remainingSeconds > 30) {
      return 'Walk through your cues now—bar path, tempo, lockout. You are almost up.';
    } else if (_remainingSeconds > 10) {
      return 'Two more breaths. Visualize the first rep hitting clean.';
    } else {
      return 'Stand tall. It is go time.';
    }
  }

  String _getSkipReason() {
    if (widget.lastSetPerformance == 'above_mandate') {
      return 'SKIP • FEELING STRONG';
    } else if (_remainingSeconds <= 30) {
      return 'SKIP • TIMER READY';
    } else if (widget.lastSetPerformance == 'within_mandate') {
      return 'SKIP • HIT TARGETS';
    }
    return 'SKIP REST';
  }
}
