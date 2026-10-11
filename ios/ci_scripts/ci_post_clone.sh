#!/bin/sh
set -e
set -x

# Xcode Cloud starts from a clean clone, so the gitignored ios/Flutter/ephemeral
# directory (including FlutterGeneratedPluginSwiftPackage) must be regenerated.
cd "$CI_PRIMARY_REPOSITORY_PATH"

FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_DIR"
fi
export PATH="$PATH:$FLUTTER_DIR/bin"

flutter precache --ios
flutter pub get

# Generates ios/Flutter/ephemeral and Generated.xcconfig without code signing.
flutter build ios --config-only --no-codesign

# The project still links CocoaPods plugins (Pods_Runner.framework).
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods || true
cd ios && pod install

exit 0
