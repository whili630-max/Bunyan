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

# Resolve Flutter ref; support branches or tags; default to stable
REF="${FLUTTER_VERSION:-stable}"
REPO="https://github.com/flutter/flutter.git"
INSTALL_DIR="$HOME/flutter"

echo "Requested Flutter ref: $REF"
rm -rf "$INSTALL_DIR"
# Start from stable to ensure a valid checkout exists
if ! git clone --depth 1 --branch stable "$REPO" "$INSTALL_DIR"; then
  git clone --depth 1 "$REPO" "$INSTALL_DIR"
fi

pushd "$INSTALL_DIR"
# Try branch first
if git ls-remote --heads origin "$REF" | grep -q "$REF"; then
  git fetch --depth 1 origin "$REF"
  git checkout -B "$REF" "origin/$REF"
# Then try tag
elif git ls-remote --tags origin "refs/tags/$REF" | grep -q "$REF"; then
  git fetch --depth 1 origin "refs/tags/$REF:refs/tags/$REF" || true
  git checkout -f "refs/tags/$REF" || git checkout -f "tags/$REF" || true
else
  echo "Ref '$REF' not found; using stable"
fi
popd

export PATH="$INSTALL_DIR/bin:$PATH"
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