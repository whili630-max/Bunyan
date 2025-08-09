#!/bin/bash
set -e

echo "Starting Netlify build script..."

# Build the Flutter web app
echo "Building Flutter web app..."
flutter build web --release

# Verify the build output directory exists
if [ ! -d "build/web" ]; then
  echo "Error: build/web directory not found!"
  exit 1
fi

# Ensure we're using the modern index.html with flutter_bootstrap.js
echo "Ensuring modern index.html is used..."

# Try our template first
if [ -f "web/index.html.template" ]; then
  echo "Using web/index.html.template as source"
  cp web/index.html.template build/web/index.html
# Then try various fallback options
elif [ -f "web/index.modern.html" ]; then
  echo "Using web/index.modern.html as source"
  cp web/index.modern.html build/web/index.html
elif [ -f "web/index.html" ]; then
  echo "Using web/index.html as source"
  cp web/index.html build/web/index.html
fi

# Verify that the final index.html has the expected modern content
if ! grep -q "flutter_bootstrap.js" "build/web/index.html"; then
  echo "Warning: flutter_bootstrap.js not found in final index.html!"
  # As a last resort, inject the script tag
  sed -i 's#</head>#<script src="flutter_bootstrap.js" async></script></head>#' build/web/index.html
fi

# Verify viewport meta tag is present
if ! grep -q "viewport" "build/web/index.html"; then
  echo "Warning: viewport meta tag not found in final index.html!"
  # Add viewport meta tag if missing
  sed -i 's#<head>#<head><meta name="viewport" content="width=device-width, initial-scale=1.0">#' build/web/index.html
fi

echo "Netlify build completed successfully!"
