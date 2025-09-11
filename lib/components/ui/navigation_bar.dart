import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../core/logging.dart';

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
    const tabs = ['ASSIGNMENT', 'LOGBOOK', 'SETTINGS'];
    const routes = ['/assignment', '/training-log', '/settings'];
    
    return Container(
      height: 70, // Optimized height for aesthetic
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom / 2),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: HeavyweightTheme.secondary, width: 1)),
        color: HeavyweightTheme.background,
      ),
      child: Stack(
        children: [
          // Animated slide indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutQuart,
            left: (MediaQuery.of(context).size.width / tabs.length) * currentIndex,
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width / tabs.length,
              height: 3,
              decoration: BoxDecoration(
                color: HeavyweightTheme.primary,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
          // Tab buttons
          Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = index == currentIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HWLog.event('bottom_nav_tap', data: {
                  'index': index,
                  'label': label,
                });
                if (onTap != null) {
                  onTap!(index);
                } else {
                  // Default navigation behavior
                  if (index < routes.length) {
                    context.go(routes[index]);
                  }
                }
              },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    color: isSelected ? HeavyweightTheme.primary : Colors.transparent,
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: HeavyweightTheme.labelSmall.copyWith(
                      color: isSelected ? HeavyweightTheme.onPrimary : HeavyweightTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    child: Text(label),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
          ),
        ],
      ),
    );
  }
}
