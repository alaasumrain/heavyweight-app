import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// no GoogleFonts here to avoid iOS startup issues
import 'package:go_router/go_router.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../core/logging.dart';
import '../../nav.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../core/nav_logging.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _navigated = false;

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

    // Navigate once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _goNextOnce());
  }
  
  void _goNextOnce() {
    if (_navigated || !mounted) return;
    _navigated = true;
    AppStateNotifier.setSplashShown(true);
    try { AppStateNotifier.instance.updateRoute('/splash_shown'); } catch (_) {}
    final appStateProvider = context.read<AppStateProvider>();
    final target = appStateProvider.isInitialized
        ? appStateProvider.appState.nextRoute
        : '/';
    try { context.go(target); } catch (_) {
      final rootCtx = NavLogging.navigatorKey.currentContext;
      if (rootCtx != null) {
        try { GoRouter.of(rootCtx).go(target); } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🎬 SplashScreen: dispose');
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
