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
          appBar: AppBar(
            backgroundColor: HeavyweightTheme.surface,
            title: Text(
              'PROFILE',
              style: HeavyweightTheme.h3,
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Status
                _buildProfileStatus(profileProvider),
                
                const SizedBox(height: 30),
                
                // Profile Information
                _buildProfileSection('TRAINING PROFILE', [
                  _buildProfileItem(
                    'Experience Level',
                    _getExperienceText(profileProvider.experience),
                    () => context.go('/profile/experience'),
                  ),
                  _buildProfileItem(
                    'Training Frequency',
                    profileProvider.frequency != null 
                        ? '${profileProvider.frequency} days/week'
                        : 'Not set',
                    () => context.go('/profile/frequency'),
                  ),
                  _buildProfileItem(
                    'Training Objective',
                    _getObjectiveText(profileProvider.objective),
                    () => context.go('/profile/objective'),
                  ),
                ]),
                
                const SizedBox(height: 30),
                
                // Physical Stats
                _buildProfileSection('PHYSICAL STATS', [
                  _buildProfileItem(
                    'Age',
                    profileProvider.age != null 
                        ? '${profileProvider.age} years'
                        : 'Not set',
                    () => context.go('/profile/stats'),
                  ),
                  _buildProfileItem(
                    'Weight',
                    _getWeightText(profileProvider),
                    () => context.go('/profile/stats'),
                  ),
                  _buildProfileItem(
                    'Height',
                    profileProvider.height != null 
                        ? '${profileProvider.height} cm'
                        : 'Not set',
                    () => context.go('/profile/stats'),
                  ),
                ]),
                
                const SizedBox(height: 30),
                
                // Preferences
                _buildProfileSection('PREFERENCES', [
                  _buildProfileItem(
                    'Units',
                    profileProvider.unit == Unit.kg ? 'Metric (kg)' : 'Imperial (lb)',
                    () => context.go('/profile/units'),
                  ),
                ]),
                
                const SizedBox(height: 40),
                
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
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
        const SizedBox(height: 15),
        ...items,
      ],
    );
  }

  Widget _buildProfileItem(String label, String value, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
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
                  const SizedBox(height: 5),
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
            style: CommandButtonStyle.primary,
          ),
        const SizedBox(height: 15),
        CommandButton(
          text: 'RESET PROFILE',
          onPressed: () => _showResetDialog(context, profileProvider),
          style: CommandButtonStyle.secondary,
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