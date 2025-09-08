import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../providers/app_state_provider.dart';

class LegalGateScreen extends StatelessWidget {
  const LegalGateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeavyweightTheme.background,
      appBar: AppBar(
        backgroundColor: HeavyweightTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HeavyweightTheme.primary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/'); // Go back to splash
            }
          },
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
          child: Column(
            children: [
              const SystemBanner(),
              const SizedBox(height: HeavyweightTheme.spacingXl),
              
              // Warning text
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                      // Mark legal as accepted in AppState
                      final appState = context.read<AppStateProvider>().appState;
                      await appState.acceptLegal();
                      
                      // Navigate to next screen (AppState will handle routing)
                      if (context.mounted) {
                        final nextRoute = appState.nextRoute;
                        context.go(nextRoute);
                      }
                    },
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingMd),
                  CommandButton(
                    text: 'VIEW TERMS & PRIVACY POLICY',
                    onPressed: () {
                      // Open terms in browser or show inline
                      // For now, just acknowledge the tap
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms & Privacy would open here'),
                          backgroundColor: HeavyweightTheme.secondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}