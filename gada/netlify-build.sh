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

# 🔧 توليد الأيقونات أولاً لضمان دخولها داخل build
dart run lib/generate_icons.dart || echo "Icon generation skipped"

# ⬇️ ابنِ من main.dart بعد توفر الأيقونات الصحيحة
flutter build web --release --target=lib/main.dart

# نسخ الأيقونات المولَّدة إلى مجلد البناء (إذا لم ينسخها Flutter لأنه قد يعتمد النسخ السابقة)
cp -f web/icons/Icon-192.png build/web/icons/Icon-192.png || true
cp -f web/icons/Icon-512.png build/web/icons/Icon-512.png || true

# إزالة أي بقايا لملفات flutter.js القديمة إن وُجدت
rm -f build/web/flutter.js || true
sed -i 's/_flutter[[:alnum:]_.-]*//g' build/web/index.html || true

# ملفات مساعدة للنشر
test -f build/web/_redirects || echo "/* /index.html 200" > build/web/_redirects
cp -f build/web/index.html build/web/404.html

echo "تم بناء التطبيق بنجاح من lib/main.dart"
