#!/usr/bin/env bash
set -euo pipefail
set -x
git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION:-stable} --depth 1 "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --enable-web
flutter doctor -v
flutter pub get
flutter clean
flutter build web --release --target=lib/main_client.dart
cp -f web/index.html build/web/index.html
cp -f build/web/index.html build/web/404.html
echo "===== verify modern loader ====="
grep -n "flutter_bootstrap.js" build/web/index.html || { echo "ERROR: modern loader not found"; exit 1; }
echo "===== list build/web ====="
ls -la build/web/