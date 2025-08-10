#!/usr/bin/env bash
set -euo pipefail
set -x

REF="${FLUTTER_VERSION:-stable}"
REPO="https://github.com/flutter/flutter.git"
INSTALL_DIR="$HOME/flutter"

rm -rf "$INSTALL_DIR"
git clone --depth 1 --branch stable "$REPO" "$INSTALL_DIR" || git clone --depth 1 "$REPO" "$INSTALL_DIR"
export PATH="$INSTALL_DIR/bin:$PATH"

# ⬇️ مهم: اشتغل داخل مجلد المشروع الحقيقي
cd gada
echo "PWD=$(pwd)"

flutter --version
flutter config --enable-web
flutter pub get
flutter clean

# ⬇️ ابنِ من main.dart
flutter build web --release --target=lib/main.dart

# ملفات مساعدة للنشر
test -f build/web/_redirects || echo "/* /index.html 200" > build/web/_redirects
cp -f build/web/index.html build/web/404.html

echo "تم بناء التطبيق بنجاح من lib/main.dart"
