#!/bin/bash

# Launch Fortress Mode - Complete ideological takeover
# This script launches the app in fortress mode, bypassing all legacy code

echo "============================================"
echo "        FORTRESS MODE ACTIVATION"
echo "============================================"
echo ""
echo "The mandate is absolute."
echo "Recovery is not optional."
echo "The system needs truth."
echo ""
echo "============================================"

# Set the entry point to fortress
export FLUTTER_ENTRY_POINT="lib/main_fortress.dart"

# Clean previous builds
echo "Purging legacy remnants..."
flutter clean

# Get dependencies
echo "Initializing fortress systems..."
flutter pub get

# Build for web with HTML renderer
echo "Constructing the fortress..."
flutter build web --web-renderer html --dart-define=entry-point=fortress

# Launch the server
echo ""
echo "============================================"
echo "FORTRESS ACTIVE AT: http://88.99.34.44:8080"
echo "============================================"
echo ""
echo "BEGIN PROTOCOL when ready."
echo ""

# Start Python server for the fortress
cd build/web
python3 -m http.server 8080 --bind 0.0.0.0