import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../engine/models/set_data.dart';

/// Rep Logger - Accepts the TRUTH
/// No limits, no validation - we need honest data, especially in failure
class RepLogger extends StatefulWidget {
  final Function(int) onRepsLogged;
  final int initialValue;
  
  const RepLogger({
    Key? key,
    required this.onRepsLogged,
    this.initialValue = 5,
  }) : super(key: key);
  
  @override
  State<RepLogger> createState() => _RepLoggerState();
}

class _RepLoggerState extends State<RepLogger> {
  late int _currentReps;
  late TextEditingController _controller;
  
  // Visual zones for feedback
  static const _failureZone = [0, 3];   // Red zone
  static const _mandateZone = [4, 6];   // Green zone - THE MANDATE
  static const _excessZone = [7, 30];   // Yellow zone
  
  @override
  void initState() {
    super.initState();
    _currentReps = widget.initialValue;
    _controller = TextEditingController(text: _currentReps.toString());
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Color _getZoneColor() {
    if (_currentReps == 0) {
      return Colors.red.shade900; // Complete failure
    } else if (_currentReps <= _failureZone[1]) {
      return Colors.red.shade700; // Below mandate
    } else if (_currentReps >= _mandateZone[0] && _currentReps <= _mandateZone[1]) {
      return const Color(0xFF00FF00); // Perfect - The Mandate
    } else {
      return Colors.amber; // Above mandate
    }
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
  
  void _increment() {
    if (_currentReps < 30) {
      setState(() {
        _currentReps++;
        _controller.text = _currentReps.toString();
      });
    }
  }
  
  void _decrement() {
    if (_currentReps > 0) {
      setState(() {
        _currentReps--;
        _controller.text = _currentReps.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final zoneColor = _getZoneColor();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: zoneColor, width: 2),
      ),
      child: Column(
        children: [
          // Zone indicator
          Text(
            _getZoneText(),
            style: TextStyle(
              color: zoneColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
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
                    if (reps >= 0 && reps <= 30) {
                      setState(() {
                        _currentReps = reps;
                      });
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
                  const Color(0xFF00FF00), // 4-6
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
              Text('4-6', style: TextStyle(color: const Color(0xFF00FF00), fontSize: 10, fontWeight: FontWeight.bold)),
              Text('30', style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Log button
          ElevatedButton(
            onPressed: () {
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