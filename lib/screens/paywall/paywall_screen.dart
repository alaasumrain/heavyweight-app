import 'package:flutter/material.dart';
import '../../components/ui/system_banner.dart';
import '../../components/ui/command_button.dart';
import '../../components/layout/heavyweight_scaffold.dart';

/// Paywall screen for subscription management
/// Shows when free trial expires or premium features accessed
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeavyweightScaffold(
      body: Column(
        children: [
          const SystemBanner(),
          const SizedBox(height: 40),
          
          // Trial status
          const Text(
            'TRIAL_EXPIRED',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Benefits
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HEAVYWEIGHT_PREMIUM:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '• UNLIMITED_SESSIONS',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  '• ADVANCED_ANALYTICS',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  '• PRIORITY_SUPPORT',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  '• FUTURE_FEATURES',
                  style: TextStyle(color: Colors.white, fontSize: 14),
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
          
          const SizedBox(height: 16),
          
          CommandButton(
            text: 'COMMAND: RESTORE_PURCHASE',
            variant: ButtonVariant.secondary,
            onPressed: () {
              // TODO: Implement restore purchase
            },
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
