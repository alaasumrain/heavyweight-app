import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/logging.dart';

/// RevenueCat subscription management service
/// Handles all subscription-related operations including purchases, restores, and entitlement checks
class RevenueCatService extends ChangeNotifier {
  static RevenueCatService? _instance;
  static RevenueCatService get instance => _instance ??= RevenueCatService._();

  RevenueCatService._();

  bool _isConfigured = false;
  CustomerInfo? _customerInfo;
  Offerings? _offerings;

  // Getters
  bool get isConfigured => _isConfigured;
  CustomerInfo? get customerInfo => _customerInfo;
  Offerings? get offerings => _offerings;

  /// Check if user has active subscription
  bool get hasActiveSubscription {
    if (_customerInfo?.entitlements.active.isEmpty ?? true) return false;
    return _customerInfo!.entitlements.active.containsKey('pro') ||
        _customerInfo!.entitlements.active.containsKey('premium');
  }

  /// Initialize RevenueCat SDK
  Future<bool> configure({
    required String apiKey,
    String? userId,
  }) async {
    try {
      HWLog.event('revenuecat_configure_start', data: {
        'hasUserId': userId != null,
        'platform': defaultTargetPlatform.name,
      });

      // Enable debug logs in development
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      // Configure SDK with API key (modern configuration object required in v8+)
      final purchasesConfiguration = PurchasesConfiguration(apiKey)
        ..appUserID = userId;

      await Purchases.configure(purchasesConfiguration);

      // Log in user if provided
      if (userId != null && userId.isNotEmpty) {
        await _logInUser(userId);
      }

      // Fetch initial data
      await _fetchCustomerInfo();
      await _fetchOfferings();

      _isConfigured = true;
      notifyListeners();

      HWLog.event('revenuecat_configure_success', data: {
        'hasActiveSubscription': hasActiveSubscription,
        'offeringsCount': _offerings?.all.length ?? 0,
      });

      return true;
    } catch (e, stackTrace) {
      HWLog.event('revenuecat_configure_error', data: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
      return false;
    }
  }

  /// Log in user with RevenueCat
  Future<bool> _logInUser(String userId) async {
    try {
      final result = await Purchases.logIn(userId);
      _customerInfo = result.customerInfo;

      HWLog.event('revenuecat_login_success', data: {
        'userId': userId,
        'originalAppUserId': result.customerInfo.originalAppUserId,
        'created': result.created,
      });

      return true;
    } catch (e) {
      HWLog.event('revenuecat_login_error', data: {
        'userId': userId,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Log out current user
  Future<bool> logOut() async {
    try {
      _customerInfo = await Purchases.logOut();
      notifyListeners();

      HWLog.event('revenuecat_logout_success');
      return true;
    } catch (e) {
      HWLog.event('revenuecat_logout_error', data: {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Fetch current customer info
  Future<bool> _fetchCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      notifyListeners();
      return true;
    } catch (e) {
      HWLog.event('revenuecat_customer_info_error', data: {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Fetch available offerings
  Future<bool> _fetchOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
      return true;
    } catch (e) {
      HWLog.event('revenuecat_offerings_error', data: {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Purchase a product
  Future<CustomerInfo?> purchaseProduct(StoreProduct product) async {
    try {
      HWLog.event('revenuecat_purchase_start', data: {
        'productId': product.identifier,
      });

      final customerInfo = await Purchases.purchaseStoreProduct(product);
      _customerInfo = customerInfo;
      notifyListeners();

      HWLog.event('revenuecat_purchase_success', data: {
        'productId': product.identifier,
        'hasActiveSubscription': hasActiveSubscription,
        'transactionId': 'unknown',
      });

      return customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      final userCancelled =
          errorCode == PurchasesErrorCode.purchaseCancelledError;

      HWLog.event('revenuecat_purchase_error', data: {
        'productId': product.identifier,
        'errorCode': errorCode.toString(),
        'userCancelled': userCancelled,
        'error': e.toString(),
      });

      if (!userCancelled) {
        // Only log non-cancellation errors as actual errors
        HWLog.event('revenuecat_purchase_failed', data: {
          'productId': product.identifier,
          'error': e.toString(),
        });
      }

      return null;
    } catch (e) {
      HWLog.event('revenuecat_purchase_error', data: {
        'productId': product.identifier,
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    try {
      HWLog.event('revenuecat_restore_start');

      _customerInfo = await Purchases.restorePurchases();
      notifyListeners();

      HWLog.event('revenuecat_restore_success', data: {
        'hasActiveSubscription': hasActiveSubscription,
        'entitlementsCount': _customerInfo?.entitlements.active.length ?? 0,
      });

      return true;
    } catch (e) {
      HWLog.event('revenuecat_restore_error', data: {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Refresh customer info (force fetch from server)
  Future<bool> refreshCustomerInfo() async {
    try {
      await Purchases.invalidateCustomerInfoCache();
      return await _fetchCustomerInfo();
    } catch (e) {
      HWLog.event('revenuecat_refresh_error', data: {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Get specific offering by identifier
  Offering? getOffering(String identifier) {
    return _offerings?.getOffering(identifier);
  }

  /// Get current offering (usually the default)
  Offering? get currentOffering => _offerings?.current;

  /// Check if specific entitlement is active
  bool hasEntitlement(String entitlementId) {
    return _customerInfo?.entitlements.active[entitlementId]?.isActive ?? false;
  }

  /// Get all available products
  List<StoreProduct> get availableProducts {
    final products = <StoreProduct>[];
    _offerings?.all.forEach((key, offering) {
      products.addAll(offering.availablePackages.map((p) => p.storeProduct));
    });
    return products;
  }

  @override
  void dispose() {
    // RevenueCat doesn't need explicit disposal - it handles lifecycle automatically
    super.dispose();
  }
}
