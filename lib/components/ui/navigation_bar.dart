import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../core/logging.dart';

class HeavyweightNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const HeavyweightNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = ['ASSIGNMENT', 'LOGBOOK', 'SETTINGS'];
    const routes = ['/app?tab=0', '/app?tab=1', '/app?tab=2'];

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 70 + bottomInset,
      padding: EdgeInsets.only(
          bottom:
              bottomInset > 0 ? bottomInset / 2 : HeavyweightTheme.spacingSm),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: HeavyweightTheme.secondary, width: 1)),
        color: HeavyweightTheme.background,
      ),
      child: Stack(
        children: [
          // Animated slide indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutQuart,
            left: (MediaQuery.of(context).size.width / tabs.length) *
                currentIndex,
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
                    } else if (index < routes.length) {
                      // Default navigation behavior
                      final router = GoRouter.of(context);
                      final target = routes[index];
                      final currentLocation =
                          GoRouterState.of(context).uri.toString();
                      if (currentLocation != target) {
                        router.go(target);
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    color: isSelected
                        ? HeavyweightTheme.primary
                        : Colors.transparent,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: HeavyweightTheme.labelSmall.copyWith(
                          color: isSelected
                              ? HeavyweightTheme.onPrimary
                              : HeavyweightTheme.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
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
