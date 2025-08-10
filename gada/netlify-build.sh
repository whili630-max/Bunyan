#!/usr/bin/env bash
set -euo pipefail
set -x

REF="${FLUTTER_VERSION:-stable}"
REPO="https://github.com/flutter/flutter.git"
INSTALL_DIR="$HOME/flutter"

rm -rf "$INSTALL_DIR"
git clone --depth 1 --branch stable "$REPO" "$INSTALL_DIR" || git clone --depth 1 "$REPO" "$INSTALL_DIR"
export PATH="$INSTALL_DIR/bin:$PATH"

# â¬‡ï¸ Ù…Ù‡Ù…: Ø§Ø´ØªØºÙ„ Ø¯Ø§Ø®Ù„ Ù…Ø¬Ù„Ø¯ Ø§Ù„Ù…Ø´Ø±ÙˆØ¹ Ø§Ù„Ø­Ù‚ÙŠÙ‚ÙŠ
cd gada
echo "PWD=$(pwd)"

flutter --version
flutter config --enable-web
flutter pub get
flutter clean

# ðŸ”§ ØªÙˆÙ„ÙŠØ¯ Ø§Ù„Ø£ÙŠÙ‚ÙˆÙ†Ø§Øª Ø£ÙˆÙ„Ø§Ù‹ Ù„Ø¶Ù…Ø§Ù† Ø¯Ø®ÙˆÙ„Ù‡Ø§ Ø¯Ø§Ø®Ù„ build
dart run lib/generate_icons.dart || echo "Icon generation skipped"

# â¬‡ï¸ Ø§Ø¨Ù†Ù Ù…Ù† main.dart Ø¨Ø¹Ø¯ ØªÙˆÙØ± Ø§Ù„Ø£ÙŠÙ‚ÙˆÙ†Ø§Øª Ø§Ù„ØµØ­ÙŠØ­Ø©
flutter build web --release --web-renderer canvaskit --target=lib/main_client.dart

# Ù†Ø³Ø® Ø§Ù„Ø£ÙŠÙ‚ÙˆÙ†Ø§Øª Ø§Ù„Ù…ÙˆÙ„Ù‘ÙŽØ¯Ø© Ø¥Ù„Ù‰ Ù…Ø¬Ù„Ø¯ Ø§Ù„Ø¨Ù†Ø§Ø¡ (Ø¥Ø°Ø§ Ù„Ù… ÙŠÙ†Ø³Ø®Ù‡Ø§ Flutter Ù„Ø£Ù†Ù‡ Ù‚Ø¯ ÙŠØ¹ØªÙ…Ø¯ Ø§Ù„Ù†Ø³Ø® Ø§Ù„Ø³Ø§Ø¨Ù‚Ø©)
cp -f web/icons/Icon-192.png build/web/icons/Icon-192.png || true
cp -f web/icons/Icon-512.png build/web/icons/Icon-512.png || true

# Ø§Ø³ØªØ¨Ø¯Ù„ index.html Ø§Ù„Ù†Ø§ØªØ¬ Ø¨Ù†Ø³Ø®Ø© Ø§Ù„Ù†Ø¸ÙŠÙØ© Ø§Ù„Ø­Ø§Ù„ÙŠØ© (Ù„Ù…Ù†Ø¹ Ø£ÙŠ ØªØ¯Ø§Ø®Ù„ Ø³Ø§Ø¨Ù‚ Ù…Ø­ÙÙˆØ¸ ÙÙŠ cache)
cp -f web/index.html build/web/index.html

# Ø¥Ø²Ø§Ù„Ø© Ø£ÙŠ Ø¨Ù‚Ø§ÙŠØ§ Ù„Ù…Ù„ÙØ§Øª flutter.js Ø§Ù„Ù‚Ø¯ÙŠÙ…Ø© Ø¥Ù† ÙˆÙØ¬Ø¯Øª
rm -f build/web/flutter.js || true
sed -i 's/_flutter[[:alnum:]_.-]*//g' build/web/index.html || true

# Ù…Ù„ÙØ§Øª Ù…Ø³Ø§Ø¹Ø¯Ø© Ù„Ù„Ù†Ø´Ø±
test -f build/web/_redirects || echo "/* /index.html 200" > build/web/_redirects
cp -f build/web/index.html build/web/404.html

echo "ØªÙ… Ø¨Ù†Ø§Ø¡ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ Ø¨Ù†Ø¬Ø§Ø­ Ù…Ù† lib/main.dart"


