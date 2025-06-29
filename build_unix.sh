#!/bin/bash

echo "============================================"
echo "Universal File Converter - Unix Build Tool"
echo "============================================"
echo ""

# Check for Python installation
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 not found!"
    echo "Please install Python 3.8 or higher and ensure it's in your PATH."
    exit 1
fi

# Check Python version
PYVER=$(python3 --version 2>&1)
echo "Detected Python: $PYVER"

# Function to check and install Python packages
check_package() {
    python3 -c "import $1" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "$1 not found. Installing..."
        python3 -m pip install $1
        if [ $? -ne 0 ]; then
            echo "Failed to install $1. Aborting."
            exit 1
        fi
    fi
}

# Check for required Python packages
echo "Checking for required packages..."

# Check for PyInstaller
check_package PyInstaller

# Check for PyQt6
check_package PyQt6

# Check for other dependencies
for pkg in tqdm requests; do
    check_package $pkg
done

echo "All required packages found or installed."

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    echo "Detected platform: macOS"
else
    PLATFORM="linux"
    echo "Detected platform: Linux"
fi

# Create portable_tools directory if it doesn't exist
if [ ! -d "portable_tools" ]; then
    echo "Creating portable_tools directory..."
    mkdir -p portable_tools
fi

# Create tool directories if they don't exist
for dir in ffmpeg pandoc libreoffice; do
    if [ ! -d "portable_tools/$dir" ]; then
        echo "Creating portable_tools/$dir directory..."
        mkdir -p "portable_tools/$dir/bin"
    fi
done

# Ensure src directory exists
if [ ! -d "src" ]; then
    echo "Error: src directory not found!"
    echo "This script must be run from the project root directory."
    exit 1
fi

# Clean up any previous build
echo "Cleaning up previous builds..."
rm -rf build dist
rm -f universal-converter.spec

# Create the spec file
echo "Using custom spec file..."
cp -f universal-converter.spec pyinstaller-spec.py 2>/dev/null || {
    echo "Generating PyInstaller spec file..."
    
    # Generate the GUI spec file
    python3 -m PyInstaller --name=universal-converter \
      --noconfirm \
      --windowed \
      --add-data="resources:resources" \
      --hidden-import=PyQt6.QtCore \
      --hidden-import=PyQt6.QtGui \
      --hidden-import=PyQt6.QtWidgets \
      src/main_gui.py

    # Add the CLI version to the spec file
    python3 -m PyInstaller --name=universal-converter-cli \
      --noconfirm \
      --console \
      --add-data="resources:resources" \
      --hidden-import=converters.ffmpeg \
      --hidden-import=converters.pandoc \
      --hidden-import=converters.libreoffice \
      src/main.py
}

# Build the package
echo "Building the executable package..."
python3 -m PyInstaller universal-converter.spec --noconfirm --clean

if [ $? -ne 0 ]; then
    echo "Build failed. Please check the errors above."
    exit 1
fi

# Copy the README and licenses
echo "Copying documentation files..."
cp README.md dist/universal-converter/ 2>/dev/null
cp LICENSE dist/universal-converter/ 2>/dev/null

# Create version file
echo "Creating version file..."
echo "Universal File Converter v1.0" > dist/universal-converter/version.txt
echo "Build date: $(date)" >> dist/universal-converter/version.txt

# Create app bundle for macOS
if [[ "$PLATFORM" == "macos" ]]; then
    echo "Creating macOS app bundle..."
    
    # Check if app bundle exists
    if [ -d "dist/UniversalConverter.app" ]; then
        echo "macOS app bundle created at: $(pwd)/dist/UniversalConverter.app"
    else
        echo "Warning: macOS app bundle not created. You may need to add app bundle configuration to the spec file."
    fi
fi

echo ""
echo "============================================"
echo "Build completed successfully!"
echo ""
if [[ "$PLATFORM" == "macos" ]]; then
    echo "The executable package is available in:"
    echo "$(pwd)/dist/universal-converter/universal-converter"
    if [ -d "dist/UniversalConverter.app" ]; then
        echo ""
        echo "macOS app bundle:"
        echo "$(pwd)/dist/UniversalConverter.app"
    fi
else
    echo "The executable package is available in:"
    echo "$(pwd)/dist/universal-converter/universal-converter"
fi
echo ""
echo "To run the command-line version:"
echo "$(pwd)/dist/universal-converter/universal-converter-cli"
echo "============================================"

# Ask to create a tar.gz package
echo ""
read -p "Would you like to create a compressed package of the build? (y/n): " MAKE_PACKAGE

if [[ "$MAKE_PACKAGE" == "y" || "$MAKE_PACKAGE" == "Y" ]]; then
    echo "Creating compressed package..."
    
    BUILD_DATE=$(date +%Y%m%d)
    
    if [[ "$PLATFORM" == "macos" ]]; then
        # For macOS, create a DMG if possible
        if command -v hdiutil &> /dev/null; then
            echo "Creating DMG package..."
            hdiutil create -volname "UniversalConverter" -srcfolder dist/universal-converter -ov -format UDZO "dist/universal-converter-$BUILD_DATE.dmg"
            echo "DMG package created at:"
            echo "$(pwd)/dist/universal-converter-$BUILD_DATE.dmg"
        else
            # Fallback to tar.gz if hdiutil is not available
            tar -czf "dist/universal-converter-$BUILD_DATE.tar.gz" -C dist universal-converter
            echo "Tar.gz package created at:"
            echo "$(pwd)/dist/universal-converter-$BUILD_DATE.tar.gz"
        fi
    else
        # For Linux, create a tar.gz
        tar -czf "dist/universal-converter-$BUILD_DATE.tar.gz" -C dist universal-converter
        echo "Tar.gz package created at:"
        echo "$(pwd)/dist/universal-converter-$BUILD_DATE.tar.gz"
    fi
fi

echo ""
echo "Build process complete."