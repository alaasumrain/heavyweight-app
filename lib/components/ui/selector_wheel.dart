import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';
import 'dart:async';

class SelectorWheel extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final Function(int) onChanged;
  final String suffix;
  
  const SelectorWheel({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix = '',
  }) : super(key: key);
  
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
      widget.onChanged(widget.value - 1);
    }
  }
  
  void _handleSingleIncrement() {
    if (widget.value < widget.max) {
      widget.onChanged(widget.value + 1);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left arrow (minus)
        GestureDetector(
          onTap: _handleSingleDecrement,
          onLongPressStart: (_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _startDecrement();
            });
          },
          onLongPressEnd: (_) => _cancelTimer(),
          onLongPressCancel: () => _cancelTimer(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.value > widget.min ? Colors.white : Colors.grey.shade700,
              ),
              color: widget.value > widget.min 
                  ? (_isDecrementing ? Colors.white.withOpacity(0.1) : Colors.transparent)
                  : Colors.grey.shade900,
            ),
            child: Icon(
              Icons.remove,
              color: widget.value > widget.min ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Value display
        Container(
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Text(
            '${widget.value} ${widget.suffix}',
            textAlign: TextAlign.center,
            style: HeavyweightTheme.h3.copyWith(
              fontSize: 20,
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Right arrow (plus)
        GestureDetector(
          onTap: _handleSingleIncrement,
          onLongPressStart: (_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _startIncrement();
            });
          },
          onLongPressEnd: (_) => _cancelTimer(),
          onLongPressCancel: () => _cancelTimer(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.value < widget.max ? Colors.white : Colors.grey.shade700,
              ),
              color: widget.value < widget.max
                  ? (_isIncrementing ? Colors.white.withOpacity(0.1) : Colors.transparent)
                  : Colors.grey.shade900,
            ),
            child: Icon(
              Icons.add,
              color: widget.value < widget.max ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}