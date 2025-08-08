#!/bin/bash
set -e

# Download and install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"
flutter doctor

# Install dependencies and build
flutter pub get
flutter clean
flutter build web -t lib/main_selector_page.dart --release --base-href / --web-renderer html --pwa-strategy=none

# Debug info - list build output
echo "Build complete. Contents of build/web:"
ls -la build/web/
