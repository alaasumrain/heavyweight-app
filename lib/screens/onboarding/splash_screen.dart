import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import '../../components/ui/system_banner.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/legal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeavyweightTheme.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SystemBanner(),
            const SizedBox(height: HeavyweightTheme.spacingXl),
            const Text(
              'INITIALIZING...',
              style: HeavyweightTheme.bodySmall,
            ),
            const SizedBox(height: HeavyweightTheme.spacingLg),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: HeavyweightTheme.secondary,
                valueColor: const AlwaysStoppedAnimation<Color>(HeavyweightTheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}