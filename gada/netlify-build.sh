#!/usr/bin/env bash
set -euo pipefail
set -x

echo "===== show script contents ====="
cat netlify-build.sh || true

git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION:-stable} --depth 1 "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --enable-web
flutter doctor -v

flutter pub get
flutter clean
flutter build web --release --target=lib/main_client.dart

test -f build/web/index.html
cp -f build/web/index.html build/web/404.html

echo "===== list build/web ====="
ls -la build/web/