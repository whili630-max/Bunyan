#!/usr/bin/env bash
set -euo pipefail
set -x

unset FLUTTER_TOOL_ARGS EXTRA_FRONT_END_OPTIONS EXTRA_FRONTEND_OPTIONS DART_VM_OPTIONS DART_FLAGS DART_DEFINES || true

REF="${FLUTTER_VERSION:-stable}"
REPO="https://github.com/flutter/flutter.git"
INSTALL_DIR="$HOME/flutter"

rm -rf "$INSTALL_DIR"
if ! git clone --depth 1 --branch stable "$REPO" "$INSTALL_DIR"; then
  git clone --depth 1 "$REPO" "$INSTALL_DIR"
fi

pushd "$INSTALL_DIR"
if git ls-remote --heads origin "$REF" | grep -q "$REF"; then
  git fetch --depth 1 origin "$REF"
  git checkout -B "$REF" "origin/$REF"
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

flutter pub get
flutter clean
flutter build web --release --target=lib/main.dart

test -f build/web/index.html
cp -f build/web/index.html build/web/404.html
ls -la build/web/