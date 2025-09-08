import 'package:flutter/material.dart';
import '../../components/ui/system_banner.dart';
import '../../components/ui/command_button.dart';
import '../../components/layout/heavyweight_scaffold.dart';

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
      body: Column(
        children: [
          const SystemBanner(),
          const SizedBox(height: 40),
          
          const Text(
            'SUBSCRIPTION_PLANS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Plan selection
          Expanded(
            child: Column(
              children: [
                // Monthly plan
                GestureDetector(
                  onTap: () => setState(() => _selectedPlan = 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPlan == 0 ? Colors.white : Colors.grey,
                        width: _selectedPlan == 0 ? 2 : 1,
                      ),
                      color: _selectedPlan == 0 ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONTHLY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$9.99/MONTH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
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
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPlan == 1 ? Colors.white : Colors.grey,
                        width: _selectedPlan == 1 ? 2 : 1,
                      ),
                      color: _selectedPlan == 1 ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'YEARLY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'SAVE_40%',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$59.99/YEAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '(\$4.99/MONTH)',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
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
          
          const SizedBox(height: 16),
          
          CommandButton(
            text: 'COMMAND: CANCEL',
            variant: ButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          const SizedBox(height: 40),
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
