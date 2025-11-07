import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// no GoogleFonts here to avoid iOS startup issues
import 'package:go_router/go_router.dart';
import '../../core/logging.dart';
import '../../nav.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../core/nav_logging.dart';
import '../../core/theme/heavyweight_theme.dart';

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
    try {
      AppStateNotifier.instance.updateRoute('/splash_shown');
    } catch (_) {}
    final appStateProvider = context.read<AppStateProvider>();
    final target = appStateProvider.isInitialized
        ? appStateProvider.appState.nextRoute
        : '/';
    try {
      GoRouter.of(context).go(target);
    } catch (_) {
      final rootCtx = NavLogging.navigatorKey.currentContext;
      if (rootCtx != null) {
        try {
          GoRouter.of(rootCtx).go(target);
        } catch (_) {}
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
      backgroundColor: HeavyweightTheme.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            final progress = _animationController.value.clamp(0.0, 1.0);
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'HEAVYWEIGHT',
                        style: HeavyweightTheme.h1.copyWith(letterSpacing: 4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: HeavyweightTheme.spacingLg),
                      Text(
                        'INITIALIZING SYSTEM…',
                        style: HeavyweightTheme.bodySmall.copyWith(
                          color: HeavyweightTheme.textSecondary,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: HeavyweightTheme.spacingLg),
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(HeavyweightTheme.spacingSm),
                        decoration: BoxDecoration(
                          border: Border.all(color: HeavyweightTheme.secondary),
                        ),
                        child: SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: progress == 1.0 ? null : progress,
                            backgroundColor: HeavyweightTheme.surface,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                HeavyweightTheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: HeavyweightTheme.spacingMd),
                      Text(
                        'DO NOT INTERRUPT',
                        style: HeavyweightTheme.bodySmall.copyWith(
                          color: HeavyweightTheme.textSecondary,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
