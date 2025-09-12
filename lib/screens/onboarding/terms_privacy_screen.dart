import 'package:flutter/material.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/theme/heavyweight_theme.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HeavyweightScaffold(
      title: 'TERMS & PRIVACY',
      showBackButton: true,
      fallbackRoute: '/app?tab=2',
      body: Padding(
        padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'This app provides fitness guidance and stores minimal necessary data for your account and training history. By using HEAVYWEIGHT, you agree that training carries inherent risk and you assume all responsibility for your actions. Consult a physician before training.\n\nData usage: We store profile preferences and logged workouts associated with your account to deliver the protocol. You may delete your data at any time from Settings → Reset. We never sell your data.\n\nSecurity: We take reasonable measures to protect your data. However, no system is perfectly secure.\n\nContact: For data requests or questions, contact support@heavyweight.app',
                  style: HeavyweightTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
