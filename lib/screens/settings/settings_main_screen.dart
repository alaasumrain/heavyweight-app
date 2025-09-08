import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/warning_stripes.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../providers/profile_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/repository_provider.dart';

class SettingsMainScreen extends StatelessWidget {
  const SettingsMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeavyweightScaffold(
      title: 'SETTINGS',
      showBanner: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      _buildSettingsSection('PROFILE', [
                        _buildSettingsItem(
                          icon: Icons.person_outline,
                          label: 'Profile Management',
                          subtitle: 'Edit training profile and physical stats',
                          onTap: () => context.go('/profile'),
                        ),
                      ]),
                      
                      const SizedBox(height: HeavyweightTheme.spacingXl),
                      
                      _buildSettingsSection('DATA', [
                        _buildSettingsItem(
                          icon: Icons.storage_outlined,
                          label: 'Training Data',
                          subtitle: 'Export or manage workout history',
                          onTap: () => _showDataOptions(context),
                        ),
                        _buildSettingsItem(
                          icon: Icons.refresh_outlined,
                          label: 'Reset Application',
                          subtitle: 'Clear all data and start fresh',
                          onTap: () => _showResetDialog(context),
                          isDestructive: true,
                        ),
                      ]),
                      
                      const SizedBox(height: HeavyweightTheme.spacingXl),
                      
                      _buildSettingsSection('ABOUT', [
                        _buildSettingsItem(
                          icon: Icons.info_outline,
                          label: 'Version',
                          subtitle: 'v1.0.0 - HEAVYWEIGHT Protocol',
                          onTap: () => _showAbout(context),
                        ),
                        _buildSettingsItem(
                          icon: Icons.description_outlined,
                          label: 'Philosophy',
                          subtitle: 'The 4-6 rep mandate explained',
                          onTap: () => context.go('/manifesto'),
                        ),
                      ]),
                      
                      const SizedBox(height: HeavyweightTheme.spacingXl),
                      
                      _buildSettingsSection('DEVELOPER', [
                        _buildSettingsItem(
                          icon: Icons.refresh,
                          label: 'Reset All Data',
                          subtitle: 'Clear all data and restart onboarding',
                          onTap: () => _resetAllData(context),
                          isDestructive: true,
                        ),
                      ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: HeavyweightTheme.labelMedium.copyWith(
            color: HeavyweightTheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: HeavyweightTheme.spacingMd),
        ...items,
      ],
    );
  }
  
  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingSm),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDestructive 
                  ? HeavyweightTheme.error.withOpacity(0.3)
                  : HeavyweightTheme.secondary,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive 
                    ? HeavyweightTheme.error 
                    : HeavyweightTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: HeavyweightTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: HeavyweightTheme.bodyMedium.copyWith(
                        color: isDestructive 
                            ? HeavyweightTheme.error 
                            : HeavyweightTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: HeavyweightTheme.spacingXs),
                    Text(
                      subtitle,
                      style: HeavyweightTheme.bodySmall.copyWith(
                        color: HeavyweightTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: HeavyweightTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDataOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HeavyweightTheme.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TRAINING DATA',
              style: HeavyweightTheme.h4,
            ),
            const SizedBox(height: HeavyweightTheme.spacingLg),
            ListTile(
              leading: const Icon(Icons.file_download, color: HeavyweightTheme.textPrimary),
              title: const Text('Export Data', style: TextStyle(color: HeavyweightTheme.textPrimary)),
              subtitle: const Text('Export workout history as CSV', style: TextStyle(color: HeavyweightTheme.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                _exportData(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: HeavyweightTheme.textPrimary),
              title: const Text('View Statistics', style: TextStyle(color: HeavyweightTheme.textPrimary)),
              subtitle: const Text('Detailed training analytics', style: TextStyle(color: HeavyweightTheme.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                context.go('/training-log');
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('DATA EXPORT: FEATURE_COMING_SOON'),
        backgroundColor: HeavyweightTheme.primary,
      ),
    );
  }
  
  void _resetAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HeavyweightTheme.surface,
        title: const Text(
          'RESET ALL DATA',
          style: TextStyle(color: HeavyweightTheme.textPrimary),
        ),
        content: const Text(
          'This will delete ALL your data and restart the onboarding process. This action cannot be undone.',
          style: TextStyle(color: HeavyweightTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Reset app state
              final appState = context.read<AppStateProvider>().appState;
              await appState.reset();
              
              // Reset repository
              final repository = context.read<RepositoryProvider>().repository;
              if (repository != null) {
                await repository.clearAll();
              }
              
              // Navigate to splash/onboarding
              context.go('/');
            },
            style: TextButton.styleFrom(foregroundColor: HeavyweightTheme.danger),
            child: const Text('RESET ALL'),
          ),
        ],
      ),
    );
  }
  
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HeavyweightTheme.surface,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WarningStripes.danger(
              height: 35,
              text: 'DESTRUCTIVE_ACTION',
              animated: true,
            ),
            const SizedBox(height: 16),
            Text(
              'RESET APPLICATION?',
              style: HeavyweightTheme.h4.copyWith(
                color: HeavyweightTheme.error,
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete:\n• All workout data\n• Profile settings\n• Training history\n\nThis action cannot be undone.',
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
              context.read<ProfileProvider>().reset();
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('APPLICATION RESET COMPLETE'),
                  backgroundColor: HeavyweightTheme.error,
                ),
              );
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
  
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HeavyweightTheme.surface,
        title: Text(
          'HEAVYWEIGHT',
          style: HeavyweightTheme.h4,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: HeavyweightTheme.bodyMedium.copyWith(
                color: HeavyweightTheme.primary,
              ),
            ),
            const SizedBox(height: HeavyweightTheme.spacingMd),
            Text(
              'The uncompromising strength training protocol.',
              style: HeavyweightTheme.bodyMedium,
            ),
            const SizedBox(height: HeavyweightTheme.spacingMd),
            Text(
              'Built on the principle that 4-6 reps per set is non-negotiable for optimal strength development.',
              style: HeavyweightTheme.bodySmall.copyWith(
                color: HeavyweightTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'UNDERSTOOD',
              style: HeavyweightTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

