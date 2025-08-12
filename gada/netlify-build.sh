#!/usr/bin/env bash
set -e

# نثبت Flutter (stable) إذا ما كان موجود
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi

# نضيفه للـ PATH في نفس الشيل
export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release
