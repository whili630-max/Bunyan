#!/usr/bin/env bash
set -euo pipefail

echo "===== Environment ====="
uname -a
echo "NODE_VERSION: ${NODE_VERSION:-unset}"

git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --enable-web
flutter doctor -v

flutter pub get
flutter clean
flutter build web -t lib/main_selector_page.dart --release --base-href / --web-renderer html --pwa-strategy=none

test -f build/web/index.html || (echo "❌ index.html missing" && exit 1)
cp -f build/web/index.html build/web/404.html

echo "===== build/web ====="
ls -la build/web/
echo "===== icons ====="
ls -la build/web/icons/ || echo "no icons dir!"
