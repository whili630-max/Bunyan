#!/usr/bin/env bash
set -e

# نزّل Flutter (stable) إذا ما كان موجود
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi

# أضف Flutter للـ PATH
export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
