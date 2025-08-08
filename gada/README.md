# Bunyan App

## Deploying to Netlify

This Flutter web application is configured for deployment on Netlify. The build process:

1. Installs Flutter in the Netlify build environment
2. Builds the web application with the selected entry point (`lib/main_selector_page.dart`)
3. Deploys the built files to Netlify hosting

### Important Notes

- Make sure all files in the `web/icons/` directory are actual PNG images with the correct dimensions:
  - `Icon-192.png` (192×192 pixels)
  - `Icon-512.png` (512×512 pixels)

- The `netlify-build.sh` script must have Unix-style line endings (LF, not CRLF) and executable permissions
  - The `setup.sh` script ensures this during the build process

- If you encounter build failures, check the Netlify logs for specific error messages

### Local Development

To run the app locally:

```bash
flutter pub get
flutter run -d chrome -t lib/main_selector_page.dart
```

### Building for Production

To build the app for production locally:

```bash
flutter build web -t lib/main_selector_page.dart --release
```

The output will be in the `build/web` directory, which can be deployed to any static web hosting service.
