#!/bin/bash
# iOS Release Build Script for HEAVYWEIGHT
# This script builds the app with proper environment configuration for TestFlight

set -e  # Exit on any error

echo "🏗️  Building HEAVYWEIGHT for iOS Release..."
echo "📋 Using credentials from env.json"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf ios/build
rm -rf build

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build iOS release with environment variables from env.json
echo "🔨 Building iOS release archive..."
flutter build ios \
  --release \
  --dart-define-from-file=env.json \
  --no-codesign

echo "✅ Build complete!"
echo ""
echo "🚀 Next steps for TestFlight:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Select 'Any iOS Device (arm64)' as target"
echo "3. Product → Archive"
echo "4. Distribute App → App Store Connect"
echo ""
echo "⚠️  Important: The env.json file contains your Supabase credentials"
echo "   Make sure these are properly configured before archiving"