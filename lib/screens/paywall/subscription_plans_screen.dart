import 'package:flutter/material.dart';
import '../../components/ui/command_button.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/theme/heavyweight_theme.dart';

/// Subscription plans selection screen
class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  int _selectedPlan = 1; // 0 = monthly, 1 = yearly

  @override
  Widget build(BuildContext context) {
    return HeavyweightScaffold(
      title: 'SUBSCRIPTION_PLANS',
      
      body: Column(
        children: [
          
          // Plan selection
          Expanded(
            child: Column(
              children: [
                // Monthly plan
                GestureDetector(
                  onTap: () => setState(() => _selectedPlan = 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                    margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPlan == 0 ? HeavyweightTheme.primary : HeavyweightTheme.secondary,
                        width: _selectedPlan == 0 ? 2 : 1,
                      ),
                      color: _selectedPlan == 0 ? HeavyweightTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONTHLY',
                          style: HeavyweightTheme.h4,
                        ),
                        SizedBox(height: HeavyweightTheme.spacingSm),
                        Text(
                          '\$9.99/MONTH',
                          style: HeavyweightTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Yearly plan
                GestureDetector(
                  onTap: () => setState(() => _selectedPlan = 1),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                    margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPlan == 1 ? HeavyweightTheme.primary : HeavyweightTheme.secondary,
                        width: _selectedPlan == 1 ? 2 : 1,
                      ),
                      color: _selectedPlan == 1 ? HeavyweightTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'YEARLY',
                              style: TextStyle(
                                color: HeavyweightTheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: HeavyweightTheme.spacingSm),
                            Text(
                              'SAVE_40%',
                              style: HeavyweightTheme.labelSmall.copyWith(
                                color: HeavyweightTheme.success,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: HeavyweightTheme.spacingSm),
                        Text(
                          '\$59.99/YEAR',
                          style: HeavyweightTheme.bodyMedium,
                        ),
                        Text(
                          '(\$4.99/MONTH)',
                          style: HeavyweightTheme.bodySmall.copyWith(
                            color: HeavyweightTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Purchase button
          CommandButton(
            text: 'COMMAND: PURCHASE',
            onPressed: () {
              // TODO: Implement purchase logic
              _handlePurchase();
            },
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingMd),
          
          CommandButton(
            text: 'COMMAND: CANCEL',
            variant: ButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingXl),
        ],
      ),
    );
  }
  
  void _handlePurchase() {
    // TODO: Implement RevenueCat purchase logic
    final planType = _selectedPlan == 0 ? 'monthly' : 'yearly';
    print('Purchasing $planType plan');
  }
}
