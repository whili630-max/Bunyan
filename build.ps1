$ErrorActionPreference = "Stop"

# إعدادات
$ref = $env:FLUTTER_VERSION
if ([string]::IsNullOrEmpty($ref)) { $ref = "stable" }

$repo = "https://github.com/flutter/flutter.git"
$installDir = Join-Path $env:USERPROFILE "flutter"

# تنظيف وتثبيت Flutter مستقل
if (Test-Path $installDir) { Remove-Item $installDir -Recurse -Force }
git clone --depth 1 --branch stable $repo $installDir | Out-Null

# لو بتستخدم ref غير stable ضعه هنا بـ git checkout

# حدث PATH مؤقتا للجلسة
$env:Path = "$installDir\bin;$env:Path"

# أوامر Flutter
flutter --version
flutter config --enable-web
flutter doctor -v
flutter pub get
flutter clean

# اختيار target اختياري
$target = ""
if (Test-Path "lib\main_client.dart") { $target = "--target=lib/main_client.dart" }

# البناء
flutter build web --release $target

# 404.html لتوجيهات SPA
Copy-Item "build\web\index.html" "build\web\404.html" -Force

Write-Host "`n Done. Output: build/web"
