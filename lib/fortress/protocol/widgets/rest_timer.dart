import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/heavyweight_theme.dart';
import '../../../components/ui/warning_stripes.dart';

/// Flexible Rest Timer - Smart skip/extend based on context
/// Recovery is important, but so is practical training flow
class RestTimer extends StatefulWidget {
  final int restSeconds;
  final VoidCallback onComplete;
  final bool canSkip; // Allow early skip based on conditions
  final bool canExtend; // Allow extending rest time
  final String? lastSetPerformance; // 'below_mandate', 'within_mandate', 'above_mandate'
  
  const RestTimer({
    Key? key,
    required this.restSeconds,
    required this.onComplete,
    this.canSkip = true, // Default to flexible
    this.canExtend = true,
    this.lastSetPerformance,
  }) : super(key: key);
  
  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late int _remainingSeconds;
  late int _originalRestSeconds; // Track original time for extend calculations
  bool _isExtended = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.restSeconds;
    _originalRestSeconds = widget.restSeconds;
    
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
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
    super.dispose();
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  double get _progress => 1 - (_remainingSeconds / widget.restSeconds);
  
  /// Skip rest early (with conditions)
  void _skipRest() {
    _timer.cancel();
    _pulseController.stop();
    widget.onComplete();
  }
  
  /// Extend rest time by 30 seconds
  void _extendRest() {
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
    if (widget.lastSetPerformance == 'above_mandate' && _remainingSeconds > 15) {
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
                  ? 'CONTINUE_PROTOCOL' 
                  : _remainingSeconds <= 10
                      ? 'PREPARE_TO_LIFT'
                      : 'ALMOST_READY',
              animated: _remainingSeconds <= 0,
            ),
          
          if (_remainingSeconds <= 0 || _remainingSeconds <= 30)
            const SizedBox(height: 20),
          
          // REST MANDATORY text
          Text(
            _remainingSeconds <= 0 ? 'REST COMPLETE' : 'REST MANDATORY',
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
                    scale: _remainingSeconds <= 10 ? _pulseAnimation.value : 1.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: GoogleFonts.ibmPlexMono(
                            color: timerColor,
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'REMAINING',
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
          
          const SizedBox(height: 40),
          
          // Recovery message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _getRecoveryMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
                height: 1.5,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_alarm, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'EXTEND +30s (RECOMMENDED)',
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade800),
                      color: Colors.orange.shade900.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'REST EXTENDED',
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade900, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: Colors.red.shade900, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'RECOVERY IS MANDATORY',
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
      return 'Your muscles are rebuilding ATP stores.\nThis is not negotiable.';
    } else if (_remainingSeconds > 60) {
      return 'The nervous system requires recovery.\nPatience builds strength.';
    } else if (_remainingSeconds > 30) {
      return 'Almost ready.\nPrepare your mind.';
    } else if (_remainingSeconds > 10) {
      return 'Focus.\nVisualize the next set.';
    } else {
      return 'PREPARE TO LIFT';
    }
  }
  
  String _getSkipReason() {
    if (widget.lastSetPerformance == 'above_mandate') {
      return 'SKIP - FEELING STRONG';
    } else if (_remainingSeconds <= 30) {
      return 'SKIP - TIME READY';
    } else if (widget.lastSetPerformance == 'within_mandate') {
      return 'SKIP - GOOD PERFORMANCE';
    }
    return 'SKIP REST';
  }
}