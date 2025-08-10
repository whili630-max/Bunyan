#!/usr/bin/env bash
set -euo pipefail

unset FLUTTER_TOOL_ARGS EXTRA_FRONT_END_OPTIONS EXTRA_FRONTEND_OPTIONS DART_VM_OPTIONS DART_FLAGS DART_DEFINES || true

REF="${FLUTTER_VERSION:-stable}"
REPO="https://github.com/flutter/flutter.git"
INSTALL_DIR="$HOME/flutter"
rm -rf "$INSTALL_DIR"
if ! git clone --depth 1 --branch stable "$REPO" "$INSTALL_DIR"; then
  git clone --depth 1 "$REPO" "$INSTALL_DIR"
fi
pushd "$INSTALL_DIR" >/dev/null
if git ls-remote --heads origin "$REF" | grep -q "$REF"; then
  git fetch --depth 1 origin "$REF" && git checkout -B "$REF" "origin/$REF"
elif git ls-remote --tags origin "refs/tags/$REF" | grep -q "$REF"; then
  git fetch --depth 1 origin "refs/tags/$REF:refs/tags/$REF" || true
  git checkout -f "refs/tags/$REF" || git checkout -f "tags/$REF" || true
fi
popd >/dev/null
export PATH="$INSTALL_DIR/bin:$PATH"

flutter --version
flutter config --enable-web
flutter doctor -v
flutter pub get
flutter clean

# حدد الهدف تلقائيا
TARGET=""
if [ -f "lib/main_client.dart" ]; then
  TARGET="--target=lib/main_client.dart"
fi

flutter build web --release $TARGET

test -f build/web/index.html
cp -f build/web/index.html build/web/404.html
echo "===== list build/web (root) ====="
ls -la build/web/