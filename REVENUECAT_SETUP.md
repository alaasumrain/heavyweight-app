# RevenueCat Integration Setup Guide

This guide walks you through setting up RevenueCat for in-app subscriptions in the Heavyweight app.

## Prerequisites

1. RevenueCat account (free at https://www.revenuecat.com/)
2. Apple Developer account (for iOS)
3. Google Play Console account (for Android)

## Step 1: Create RevenueCat Project

1. Sign up at https://www.revenuecat.com/
2. Create a new project called "Heavyweight"
3. Note your API key from the dashboard

## Step 2: Configure App Store Connect (iOS)

1. Go to App Store Connect
2. Create your app if not exists
3. Go to Features → In-App Purchases
4. Create subscription products:
   - **Monthly**: `heavyweight_monthly` - $9.99/month
   - **Annual**: `heavyweight_annual` - $59.99/year

### Product Configuration
- **Reference Name**: "Heavyweight Pro Monthly" / "Heavyweight Pro Annual"
- **Product ID**: `heavyweight_monthly` / `heavyweight_annual`
- **Auto-renewable subscription**: Yes
- **Subscription Group**: Create "Heavyweight Pro"

## Step 3: Configure Google Play Console (Android)

1. Go to Google Play Console
2. Select your app
3. Go to Monetize → Products → Subscriptions
4. Create the same products with matching IDs

## Step 4: Connect RevenueCat to Stores

### iOS Setup
1. In RevenueCat dashboard → Project Settings → Apps
2. Add iOS app
3. Enter your Bundle ID
4. Upload App Store Connect API Key:
   - Go to App Store Connect → Users and Access → Keys
   - Create new API key with "Developer" role
   - Download and upload to RevenueCat

### Android Setup
1. Add Android app in RevenueCat
2. Enter your Package Name
3. Upload Google Play Service Account Key:
   - Go to Google Play Console → Setup → API Access
   - Create new service account
   - Grant "Viewer" permissions
   - Download JSON key and upload to RevenueCat

## Step 5: Configure Products in RevenueCat

1. Go to Products in RevenueCat dashboard
2. Import your products from both stores
3. Create entitlements:
   - **pro**: Maps to both monthly and annual subscriptions

## Step 6: Update App Configuration

1. **Add your RevenueCat API key** - You have two options:

### Option A: Environment Variable (Recommended)
```bash
# Run your app with the API key as an environment variable
flutter run --dart-define=REVENUECAT_API_KEY=rcv_your_actual_api_key_here
```

### Option B: Direct Configuration (for testing)
Edit `lib/main.dart` and replace the TODO comment:
```dart
// Replace this line:
const revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');

// With your actual API key:
const revenueCatApiKey = 'rcv_your_actual_api_key_here';
```

2. **The subscription screen is already implemented** and will automatically:
   - Load available packages from RevenueCat
   - Handle purchases and restore functionality
   - Show appropriate error messages
   - Check for `pro` entitlement (matches your RevenueCat setup)

## Step 7: Test Your Implementation

### iOS Testing
1. Create sandbox test users in App Store Connect
2. Sign into sandbox account on device
3. Test purchases (they'll be free in sandbox)

### Android Testing
1. Upload signed APK to Google Play Internal Testing track
2. Add test accounts to license testing
3. Test purchases

## Step 8: Entitlement Checks

The app automatically checks for active subscriptions using:

```dart
bool hasSubscription = RevenueCatService.instance.hasActiveSubscription;
```

You can also check specific entitlements:

```dart
bool hasPro = RevenueCatService.instance.hasEntitlement('pro');
```

## Security Notes

- **Never commit API keys to version control**
- Store API keys in environment variables or secure config
- Use different API keys for development/production
- Test thoroughly in sandbox before production

## Troubleshooting

### Common Issues

1. **"No packages found"**
   - Ensure products are created in both stores
   - Check product IDs match exactly
   - Verify RevenueCat import was successful

2. **"Purchase failed"**
   - Check network connectivity
   - Verify sandbox test account setup
   - Ensure app is signed properly

3. **"Restore failed"**
   - Test user must have made previous purchases
   - Check Apple/Google account is same as purchase account

## Production Checklist

- [ ] API keys configured for production
- [ ] Products created in both App Store and Play Store
- [ ] RevenueCat connected to both stores
- [ ] Entitlements properly configured
- [ ] Sandbox testing completed
- [ ] Privacy policy updated for subscriptions
- [ ] App Store/Play Store metadata includes subscription info

## Support

For RevenueCat specific issues:
- Documentation: https://docs.revenuecat.com/
- Support: support@revenuecat.com

For app-specific integration issues, check the `RevenueCatService` implementation in `lib/services/revenue_cat_service.dart`.