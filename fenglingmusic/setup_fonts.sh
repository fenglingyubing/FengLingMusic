#!/bin/bash

# Setup fonts for FengLingMusic Neo-Vinyl design
# This script downloads the required fonts from Google Fonts

echo "🎵 FengLingMusic - Font Setup Script"
echo "=================================="
echo ""

# Create fonts directory
FONTS_DIR="assets/fonts"
mkdir -p "$FONTS_DIR"

echo "📁 Created fonts directory: $FONTS_DIR"
echo ""

# Download Archivo Black
echo "⬇️  Downloading Archivo Black..."
ARCHIVO_URL="https://github.com/google/fonts/raw/main/ofl/archivoblack/ArchivoBlack-Regular.ttf"
curl -L "$ARCHIVO_URL" -o "$FONTS_DIR/ArchivoBlack-Regular.ttf"

if [ -f "$FONTS_DIR/ArchivoBlack-Regular.ttf" ]; then
    echo "✅ Archivo Black downloaded successfully"
else
    echo "❌ Failed to download Archivo Black"
fi

echo ""

# Download Inter fonts
echo "⬇️  Downloading Inter fonts..."

INTER_BASE="https://github.com/rsms/inter/raw/master/docs/font-files"

curl -L "$INTER_BASE/Inter-Regular.ttf" -o "$FONTS_DIR/Inter-Regular.ttf"
curl -L "$INTER_BASE/Inter-Medium.ttf" -o "$FONTS_DIR/Inter-Medium.ttf"
curl -L "$INTER_BASE/Inter-SemiBold.ttf" -o "$FONTS_DIR/Inter-SemiBold.ttf"
curl -L "$INTER_BASE/Inter-Bold.ttf" -o "$FONTS_DIR/Inter-Bold.ttf"

# Check if all Inter fonts were downloaded
if [ -f "$FONTS_DIR/Inter-Regular.ttf" ] && \
   [ -f "$FONTS_DIR/Inter-Medium.ttf" ] && \
   [ -f "$FONTS_DIR/Inter-SemiBold.ttf" ] && \
   [ -f "$FONTS_DIR/Inter-Bold.ttf" ]; then
    echo "✅ Inter fonts downloaded successfully"
else
    echo "❌ Some Inter fonts failed to download"
fi

echo ""
echo "=================================="
echo "✨ Font setup complete!"
echo ""
echo "Next steps:"
echo "1. Run 'flutter pub get' to refresh dependencies"
echo "2. Run 'flutter clean' if fonts don't load"
echo "3. Restart your app"
echo ""
echo "🎨 Your Neo-Vinyl design is ready!"
