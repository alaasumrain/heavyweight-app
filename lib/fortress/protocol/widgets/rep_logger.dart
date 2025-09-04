import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// Enhanced Rep Logger - Live feedback with context
/// No limits, no validation - we need honest data, especially in failure
class RepLogger extends StatefulWidget {
  final Function(int) onRepsLogged;
  final int initialValue;
  final int currentSet; // Which set number this is (1, 2, 3, etc.)
  final List<int>? previousSetReps; // Reps from previous sets for comparison
  final bool liveMode; // Enable real-time visual feedback
  
  const RepLogger({
    Key? key,
    required this.onRepsLogged,
    this.initialValue = 5,
    this.currentSet = 1,
    this.previousSetReps,
    this.liveMode = true,
  }) : super(key: key);
  
  @override
  State<RepLogger> createState() => _RepLoggerState();
}

class _RepLoggerState extends State<RepLogger> with TickerProviderStateMixin {
  late int _currentReps;
  late TextEditingController _controller;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Visual zones for feedback
  static const _failureZone = [0, 3];   // Red zone
  static const _mandateZone = [4, 6];   // Green zone - THE MANDATE
  
  @override
  void initState() {
    super.initState();
    _currentReps = widget.initialValue;
    _controller = TextEditingController(text: _currentReps.toString());
    
    // Animation for live mode feedback
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  Color _getZoneColor() {
    if (_currentReps == 0) {
      return Colors.red.shade900; // Complete failure
    } else if (_currentReps <= _failureZone[1]) {
      return Colors.red.shade700; // Below mandate
    } else if (_currentReps >= _mandateZone[0] && _currentReps <= _mandateZone[1]) {
      return Colors.white; // Perfect - The Mandate
    } else {
      return Colors.amber; // Above mandate
    }
  }

  /// Validate rep input with reasonable limits
  int _validateReps(int reps) {
    // Allow 0 for failure, but cap at reasonable maximum
    if (reps < 0) return 0;
    if (reps > 50) return 50; // Reasonable maximum for safety
    return reps;
  }
  
  String _getZoneText() {
    if (_currentReps == 0) {
      return 'COMPLETE FAILURE';
    } else if (_currentReps <= _failureZone[1]) {
      return 'BELOW MANDATE';
    } else if (_currentReps >= _mandateZone[0] && _currentReps <= _mandateZone[1]) {
      return 'WITHIN MANDATE';
    } else {
      return 'EXCEEDED MANDATE';
    }
  }
  
  /// Get previous set performance comparison
  String? _getPreviousSetComparison() {
    if (widget.previousSetReps == null || widget.previousSetReps!.isEmpty) {
      return null;
    }
    
    final previousReps = widget.previousSetReps!.last;
    if (_currentReps > previousReps) {
      return 'IMPROVEMENT (+${_currentReps - previousReps})';
    } else if (_currentReps < previousReps) {
      return 'DECLINE (-${previousReps - _currentReps})';
    } else {
      return 'CONSISTENT (=${_currentReps})';
    }
  }
  
  /// Start live mode animation based on zone
  void _triggerLiveFeedback() {
    if (!widget.liveMode) return;
    
    if (_currentReps >= _mandateZone[0] && _currentReps <= _mandateZone[1]) {
      // In mandate zone - pulse green
      _pulseController.repeat(reverse: true);
    } else if (_currentReps == 0) {
      // Complete failure - strong pulse
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }
  
  void _increment() {
    if (_currentReps < 30) {
      setState(() {
        _currentReps++;
        _controller.text = _currentReps.toString();
      });
      _triggerLiveFeedback();
    }
  }
  
  void _decrement() {
    if (_currentReps > 0) {
      setState(() {
        _currentReps--;
        _controller.text = _currentReps.toString();
      });
      _triggerLiveFeedback();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final zoneColor = _getZoneColor();
    final comparison = _getPreviousSetComparison();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: zoneColor, width: 2),
      ),
      child: Column(
        children: [
          // Set header with progression
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SET ${widget.currentSet}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              if (widget.previousSetReps != null && widget.previousSetReps!.isNotEmpty)
                Text(
                  'PREV: ${widget.previousSetReps!.map((r) => r.toString()).join(', ')}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Zone indicator with live feedback
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.liveMode ? _pulseAnimation.value : 1.0,
                child: Text(
                  _getZoneText(),
                  style: TextStyle(
                    color: zoneColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              );
            },
          ),
          
          // Previous set comparison
          if (comparison != null) ...[
            const SizedBox(height: 8),
            Text(
              comparison,
              style: TextStyle(
                color: _currentReps > (widget.previousSetReps?.last ?? 0)
                    ? Colors.green.shade400
                    : _currentReps < (widget.previousSetReps?.last ?? 0)
                        ? Colors.orange.shade400
                        : Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Rep counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrease button
              IconButton(
                onPressed: _decrement,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.white,
                iconSize: 48,
              ),
              
              // Rep display/input
              Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: zoneColor, width: 3),
                  color: Colors.black,
                ),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: zoneColor,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onChanged: (value) {
                    final reps = int.tryParse(value) ?? 0;
                    final validatedReps = _validateReps(reps);
                    if (validatedReps != _currentReps) {
                      setState(() {
                        _currentReps = validatedReps;
                      });
                      _triggerLiveFeedback();
                    }
                  },
                ),
              ),
              
              // Increase button
              IconButton(
                onPressed: _increment,
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.white,
                iconSize: 48,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Mandate zone indicator
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade900,    // 0
                  Colors.red.shade700,    // 1-3
                  Colors.white, // 4-6
                  Colors.amber,           // 7+
                ],
                stops: const [0.0, 0.13, 0.5, 1.0],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Scale labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
              Text('4-6', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('30', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Log button
          ElevatedButton(
            onPressed: () {
              // Provide haptic feedback based on performance zone
              if (_currentReps == 0) {
                HapticFeedback.heavyImpact(); // Failure - strong haptic
              } else if (_currentReps <= _failureZone[1]) {
                HapticFeedback.mediumImpact(); // Below mandate - medium haptic
              } else if (_currentReps >= _mandateZone[0] && _currentReps <= _mandateZone[1]) {
                HapticFeedback.lightImpact(); // Perfect mandate - light success haptic
              } else {
                HapticFeedback.selectionClick(); // Exceeded - subtle click
              }
              
              widget.onRepsLogged(_currentReps);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: zoneColor,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 60),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              'LOG ${_currentReps} REPS',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Truth reminder
          Text(
            'LOG THE TRUTH. THE SYSTEM NEEDS HONESTY.',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}