import 'package:flutter/material.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../fortress/engine/exercise_intel.dart';
import '../../core/logging.dart';

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
    HWLog.screen('Training/ExerciseIntel');
    final intel = ExerciseIntel.getIntelProfile(exerciseId);

    return HeavyweightScaffold(
      title: 'EXERCISE_INTEL',
      showBackButton: true,
      fallbackRoute: '/app?tab=0',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: HeavyweightTheme.spacingLg,
          vertical: HeavyweightTheme.spacingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            _buildHeader(intel),

            const SizedBox(height: HeavyweightTheme.spacingXl),

            // Form Protocol
            _buildSection(
              'FORM_CHECKLIST',
              intel.formProtocol,
              HeavyweightTheme.primary,
              Icons.check_circle_outline,
            ),

            const SizedBox(height: HeavyweightTheme.spacingLg),

            // Safety Thresholds
            _buildSection(
              'SAFETY_THRESHOLDS',
              intel.safetyThresholds,
              HeavyweightTheme.error,
              Icons.warning_outlined,
            ),

            const SizedBox(height: HeavyweightTheme.spacingLg),

            // Execution Parameters
            _buildExecutionParams(intel),

            const SizedBox(height: HeavyweightTheme.spacingLg),

            // Common Failures
            _buildSection(
              'COMMON_FAILURES',
              intel.commonFailures,
              Colors.amber.shade700,
              Icons.error_outline,
            ),

            const SizedBox(height: HeavyweightTheme.spacingLg),

            // Abort Conditions
            _buildAbortConditions(intel),

            const SizedBox(height: HeavyweightTheme.spacingXxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ExerciseIntelProfile intel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exerciseName.toUpperCase(),
            style: HeavyweightTheme.h2,
          ),
          const SizedBox(height: HeavyweightTheme.spacingSm),
          Text(
            'CODENAME: ${intel.codename}',
            style: HeavyweightTheme.bodyMedium.copyWith(
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

  Widget _buildSection(
      String title, List<String> items, Color accentColor, IconData icon) {
    final displayItems = items.map((item) => item.toUpperCase()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: HeavyweightTheme.spacingSm),
            Text(
              title,
              style: HeavyweightTheme.bodyMedium.copyWith(
                color: accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: HeavyweightTheme.spacingMd),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            color: HeavyweightTheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: displayItems
                .map((item) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: HeavyweightTheme.spacingSm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: HeavyweightTheme.bodyMedium.copyWith(
                              color: accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: HeavyweightTheme.bodyMedium.copyWith(
                                color: HeavyweightTheme.primary,
                                fontSize: 13,
                                height: 1.4,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExecutionParams(ExerciseIntelProfile intel) {
    final params = intel.executionParams.map(
      (key, value) => MapEntry(key.toUpperCase(), value.toUpperCase()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.settings,
                color: HeavyweightTheme.accent, size: 20),
            const SizedBox(width: HeavyweightTheme.spacingSm),
            Text(
              'TRAINING_PARAMETERS',
              style: HeavyweightTheme.bodyMedium.copyWith(
                color: HeavyweightTheme.accent,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: HeavyweightTheme.spacingMd),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(
                color: HeavyweightTheme.accent.withValues(alpha: 0.3)),
            color: HeavyweightTheme.surface,
          ),
          child: Column(
            children: params.entries
                .map(
                  (param) => Padding(
                    padding: const EdgeInsets.only(
                        bottom: HeavyweightTheme.spacingSm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            '${param.key}:',
                            style: HeavyweightTheme.bodyMedium.copyWith(
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
                            style: HeavyweightTheme.bodyMedium.copyWith(
                              color: HeavyweightTheme.primary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
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
            const Icon(Icons.dangerous,
                color: HeavyweightTheme.error, size: 20),
            const SizedBox(width: HeavyweightTheme.spacingSm),
            Text(
              'ABORT_CONDITIONS',
              style: HeavyweightTheme.bodyMedium.copyWith(
                color: HeavyweightTheme.error,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: HeavyweightTheme.spacingMd),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(color: HeavyweightTheme.error, width: 2),
            color: HeavyweightTheme.errorSurface,
          ),
          child: Text(
            intel.abortConditions.toUpperCase(),
            style: HeavyweightTheme.bodyMedium.copyWith(
              color: HeavyweightTheme.error,
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
