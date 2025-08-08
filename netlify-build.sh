#!/usr/bin/env bash
set -euo pipefail

# 1) جلب Flutter (قليل العمق لتسريع)
git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"

# 2) تفعيل Flutter للويب
export PATH="$HOME/flutter/bin:$PATH"
echo "تحقق من مسار Flutter:"
which flutter || echo "Flutter غير موجود في PATH"
flutter --version
echo "تفعيل دعم الويب:"
flutter config --enable-web
echo "فحص تثبيت Flutter:"
flutter doctor -v

# 3) تثبيت تبعيات المشروع وبناء الويب
flutter pub get
flutter clean
flutter build web --release --base-href /

# 4) تأكيد وجود index.html
test -f build/web/index.html || (echo "❌ index.html غير موجود في build/web" && exit 1)

# 5) إنشاء 404.html (احتياط)
cp -f build/web/index.html build/web/404.html

# 6) عرض محتويات مجلد النشر للتأكد
echo "===== محتويات مجلد النشر ====="
ls -la build/web/
echo "===== عرض حجم ملفات البناء ====="
du -h build/web/ | sort -hr
echo "===== تأكيد وجود الملفات الرئيسية ====="
[ -f build/web/index.html ] && echo "✓ index.html موجود" || echo "✗ index.html غير موجود!"
[ -f build/web/main.dart.js ] && echo "✓ main.dart.js موجود" || echo "✗ main.dart.js غير موجود!"
[ -f build/web/flutter.js ] && echo "✓ flutter.js موجود" || echo "✗ flutter.js غير موجود!"
