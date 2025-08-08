#!/usr/bin/env bash
set -euo pipefail

# 1) جلب Flutter (قليل العمق لتسريع)
git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"

# 2) تفعيل Flutter للويب
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --enable-web
flutter doctor -v

# 3) تثبيت تبعيات المشروع وبناء الويب
flutter pub get
flutter clean
flutter build web --release --web-renderer canvaskit --base-href /

# 4) تأكيد وجود index.html
test -f build/web/index.html || (echo "❌ index.html غير موجود في build/web" && exit 1)

# 5) إنشاء 404.html (احتياط)
cp -f build/web/index.html build/web/404.html

# 6) عرض محتويات مجلد النشر للتأكد
echo "===== محتويات مجلد النشر ====="
ls -la build/web/
