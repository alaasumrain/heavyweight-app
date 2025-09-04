import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../components/ui/system_banner.dart';
import '../../../components/ui/command_button.dart';
import '../../../components/ui/selector_wheel.dart';
import '../../../providers/profile_provider.dart';

class PhysicalStatsScreen extends StatelessWidget {
  const PhysicalStatsScreen({Key? key}) : super(key: key);

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
                'OPERATOR SPECIFICATIONS',
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'INPUT PHYSICAL PARAMETERS\nREQUIRED FOR LOAD CALCULATIONS',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  height: 1.5,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 40),
              
              // Stats selectors
              Expanded(
                child: Consumer<ProfileProvider>(
                  builder: (context, provider, child) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Age
                          _buildStatSection(
                            'OPERATOR_AGE',
                            SelectorWheel(
                              value: provider.age ?? 25,
                              min: 16,
                              max: 80,
                              suffix: 'YRS',
                              onChanged: provider.setAge,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Weight
                          _buildStatSection(
                            'MASS_SPECIFICATION',
                            Column(
                              children: [
                                SelectorWheel(
                                  value: provider.weight?.round() ?? 70,
                                  min: provider.unit == Unit.kg ? 40 : 88,
                                  max: provider.unit == Unit.kg ? 200 : 440,
                                  suffix: provider.unit == Unit.kg ? 'KG' : 'LBS',
                                  onChanged: (value) => provider.setWeight(value.toDouble()),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () => provider.setUnit(Unit.kg),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white),
                                          color: provider.unit == Unit.kg ? Colors.white : Colors.transparent,
                                        ),
                                        child: Text(
                                          'KG',
                                          style: GoogleFonts.ibmPlexMono(
                                            color: provider.unit == Unit.kg ? Colors.black : Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () => provider.setUnit(Unit.lb),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white),
                                          color: provider.unit == Unit.lb ? Colors.white : Colors.transparent,
                                        ),
                                        child: Text(
                                          'LBS',
                                          style: GoogleFonts.ibmPlexMono(
                                            color: provider.unit == Unit.lb ? Colors.black : Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Height
                          _buildStatSection(
                            'HEIGHT_PARAMETER',
                            SelectorWheel(
                              value: provider.height ?? 175,
                              min: 140,
                              max: 220,
                              suffix: 'CM',
                              onChanged: provider.setHeight,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Continue button
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  final isComplete = provider.age != null && 
                                   provider.weight != null && 
                                   provider.height != null;
                  
                  return CommandButton(
                    text: 'CONFIRM_SPECS',
                    variant: ButtonVariant.primary,
                    isDisabled: !isComplete,
                    onPressed: isComplete
                        ? () => context.go('/profile/objective')
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
  
  Widget _buildStatSection(String title, Widget selector) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.ibmPlexMono(
            color: Colors.grey.shade600,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        selector,
      ],
    );
  }
}