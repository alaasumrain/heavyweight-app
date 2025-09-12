import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/profile_provider.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../core/theme/heavyweight_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return HeavyweightScaffold(
          title: 'PROFILE',
          showBackButton: true,
          fallbackRoute: '/app?tab=2',
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Status
                _buildProfileStatus(profileProvider),
                
                const SizedBox(height: HeavyweightTheme.spacingXl),
                
                // Profile Information
                _buildProfileSection('TRAINING PROFILE', [
                  _buildProfileItem(
                    'Experience Level',
                    _getExperienceText(profileProvider.experience),
                    () => context.go('/profile/experience?edit=1'),
                  ),
                  _buildProfileItem(
                    'Training Frequency',
                    profileProvider.frequency != null 
                        ? '${profileProvider.frequency} days/week'
                        : 'Not set',
                    () => context.go('/profile/frequency?edit=1'),
                  ),
                  _buildProfileItem(
                    'Training Objective',
                    _getObjectiveText(profileProvider.objective),
                    () => context.go('/profile/objective?edit=1'),
                  ),
                ]),
                
                const SizedBox(height: HeavyweightTheme.spacingXl),
                
                // Physical Stats
                _buildProfileSection('PHYSICAL STATS', [
                  _buildProfileItem(
                    'Age',
                    profileProvider.age != null 
                        ? '${profileProvider.age} years'
                        : 'Not set',
                    () => context.go('/profile/stats?edit=1'),
                  ),
                  _buildProfileItem(
                    'Weight',
                    _getWeightText(profileProvider),
                    () => context.go('/profile/stats?edit=1'),
                  ),
                  _buildProfileItem(
                    'Height',
                    profileProvider.height != null 
                        ? '${profileProvider.height} cm'
                        : 'Not set',
                    () => context.go('/profile/stats?edit=1'),
                  ),
                ]),
                
                const SizedBox(height: HeavyweightTheme.spacingXl),
                
                // Preferences
                _buildProfileSection('PREFERENCES', [
                  _buildProfileItem(
                    'Units',
                    profileProvider.unit == Unit.kg ? 'Metric (kg)' : 'Imperial (lb)',
                    () => context.go('/profile/units?edit=1'),
                  ),
                ]),
                
                const SizedBox(height: HeavyweightTheme.spacingXxl),
                
                // Actions
                _buildActionButtons(context, profileProvider),
              ],
            ),
          ),
          showNavigation: false, // Profile accessed from other screens
        );
      },
    );
  }

  Widget _buildProfileStatus(ProfileProvider profileProvider) {
    final isComplete = profileProvider.isComplete;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(
          color: isComplete ? Colors.green : Colors.amber,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.warning,
            color: isComplete ? Colors.green : Colors.amber,
            size: 32,
          ),
          const SizedBox(height: HeavyweightTheme.spacingSm),
          Text(
            isComplete ? 'PROFILE COMPLETE' : 'PROFILE INCOMPLETE',
            style: TextStyle(
              color: isComplete ? Colors.green : Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          if (!isComplete) ...[
            const SizedBox(height: HeavyweightTheme.spacingSm),
            Text(
              'Complete your profile to unlock personalized training',
              style: HeavyweightTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: HeavyweightTheme.h4,
        ),
        const SizedBox(height: HeavyweightTheme.spacingMd),
        ...items,
      ],
    );
  }

  Widget _buildProfileItem(String label, String value, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingSm),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(color: HeavyweightTheme.secondary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: HeavyweightTheme.bodySmall.copyWith(
                      color: HeavyweightTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingXs),
                  Text(
                    value,
                    style: HeavyweightTheme.bodyMedium,
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                color: HeavyweightTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ProfileProvider profileProvider) {
    return Column(
      children: [
        if (!profileProvider.isComplete)
          CommandButton(
            text: 'COMPLETE PROFILE',
            onPressed: () => context.go('/profile/experience'),
            variant: ButtonVariant.primary,
          ),
        const SizedBox(height: HeavyweightTheme.spacingMd),
        CommandButton(
          text: 'RESET PROFILE',
          onPressed: () => _showResetDialog(context, profileProvider),
          variant: ButtonVariant.secondary,
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HeavyweightTheme.surface,
        title: Text(
          'RESET PROFILE?',
          style: HeavyweightTheme.h4,
        ),
        content: Text(
          'This will clear all your profile data. You will need to set it up again.',
          style: HeavyweightTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'CANCEL',
              style: HeavyweightTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              profileProvider.reset();
              context.pop();
            },
            child: Text(
              'RESET',
              style: HeavyweightTheme.bodyMedium.copyWith(
                color: HeavyweightTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getExperienceText(ExperienceLevel? experience) {
    switch (experience) {
      case ExperienceLevel.beginner:
        return 'Beginner';
      case ExperienceLevel.intermediate:
        return 'Intermediate';
      case ExperienceLevel.advanced:
        return 'Advanced';
      default:
        return 'Not set';
    }
  }

  String _getObjectiveText(TrainingObjective? objective) {
    switch (objective) {
      case TrainingObjective.strength:
        return 'Strength';
      case TrainingObjective.size:
        return 'Muscle Size';
      case TrainingObjective.endurance:
        return 'Endurance';
      case TrainingObjective.general:
        return 'General Fitness';
      default:
        return 'Not set';
    }
  }

  String _getWeightText(ProfileProvider profileProvider) {
    if (profileProvider.weight == null) return 'Not set';
    
    final unit = profileProvider.unit == Unit.kg ? 'kg' : 'lb';
    return '${profileProvider.weight!.toStringAsFixed(1)} $unit';
  }
}
