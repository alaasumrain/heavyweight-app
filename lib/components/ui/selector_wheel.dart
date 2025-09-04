import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectorWheel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left arrow
        GestureDetector(
          onTap: value > min ? () => onChanged(value - 1) : null,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: value > min ? Colors.white : Colors.grey.shade700,
              ),
              color: value > min ? Colors.transparent : Colors.grey.shade900,
            ),
            child: Icon(
              Icons.remove,
              color: value > min ? Colors.white : Colors.grey.shade600,
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
            '$value $suffix',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ).copyWith(
              fontFamily: 'monospace', // Fallback
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Right arrow
        GestureDetector(
          onTap: value < max ? () => onChanged(value + 1) : null,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: value < max ? Colors.white : Colors.grey.shade700,
              ),
              color: value < max ? Colors.transparent : Colors.grey.shade900,
            ),
            child: Icon(
              Icons.add,
              color: value < max ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}