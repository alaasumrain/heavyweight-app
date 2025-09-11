import 'package:flutter/material.dart';
import '../../components/ui/command_button.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/theme/heavyweight_theme.dart';

/// Paywall screen for subscription management
/// Shows when free trial expires or premium features accessed
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeavyweightScaffold(
      title: 'TRIAL_EXPIRED',
      
      body: Column(
        children: [
          
          
          // Benefits
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HEAVYWEIGHT_PREMIUM:',
                  style: HeavyweightTheme.h4,
                ),
                SizedBox(height: HeavyweightTheme.spacingLg),
                Text(
                  '• UNLIMITED_SESSIONS',
                  style: HeavyweightTheme.bodyMedium,
                ),
                Text(
                  '• ADVANCED_ANALYTICS',
                  style: HeavyweightTheme.bodyMedium,
                ),
                Text(
                  '• PRIORITY_SUPPORT',
                  style: HeavyweightTheme.bodyMedium,
                ),
                Text(
                  '• FUTURE_FEATURES',
                  style: HeavyweightTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          // Action buttons
          CommandButton(
            text: 'COMMAND: VIEW_PLANS',
            onPressed: () {
              // TODO: Navigate to subscription plans
              // context.push('/subscription-plans');
            },
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingMd),
          
          CommandButton(
            text: 'COMMAND: RESTORE_PURCHASE',
            variant: ButtonVariant.secondary,
            onPressed: () {
              // TODO: Implement restore purchase
            },
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingXl),
        ],
      ),
    );
  }
}
