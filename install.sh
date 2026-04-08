#!/bin/bash

# 1. EXPORT variables FIRST so all Wine commands use this specific prefix
export WINEPREFIX="$PWD/Wine-Fuji"
export WINEARCH=win64

# Check if Wine is installed
if ! command -v wine &> /dev/null; then
    echo "Wine is not installed. Please install Wine first."
    exit 1
fi

# Check if winetricks is installed
if ! command -v winetricks &> /dev/null; then
    echo "winetricks is not installed. Please install winetricks."
    exit 1
fi

# Create the Wine prefix
echo "Creating Wine prefix directory at $WINEPREFIX"
wineboot --init
wineserver -w

# Install .NET 4.8 first
echo "Installing .NET 4.8..."
winetricks -q dotnet48
wineserver -w

# dotnet48 downgrades the prefix to Windows 7. Change it back to Windows 10.
echo "Setting Windows version to Windows 10..."
winetricks -q win10
wineserver -w

# Install dependencies for HW Acceleration and UI fixes
# - dxvk: Translates DirectX to Vulkan (Fixes WPF black UI while keeping HW acceleration)
# - oleacc: Microsoft Active Accessibility (Fixes the {618736e0...} error in your log)
# - gdiplus: Native GDI+ rendering (Highly recommended for photography software)
echo "Installing VC++, Fonts, DXVK, OLE Accessibility, and GDI+..."
winetricks -q vcrun2022 corefonts d3dcompiler_47 dxvk oleacc gdiplus
wineserver -w

# Copy the installer:
INSTALLER_SRC="$PWD/FUJIFILM_PixelShiftCombiner1070.exe"
if [ ! -f "$INSTALLER_SRC" ]; then
    echo "Error: FUJIFILM_PixelShiftCombiner1070.exe not found at $INSTALLER_SRC."
    exit 1
fi

INSTALLER_DEST="$WINEPREFIX/drive_c/Installers/FUJIFILM_PixelShiftCombiner1070.exe"
mkdir -p "$(dirname "$INSTALLER_DEST")"
echo "Copying the installer to Wine prefix..."
cp "$INSTALLER_SRC" "$INSTALLER_DEST"

echo "Running the FUJIFILM PixelShiftCombiner installer..."
wine "$INSTALLER_DEST"
wineserver -w

echo "Installation completed. You can run the software with:"
echo "WINEPREFIX=\"$WINEPREFIX\" wine \"$WINEPREFIX/drive_c/Program Files/FUJIFILM Pixel Shift Combiner/PixelShiftCombiner.exe\""
