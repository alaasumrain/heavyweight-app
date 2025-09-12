import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../core/logging.dart';

class LegalGateScreen extends StatelessWidget {
  const LegalGateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HWLog.screen('LegalGate');
    // iOS debug minimal UI to rule out theme/scaffold issues causing black screen
    if (kDebugMode && defaultTargetPlatform == TargetPlatform.iOS) {
      final appState = context.read<AppStateProvider>().appState;
      final size = MediaQuery.maybeOf(context)?.size;
      debugPrint('🔥🔥🔥 LEGAL DEBUG: MediaQuery.size=$size');
      return Scaffold(
        backgroundColor: const Color(0xFF00AA00), // bright to confirm paint
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'LEGAL DEBUG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                if (size != null)
                  Text(
                    'SIZE ${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await appState.acceptLegal();
                    if (context.mounted) context.go(appState.nextRoute);
                  },
                  child: const Text('ACCEPT'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/legal/terms'),
                  child: const Text('TERMS'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return HeavyweightScaffold(
      title: 'LEGAL DISCLAIMER',
      showBackButton: true,
      fallbackRoute: '/',
      body: Column(
        children: [
          // Warning text moved higher with reduced spacing
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Changed from center to start
              children: [
                const SizedBox(height: HeavyweightTheme.spacingXl), // Add some top spacing
                Icon(
                  Icons.warning_outlined,
                  color: HeavyweightTheme.error,
                  size: 64,
                ),
                const SizedBox(height: HeavyweightTheme.spacingXl),
                Text(
                  'LEGAL DISCLAIMER',
                  style: HeavyweightTheme.bodyLarge,
                ),
                const SizedBox(height: HeavyweightTheme.spacingXl),
                Text(
                  'THIS APPLICATION PROVIDES FITNESS GUIDANCE.\n\nYOU ASSUME ALL RISKS.\n\nCONSULT A PHYSICIAN BEFORE STARTING ANY EXERCISE PROGRAM.\n\nTHE AUTHORS DISCLAIM ALL LIABILITY.',
                  textAlign: TextAlign.center,
                  style: HeavyweightTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Action buttons
          Column(
            children: [
              CommandButton(
                text: 'I UNDERSTAND AND ACCEPT',
                variant: ButtonVariant.primary,
                onPressed: () async {
                  final appState = context.read<AppStateProvider>().appState;
                  await appState.acceptLegal();
                  if (context.mounted) {
                    final nextRoute = appState.nextRoute;
                    context.go(nextRoute);
                  }
                },
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              CommandButton(
                text: 'VIEW TERMS & PRIVACY POLICY',
                variant: ButtonVariant.secondary,
                onPressed: () => context.go('/legal/terms'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
