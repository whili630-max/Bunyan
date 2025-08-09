#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION=3.22.2

echo "Downloading Flutter SDK..."
curl -L -o flutter_linux.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
tar xf flutter_linux.tar.xz

export PATH="$PWD/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web -t lib/main_selector_page.dart --release --no-tree-shake-icons