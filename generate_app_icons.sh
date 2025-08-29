#!/bin/bash

# CyberShujaa App Icon Generator
# This script helps you generate the correct app icon sizes for your Flutter app

echo "🎯 CyberShujaa App Icon Generator"
echo "=================================="
echo ""

# Check if logo.png exists
if [ ! -f "assets/images/logo.png" ]; then
    echo "❌ Error: logo.png not found in assets/images/"
    echo "Please place your logo.png file in the assets/images/ directory first."
    exit 1
fi

echo "✅ Found logo.png in assets/images/"
echo ""

# Create icon directories if they don't exist
echo "📁 Creating icon directories..."
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi

echo "✅ Icon directories created"
echo ""

echo "📱 Required icon sizes for Android:"
echo "   - mdpi:    48x48 px"
echo "   - hdpi:    72x72 px"
echo "   - xhdpi:   96x96 px"
echo "   - xxhdpi:  144x144 px"
echo "   - xxxhdpi: 192x192 px"
echo ""

echo "🔄 To generate your app icons, you can:"
echo ""
echo "Option 1: Use an online tool like:"
echo "   - https://appicon.co/"
echo "   - https://www.appicon.co/"
echo "   - https://makeappicon.com/"
echo ""
echo "Option 2: Use ImageMagick (if installed):"
echo "   - convert assets/images/logo.png -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png"
echo "   - convert assets/images/logo.png -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png"
echo "   - convert assets/images/logo.png -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"
echo "   - convert assets/images/logo.png -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"
echo "   - convert assets/images/logo.png -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
echo ""
echo "Option 3: Use a design tool like Figma, Photoshop, or GIMP to resize your logo"
echo ""

echo "🎨 After generating the icons:"
echo "   1. Replace the ic_launcher.png files in each mipmap directory"
echo "   2. Clean and rebuild your Flutter app"
echo "   3. Your new app icon will appear on the home screen!"
echo ""

echo "🚀 Ready to proceed with icon generation!"
