import 'package:flutter/material.dart';

import '../../core/theme/heavyweight_theme.dart';

class BottomNavItem {
  const BottomNavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class HeavyweightBottomNav extends StatelessWidget {
  const HeavyweightBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onItemTapped,
    this.showLabels = false,
  }) : assert(items.length >= 2, 'Provide at least two nav items');

  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemTapped;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final navHeight = showLabels ? 96.0 : 72.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HeavyweightTheme.spacingXl,
          vertical: HeavyweightTheme.spacingMd,
        ),
        child: SizedBox(
          height: navHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _BottomNavItemTile(
                    item: items[i],
                    isSelected: i == selectedIndex,
                    showLabel: showLabels,
                    onTap: () => onItemTapped?.call(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemTile extends StatelessWidget {
  const _BottomNavItemTile({
    required this.item,
    required this.isSelected,
    required this.showLabel,
    required this.onTap,
  });

  final BottomNavItem item;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        isSelected ? Colors.white : Colors.white.withValues(alpha: 0.35);
    final Color borderColor =
        isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2);
    final Color backgroundColor =
        isSelected ? Colors.white.withValues(alpha: 0.08) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2),
              color: backgroundColor,
            ),
            child: Icon(item.icon, size: 26, color: iconColor),
          ),
          if (showLabel) ...[
            const SizedBox(height: HeavyweightTheme.spacingSm),
            Text(
              item.label,
              style: HeavyweightTheme.labelSmall.copyWith(color: iconColor),
            ),
          ] else
            const SizedBox(height: HeavyweightTheme.spacingSm),
          AnimatedOpacity(
            opacity: isSelected ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
