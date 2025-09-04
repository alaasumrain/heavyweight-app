import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class HeavyweightNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  
  const HeavyweightNavigationBar({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    const tabs = ['ASSIGNMENT', 'TRAINING_LOG', 'SETTINGS'];
    const routes = ['/assignment', '/training-log', '/settings'];
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade800, width: 1)),
        color: Colors.black,
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = index == currentIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (onTap != null) {
                  onTap!(index);
                } else {
                  // Default navigation behavior
                  if (index < routes.length) {
                    context.go(routes[index]);
                  }
                }
              },
              child: Container(
                color: isSelected ? Colors.grey.shade900 : Colors.transparent,
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.ibmPlexMono(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      letterSpacing: 1,
                    ).copyWith(
                      fontFamily: 'monospace', // Fallback
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
