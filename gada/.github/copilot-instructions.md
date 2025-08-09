# Bunyan Flutter Web App Instructions

## Project Overview
Bunyan is a Flutter web application with multiple entry points that can be deployed to Netlify. The application has different modes (client, selector) and uses a standard Flutter architecture.

## Key Architecture Components

### Entry Points
- `lib/main.dart`: Standard Flutter app entry point (demo counter app)
- `lib/main_selector_page.dart`: **Primary entry point** for production, provides mode selection screen
- `lib/main_client.dart`: Client portal interface

### Web Configuration
- `web/index.html`: Core HTML wrapper with Arabic loading text and Flutter bootstrapping
- `web/manifest.json`: Progressive Web App configuration with app metadata and icons
- Favicons: Multiple formats in `web/icons/` and root-level `favicon.ico`

### Deployment Configuration
- `netlify-build.sh`: Installs Flutter SDK and builds the web app for Netlify
- `netlify.toml`: Configures Netlify build settings and publish directory
- `setup.sh`: Sets executable permissions for build scripts

## Development Workflows

### Local Development
```bash
flutter pub get
flutter run -d chrome -t lib/main_selector_page.dart
```

### Production Build
```bash
flutter build web -t lib/main_selector_page.dart --release
```

### Deployment
The app is configured for automatic deployment to Netlify when pushing to the main branch.

## Project Conventions

### Multilingual Support
- The app includes Arabic text support (RTL), as seen in loading messages like "جاري تحميل التطبيق..."
- When editing text in HTML files, preserve the RTL text direction and ensure proper UTF-8 encoding

### Web-Specific Configurations
- Service workers are currently disabled with `var serviceWorkerVersion = null;`
- The app uses Flutter's new loader API: `_flutter.loader.load()`
- UTF-8 encoding without BOM is critical for HTML files (use `[System.IO.File]::WriteAllText()` with `$utf8NoBom = New-Object System.Text.UTF8Encoding($false)` if editing on Windows)
- The loading screen text appears while Flutter initializes

## Integration Points

### Browser Compatibility
- Multiple favicon formats are provided for cross-browser compatibility
- Cache control headers prevent stale favicon caching

### Flutter Web Optimizations
- The build process uses `--no-tree-shake-icons` to preserve all icons
- The Flutter version used for Netlify builds is specified in `netlify-build.sh` (currently 3.22.2)

## File Organization
- Entry point files (`main*.dart`) are in the root of the `lib/` directory
- Web assets (HTML, icons, manifest) are in the `web/` directory
- Build configuration is in the project root

## Common Pitfalls
- Ensure all icon files in `web/icons/` are actual PNG images with correct dimensions (192×192, 512×512)
- Build scripts require Unix-style line endings (LF, not CRLF)
- The `setup.sh` script must be run before deployment to set correct permissions
- Favicon needs multiple formats to ensure cross-browser compatibility
- Remember to use cache-busting techniques for favicon updates (e.g., `?v=2` suffix)
- When updating web content, test on multiple browsers to ensure compatibility
