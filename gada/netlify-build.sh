#!/usr/bin/env bash
set -euo pipefail
set -x  # أطبع الأوامر في اللوج للتأكد

echo "===== show script contents ====="
cat netlify-build.sh || true

# إعداد Flutter
git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION:-stable} --depth 1 "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --enable-web
flutter doctor -v

# بناء الويب من نقطة الدخول الخاصة بالعميل
flutter pub get
flutter clean
flutter build web -t lib/main_client.dart --release --base-href /

# تأكيد المخرجات
test -f build/web/index.html
cp -f build/web/index.html build/web/404.html

echo "===== list build/web ====="
ls -la build/web/
