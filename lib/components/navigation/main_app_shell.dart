import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/training/assignment_screen.dart';
import '../../screens/training/training_log_screen.dart';
import '../../screens/settings/settings_main_screen.dart';
import '../ui/navigation_bar.dart';
import '../../core/logging.dart';

/// Main app shell with sliding navigation between screens
/// Provides smooth transitions without full page rebuilds
class MainAppShell extends StatefulWidget {
  final int initialIndex;
  const MainAppShell({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
    HWLog.screen('MainAppShell');
    HWLog.event('main_shell_init', data: {
      'initialIndex': _currentIndex,
    });
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 1.0, // Full screen for seamless feel
      keepPage: true, // Maintain page state
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400), // Slightly longer for smoother feel
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      HWLog.event('tab_tap', data: {
        'from': _currentIndex,
        'to': index,
      });
      setState(() {
        _currentIndex = index;
      });
      
      // Enhanced carousel-style slide transition
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400), // Smooth carousel timing
        curve: Curves.easeInOutQuart, // More pronounced easing for carousel feel
      );
      // Keep URL in sync
      final routes = ['/assignment', '/training-log', '/settings'];
      if (index >= 0 && index < routes.length) {
        context.go('/app?tab=$index');
      }
    }
  }

  void _onPageChanged(int index) {
    if (index != _currentIndex) {
      HWLog.event('page_changed', data: {
        'from': _currentIndex,
        'to': index,
      });
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    HWLog.event('main_shell_build', data: {
      'index': _currentIndex,
    });
    debugPrint('🚀 MainAppShell.build: index=$_currentIndex');
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(), // More fluid carousel feel
          pageSnapping: true,
          padEnds: false, // Remove padding for seamless carousel
          children: [
            // Assignment Screen
            AssignmentScreen.withProvider(),
            
            // Training Log Screen  
            TrainingLogScreen.withProvider(),
            
            // Settings Screen
            const SettingsMainScreen(),
          ],
        ),
        bottomNavigationBar: HeavyweightNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
