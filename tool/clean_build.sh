#!/usr/bin/env bash
set -euo pipefail

echo "==> Heavyweight super clean"
echo "   This will clear Flutter/Xcode caches and reinstall CocoaPods."

if command -v flutter >/dev/null 2>&1; then
  echo "-> flutter clean"
  flutter clean || true
else
  echo "-> flutter not found; skipping flutter clean"
fi

echo "-> remove ios/Flutter/ephemeral"
rm -rf ios/Flutter/ephemeral || true

if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "-> clear Xcode DerivedData"
  rm -rf ~/Library/Developer/Xcode/DerivedData/* || true
fi

if command -v flutter >/dev/null 2>&1; then
  echo "-> flutter pub get (regenerates ios/Flutter/Generated.xcconfig)"
  flutter pub get
else
  echo "-> flutter not found; skip pub get"
fi

pushd ios >/dev/null
if command -v pod >/dev/null 2>&1; then
  echo "-> pod deintegrate && pod install"
  pod deintegrate || true
  pod install
else
  echo "-> CocoaPods not found; skipping pod steps"
fi
popd >/dev/null

echo "==> Clean complete. Now run: flutter run -d <device>"
