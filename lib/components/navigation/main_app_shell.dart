import 'package:flutter/material.dart';
import '../../screens/training/assignment_screen.dart';
import '../../screens/training/training_log_screen.dart';
import '../../screens/settings/settings_main_screen.dart';
import '../ui/navigation_bar.dart';

/// Main app shell with sliding navigation between screens
/// Provides smooth transitions without full page rebuilds
class MainAppShell extends StatefulWidget {
  const MainAppShell({Key? key}) : super(key: key);

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
      setState(() {
        _currentIndex = index;
      });
      
      // Enhanced carousel-style slide transition
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400), // Smooth carousel timing
        curve: Curves.easeInOutQuart, // More pronounced easing for carousel feel
      );
    }
  }

  void _onPageChanged(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Allow normal back navigation to work
        return true;
      },
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
