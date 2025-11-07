import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../components/ui/command_button.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../services/revenue_cat_service.dart';
import '../../core/logging.dart';

/// Subscription plans selection screen
class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  final _revenueCatService = RevenueCatService.instance;

  int _selectedPlan = 1; // 0 = monthly, 1 = yearly
  bool _isLoading = false;
  String? _error;
  List<Package> _availablePackages = [];

  @override
  void initState() {
    super.initState();
    HWLog.screen('Paywall/SubscriptionPlans');
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    if (!_revenueCatService.isConfigured) {
      setState(() {
        _error = 'SERVICE_NOT_CONFIGURED';
      });
      return;
    }

    final offering = _revenueCatService.currentOffering;
    if (offering != null) {
      setState(() {
        _availablePackages = offering.availablePackages;
        // Try to find monthly and yearly packages
        final monthly = _availablePackages
            .where((p) => p.packageType == PackageType.monthly)
            .firstOrNull;
        final yearly = _availablePackages
            .where((p) => p.packageType == PackageType.annual)
            .firstOrNull;

        if (monthly == null || yearly == null) {
          _error = 'PACKAGES_NOT_FOUND';
        }
      });
    } else {
      setState(() {
        _error = 'OFFERINGS_NOT_AVAILABLE';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeavyweightScaffold(
      title: 'SUBSCRIPTION_PLANS',
      body: Column(
        children: [
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
              margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
              decoration: BoxDecoration(
                border: Border.all(color: HeavyweightTheme.danger),
                color: HeavyweightTheme.danger.withValues(alpha: 0.1),
              ),
              child: Text(
                _error!,
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: HeavyweightTheme.danger,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          // Plan selection
          Expanded(
            child: _availablePackages.isNotEmpty
                ? Column(
                    children: _availablePackages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final package = entry.value;
                      final isSelected = _selectedPlan == index;
                      final isYearly =
                          package.packageType == PackageType.annual;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedPlan = index),
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(HeavyweightTheme.spacingMd),
                          margin: const EdgeInsets.only(
                              bottom: HeavyweightTheme.spacingMd),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? HeavyweightTheme.primary
                                  : HeavyweightTheme.secondary,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected
                                ? HeavyweightTheme.primary
                                    .withValues(alpha: 0.1)
                                : Colors.transparent,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    package.storeProduct.title.toUpperCase(),
                                    style: HeavyweightTheme.h4.copyWith(
                                      color: isSelected
                                          ? HeavyweightTheme.primary
                                          : HeavyweightTheme.textPrimary,
                                    ),
                                  ),
                                  if (isYearly) ...[
                                    const SizedBox(
                                        width: HeavyweightTheme.spacingSm),
                                    Text(
                                      'BEST_VALUE',
                                      style:
                                          HeavyweightTheme.labelSmall.copyWith(
                                        color: HeavyweightTheme.success,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(
                                  height: HeavyweightTheme.spacingSm),
                              Text(
                                package.storeProduct.priceString,
                                style: HeavyweightTheme.bodyMedium.copyWith(
                                  color: isSelected
                                      ? HeavyweightTheme.primary
                                      : HeavyweightTheme.textPrimary,
                                ),
                              ),
                              if (package
                                  .storeProduct.description.isNotEmpty) ...[
                                const SizedBox(
                                    height: HeavyweightTheme.spacingXs),
                                Text(
                                  package.storeProduct.description,
                                  style: HeavyweightTheme.bodySmall.copyWith(
                                    color: HeavyweightTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),

          // Error display
          if (_error != null) ...[
            Padding(
              padding:
                  const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
              child: CommandButton(
                text: 'RETRY',
                variant: ButtonVariant.secondary,
                onPressed: _loadOfferings,
              ),
            ),
          ],

          // Purchase button
          CommandButton(
            text: _isLoading ? 'PROCESSING...' : 'COMMAND: PURCHASE',
            isDisabled: _isLoading ||
                _availablePackages.isEmpty ||
                _selectedPlan >= _availablePackages.length,
            onPressed: () => _handlePurchase(),
          ),

          const SizedBox(height: HeavyweightTheme.spacingMd),

          // Restore button
          CommandButton(
            text: 'RESTORE_PURCHASES',
            variant: ButtonVariant.secondary,
            isDisabled: _isLoading,
            onPressed: () => _handleRestore(),
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

  Future<void> _handlePurchase() async {
    if (_availablePackages.isEmpty ||
        _selectedPlan >= _availablePackages.length) {
      return;
    }

    final selectedPackage = _availablePackages[_selectedPlan];

    setState(() {
      _isLoading = true;
      _error = null;
    });

    HWLog.event('subscription_purchase_attempt', data: {
      'packageType': selectedPackage.packageType.toString(),
      'productId': selectedPackage.storeProduct.identifier,
      'price': selectedPackage.storeProduct.priceString,
    });

    try {
      final result = await _revenueCatService
          .purchaseProduct(selectedPackage.storeProduct);

      if (result != null && mounted) {
        HWLog.event('subscription_purchase_success', data: {
          'productId': selectedPackage.storeProduct.identifier,
          'hasActiveSubscription': _revenueCatService.hasActiveSubscription,
        });

        // Show success and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SUBSCRIPTION_ACTIVATED'),
            backgroundColor: HeavyweightTheme.success,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'PURCHASE_FAILED: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    HWLog.event('subscription_restore_attempt');

    try {
      final success = await _revenueCatService.restorePurchases();

      if (mounted) {
        if (success && _revenueCatService.hasActiveSubscription) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PURCHASES_RESTORED'),
              backgroundColor: HeavyweightTheme.success,
            ),
          );
          Navigator.of(context).pop();
        } else {
          setState(() {
            _error = 'NO_PURCHASES_TO_RESTORE';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'RESTORE_FAILED: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
