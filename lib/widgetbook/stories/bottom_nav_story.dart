import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../components/ui/bottom_nav.dart';

WidgetbookComponent buildBottomNavComponent() {
  return WidgetbookComponent(
    name: 'Bottom Navigation',
    useCases: [
      WidgetbookUseCase(
        name: 'Interactive',
        builder: (_) => const _InteractiveBottomNav(),
      ),
    ],
  );
}

class _InteractiveBottomNav extends StatefulWidget {
  const _InteractiveBottomNav();

  @override
  State<_InteractiveBottomNav> createState() => _InteractiveBottomNavState();
}

class _InteractiveBottomNavState extends State<_InteractiveBottomNav> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: HeavyweightBottomNav(
          items: const [
            BottomNavItem(icon: Icons.home_outlined, label: 'Home'),
            BottomNavItem(icon: Icons.bar_chart_outlined, label: 'Progress'),
            BottomNavItem(icon: Icons.calendar_today_outlined, label: 'Schedule'),
            BottomNavItem(icon: Icons.fitness_center_outlined, label: 'Train'),
            BottomNavItem(icon: Icons.person_outline, label: 'Profile'),
          ],
          selectedIndex: _selectedIndex,
          onItemTapped: (index) => setState(() => _selectedIndex = index),
          showLabels: false,
        ),
      ),
    );
  }
}
