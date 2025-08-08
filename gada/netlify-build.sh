#!/usr/bin/env bash
# Force exit on errors and undefined variables
set -euo pipefail
set -x  # أطبع الأوامر في اللوج للتأكد

# Show script location to verify we're using the right script
echo "===== Script location ====="
SCRIPT_PATH=$(readlink -f "$0")
echo "Running script: $SCRIPT_PATH"
echo "Working directory: $(pwd)"
echo "Contents of current directory:"
ls -la

echo "===== Environment ====="
uname -a
echo "NODE_VERSION: ${NODE_VERSION:-none}"

echo "===== Searching for web-renderer references ====="
find . -type f -exec grep -l -- "--web-renderer" {} \; || true

# إعداد Flutter
git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION:-stable} --depth 1 "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --enable-web
flutter doctor -v

# بناء الويب من نقطة الدخول الخاصة بالعميل
flutter pub get
flutter clean

# Very simple build command with minimal options
echo "Running Flutter build with minimal options"
# First try without any extra flags
flutter build web --release --target=lib/main_client.dart

# If the above build fails, try with just --release
if [ $? -ne 0 ]; then
  echo "First build attempt failed, trying again with just --release"
  flutter build web --release
fi

# تأكيد المخرجات
test -f build/web/index.html
cp -f build/web/index.html build/web/404.html

echo "===== list build/web ====="
ls -la build/web/
