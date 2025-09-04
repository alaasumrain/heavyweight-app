import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/ui/system_banner.dart';
import '../../components/ui/command_button.dart';
import '../../providers/app_state_provider.dart';

class LegalGateScreen extends StatelessWidget {
  const LegalGateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SystemBanner(),
              const SizedBox(height: 40),
              
              // Warning text
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      color: Colors.red.shade600,
                      size: 64,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'LEGAL DISCLAIMER',
                      style: GoogleFonts.ibmPlexMono(
                        color: Colors.red.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'THIS APPLICATION PROVIDES FITNESS GUIDANCE.\n\nYOU ASSUME ALL RISKS.\n\nCONSULT A PHYSICIAN BEFORE STARTING ANY EXERCISE PROGRAM.\n\nTHE AUTHORS DISCLAIM ALL LIABILITY.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexMono(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        height: 1.8,
                        letterSpacing: 1,
                      ),
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
                        context.go('/philosophy');
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CommandButton(
                    text: 'VIEW TERMS & PRIVACY POLICY',
                    onPressed: () {
                      // Open terms in browser or show inline
                      // For now, just acknowledge the tap
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms & Privacy would open here'),
                          backgroundColor: Colors.grey,
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