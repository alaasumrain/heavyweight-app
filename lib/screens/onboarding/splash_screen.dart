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
      debugPrint('💫 Splash: scheduling quick navigate to nextRoute');
      setState(() {
        _shouldNavigate = true;
      });
      _checkAndNavigate();
    });
  }
  
  void _checkAndNavigate() {
    // Mark splash as shown and navigate away
    AppStateNotifier.setSplashShown(true);
    // Nudge router to re-evaluate redirects
    try {
      AppStateNotifier.instance.updateRoute('/splash_shown');
    } catch (_) {}
    // Decide next route directly from AppState to avoid redirect loops
    final appStateProvider = context.read<AppStateProvider>();
    String target = '/';
    if (appStateProvider.isInitialized) {
      target = appStateProvider.appState.nextRoute;
    }
    debugPrint('💫 Splash: navigating directly to "$target"');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugPrint('💫 Splash: context.go($target)');
      try {
        context.go(target);
      } catch (e) {
        debugPrint('💫 Splash: context.go failed: $e');
      }
      // Fallback: use root navigator context if available
      try {
        final rootCtx = NavLogging.navigatorKey.currentContext;
        if (rootCtx != null) {
          debugPrint('💫 Splash: fallback rootCtx.go($target)');
          GoRouter.of(rootCtx).go(target);
        } else {
          debugPrint('💫 Splash: fallback rootCtx is null');
        }
      } catch (e) {
        debugPrint('💫 Splash: fallback rootCtx.go failed: $e');
      }
      // Ensure navigation eventually happens even if initial go() was too early
      _ensureNavigated(target, attempts: 8, intervalMs: 200);
    });
  }

  void _ensureNavigated(String target, {int attempts = 6, int intervalMs = 250}) {
    if (!mounted || attempts <= 0) return;
    Future.delayed(Duration(milliseconds: intervalMs), () {
      if (!mounted) return;
      try {
        final nav = NavLogging.navigatorKey.currentState;
        final rootCtx = NavLogging.navigatorKey.currentContext;
        String current = '(unknown)';
        if (rootCtx != null) {
          try {
            final rip = GoRouter.of(rootCtx).routeInformationProvider;
            final dynamic dv = rip.value; // RouteInformation
            String? loc;
            try { loc = dv.uri?.toString(); } catch (_) {}
            loc ??= (dv.location as String?);
            current = loc ?? '(unknown)';
          } catch (e) {
            current = 'unavailable: $e';
          }
        }
        debugPrint('💫 Splash.ensureNavigated: attempts=$attempts nav=$nav current=$current target=$target');
        if (current == target) return; // done
        if (rootCtx != null) {
          try {
            GoRouter.of(rootCtx).go(target);
            debugPrint('💫 Splash.ensureNavigated: forced go($target)');
          } catch (e) {
            debugPrint('💫 Splash.ensureNavigated: forced go failed: $e');
          }
        }
      } finally {
        _ensureNavigated(target, attempts: attempts - 1, intervalMs: intervalMs);
      }
    });
  }

  @override
  void dispose() {
    debugPrint('🎬 SplashScreen: dispose');
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
