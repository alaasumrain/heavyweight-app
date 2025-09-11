import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../core/logging.dart';
import '../../nav.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _shouldNavigate = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('🎬 SplashScreen: initState - starting animation');
    }
    HWLog.screen('Splash');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Navigate quickly to avoid perceived hang; splash can be revisited if needed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugPrint('💫 Splash: scheduling quick navigate to root');
      setState(() {
        _shouldNavigate = true;
      });
      _checkAndNavigate();
    });
  }
  
  void _checkAndNavigate() {
    // Mark splash as shown and navigate away
    AppStateNotifier.setSplashShown(true);
    // Decide next route directly from AppState to avoid redirect loops
    final appStateProvider = context.read<AppStateProvider>();
    String target = '/';
    if (appStateProvider.isInitialized) {
      target = appStateProvider.appState.nextRoute;
    }
    debugPrint('💫 Splash: navigating directly to "$target"');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(target);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💫💫💫 SPLASH SCREEN BUILD() CALLED');
    debugPrint('💫💫💫 SPLASH: context=$context');
    debugPrint('💫💫💫 SPLASH: About to return Container');
    // Minimal splash content; do NOT nest a MaterialApp inside router.
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'BOOTING…',
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
