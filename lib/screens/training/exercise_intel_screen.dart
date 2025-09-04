import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../fortress/engine/exercise_intel.dart';

/// Exercise Intel Screen - Form protocols and safety thresholds
/// Tactical guidance without fluff
class ExerciseIntelScreen extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;
  
  const ExerciseIntelScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });
  
  @override
  Widget build(BuildContext context) {
    final intel = ExerciseIntel.getIntelProfile(exerciseId);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'EXERCISE_INTEL',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise header
              _buildHeader(intel),
              
              const SizedBox(height: 32),
              
              // Form Protocol
              _buildSection(
                'FORM_PROTOCOL',
                intel.formProtocol,
                Colors.white,
                Icons.check_circle_outline,
              ),
              
              const SizedBox(height: 24),
              
              // Safety Thresholds
              _buildSection(
                'SAFETY_THRESHOLDS', 
                intel.safetyThresholds,
                HeavyweightTheme.error,
                Icons.warning_outlined,
              ),
              
              const SizedBox(height: 24),
              
              // Execution Parameters
              _buildExecutionParams(intel),
              
              const SizedBox(height: 24),
              
              // Common Failures
              _buildSection(
                'COMMON_FAILURES',
                intel.commonFailures,
                Colors.amber.shade700,
                Icons.error_outline,
              ),
              
              const SizedBox(height: 24),
              
              // Abort Conditions
              _buildAbortConditions(intel),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(ExerciseIntelProfile intel) {
    return Container(\n      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exerciseName.toUpperCase(),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'CODENAME: ${intel.codename}',
            style: GoogleFonts.inter(
              color: HeavyweightTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<String> items, Color accentColor, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                color: accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: accentColor.withOpacity(0.3)),
            color: accentColor.withOpacity(0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: GoogleFonts.inter(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildExecutionParams(ExerciseIntelProfile intel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.settings, color: HeavyweightTheme.accent, size: 20),
            const SizedBox(width: 12),
            Text(
              'EXECUTION_PARAMETERS',
              style: GoogleFonts.inter(
                color: HeavyweightTheme.accent,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: HeavyweightTheme.accent.withOpacity(0.3)),
            color: HeavyweightTheme.accent.withOpacity(0.05),
          ),
          child: Column(
            children: intel.executionParams.entries.map((param) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${param.key}:',
                        style: GoogleFonts.inter(
                          color: HeavyweightTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        param.value,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAbortConditions(ExerciseIntelProfile intel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.dangerous, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Text(
              'ABORT_CONDITIONS',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
            color: Colors.red.withOpacity(0.1),
          ),
          child: Text(
            intel.abortConditions,
            style: GoogleFonts.inter(
              color: Colors.red.shade300,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}