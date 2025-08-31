import 'dart:async';
import 'package:flutter/material.dart';

/// Enforced Rest Timer - Cannot be skipped
/// Recovery is not optional
class RestTimer extends StatefulWidget {
  final int restSeconds;
  final VoidCallback onComplete;
  final bool canSkip; // Should always be false in production
  
  const RestTimer({
    Key? key,
    required this.restSeconds,
    required this.onComplete,
    this.canSkip = false,
  }) : super(key: key);
  
  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late int _remainingSeconds;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.restSeconds;
    
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
  
  Color _getTimerColor() {
    if (_remainingSeconds <= 10) {
      return const Color(0xFF00FF00); // Green - ready
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
          // REST MANDATORY text
          const Text(
            'REST MANDATORY',
            style: TextStyle(
              color: Colors.red,
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
                  backgroundColor: Colors.grey.shade900,
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
                          style: TextStyle(
                            color: timerColor,
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'REMAINING',
                          style: TextStyle(
                            color: Colors.grey.shade600,
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
          
          // Cannot skip indicator
          if (!widget.canSkip)
            Container(
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
                    'RECOVERY CANNOT BE SKIPPED',
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
          
          // Skip button (only if allowed - should never be)
          if (widget.canSkip && _remainingSeconds > 10)
            TextButton(
              onPressed: () {
                _timer.cancel();
                widget.onComplete();
              },
              child: Text(
                'SKIP (NOT RECOMMENDED)',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                ),
              ),
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
}