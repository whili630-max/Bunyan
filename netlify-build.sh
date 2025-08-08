#!/usr/bin/env bash
set -euo pipefail
set -x

echo "===== show script contents (root) ====="
cat netlify-build.sh || true

# Scrub env that might inject extra flags like --web-renderer
unset FLUTTER_TOOL_ARGS || true
unset EXTRA_FRONT_END_OPTIONS || true
unset EXTRA_FRONTEND_OPTIONS || true
unset DART_VM_OPTIONS || true
unset DART_FLAGS || true
unset DART_DEFINES || true

# Choose Flutter ref safely (fallback to stable if invalid)
REQUESTED_REF="${FLUTTER_VERSION:-stable}"
echo "Requested Flutter ref: $REQUESTED_REF"
if ! git ls-remote --heads --tags https://github.com/flutter/flutter.git "$REQUESTED_REF" | grep -q "$REQUESTED_REF"; then
  echo "Requested ref '$REQUESTED_REF' not found in flutter.git; falling back to 'stable'"
  REQUESTED_REF="stable"
fi

git clone https://github.com/flutter/flutter.git -b "$REQUESTED_REF" --depth 1 "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --enable-web
flutter doctor -v

# Build in repo root
flutter pub get
flutter clean
flutter build web --release --target=lib/main_client.dart

# Ensure outputs
test -f build/web/index.html
cp -f build/web/index.html build/web/404.html

echo "===== list build/web (root) ====="
ls -la build/web/