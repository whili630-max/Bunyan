#!/usr/bin/env bash
set -euo pipefail
set -x  # طباعة كل الأوامر للتأكد

echo "===== dump working dir ====="
pwd
ls -la

echo "===== show script contents ====="
# أطبع هذا الملف نفسه عشان نتأكد Netlify شاف التعديلات
cat netlify-build.sh

# Flutter setup
git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION:-stable} --depth 1 "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --enable-web
flutter doctor -v

# Build (بدون أي فلاغ مختلف)
flutter pub get
flutter clean
flutter build web -t lib/main_selector_page.dart --release --base-href /

# Ensure outputs
test -f build/web/index.html
cp -f build/web/index.html build/web/404.html

echo "===== list build/web ====="
ls -la build/web/
