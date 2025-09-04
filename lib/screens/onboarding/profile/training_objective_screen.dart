import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../components/ui/system_banner.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/radio_selector.dart';
import '../../../providers/profile_provider.dart';

class TrainingObjectiveScreen extends StatelessWidget {
  const TrainingObjectiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if we're in profile editing mode (not onboarding)
    final isEditMode = GoRouterState.of(context).matchedLocation.contains('/profile/');
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isEditMode ? AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ) : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SystemBanner(),
              const SizedBox(height: 40),
              
              // Header
              Text(
                'MISSION PARAMETERS',
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'SELECT PRIMARY TRAINING DIRECTIVE\nCONFIGURE PROTOCOL OPTIMIZATION',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  height: 1.5,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              
              // DEV: Quick navigation buttons
              if (true) // Set to false to hide in production
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellow.shade700),
                    color: Colors.yellow.shade900.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'DEV NAVIGATION',
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.yellow.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _devButton(context, 'EXPERIENCE', '/profile'),
                          _devButton(context, 'FREQUENCY', '/profile/frequency'),
                          _devButton(context, 'STATS', '/profile/stats'),
                          _devButton(context, 'ASSIGNMENT', '/assignment'),
                        ],
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Objective options
              Expanded(
                child: Consumer<ProfileProvider>(
                  builder: (context, provider, child) {
                    return RadioSelector<TrainingObjective>(
                      options: const [
                        RadioOption(
                          value: TrainingObjective.strength,
                          label: 'STRENGTH PROTOCOL - Maximum force development',
                        ),
                        RadioOption(
                          value: TrainingObjective.size,
                          label: 'HYPERTROPHY PROTOCOL - Muscle mass optimization',
                        ),
                        RadioOption(
                          value: TrainingObjective.endurance,
                          label: 'ENDURANCE PROTOCOL - Work capacity enhancement',
                        ),
                        RadioOption(
                          value: TrainingObjective.general,
                          label: 'GENERAL PROTOCOL - Comprehensive conditioning',
                        ),
                      ],
                      selectedValue: provider.objective,
                      onChanged: provider.setObjective,
                    );
                  },
                ),
              ),
              
              // Continue button
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return CommandButton(
                    text: 'LOCK_PARAMETERS',
                    variant: ButtonVariant.primary,
                    isDisabled: provider.objective == null,
                    onPressed: provider.objective != null
                        ? () => context.go('/assignment')
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _devButton(BuildContext context, String label, String route) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow.shade700),
          color: Colors.yellow.shade800.withOpacity(0.2),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: Colors.yellow.shade400,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}