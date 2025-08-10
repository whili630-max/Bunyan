#!/usr/bin/env bash
set -euo pipefail
set -x

unset FLUTTER_TOOL_ARGS || true
unset EXTRA_FRONT_END_OPTIONS || true
unset EXTRA_FRONTEND_OPTIONS || true
unset DART_VM_OPTIONS || true
unset DART_FLAGS || true
unset DART_DEFINES || true

REF="${FLUTTER_VERSION:-stable}"
REPO="https://github.com/flutter/flutter.git"
INSTALL_DIR="$HOME/flutter"
rm -rf "$INSTALL_DIR"
git clone --depth 1 --branch stable "$REPO" "$INSTALL_DIR" || git clone --depth 1 "$REPO" "$INSTALL_DIR"
export PATH="$INSTALL_DIR/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter clean

# بعض الإصدارات ما فيها --web-renderer
if flutter build web -h | grep -q -- '--web-renderer'; then
  RENDER_ARGS=(--web-renderer canvaskit)
else
  RENDER_ARGS=()
fi

flutter build web --release "${RENDER_ARGS[@]:-}" --target=lib/main_client.dart

test -f build/web/index.html
cp -f build/web/index.html build/web/404.html
echo '/* /index.html 200' > build/web/_redirects