#!/bin/bash

# 1. EXPORT variables FIRST so all Wine commands use this specific prefix
export WINEPREFIX="$PWD/Wine-Fuji"
export WINEARCH=win64

# Check if Wine/winetricks are installed
if ! command -v wine &> /dev/null || ! command -v winetricks &> /dev/null; then
    echo "Please install wine and winetricks first."
    exit 1
fi

echo "Creating Wine prefix directory at $WINEPREFIX"
wineboot --init
wineserver -w

# Install .NET 4.8
echo "Installing .NET 4.8..."
winetricks -q dotnet48
wineserver -w

# Re-set Windows 10
echo "Setting Windows version to Windows 10..."
winetricks -q win10
wineserver -w

# Install dependencies (Removed DXVK, added d3dx9)
echo "Installing dependencies..."
winetricks -q vcrun2022 corefonts d3dcompiler_47 d3dx9 oleacc gdiplus
wineserver -w

# FIX 1: Manually register the oleacc TypeLib to fix the {618736e0...} crash
echo "Registering OLE Accessibility TypeLib..."
wine regsvr32 oleacc.dll
wineserver -w

# FIX 2: Enable Wine's native Vulkan renderer (Keeps HW acceleration, supports WPF swapchains)
echo "Setting WineD3D to use Vulkan..."
wine reg add "HKCU\Software\Wine\Direct3D" /v renderer /t REG_SZ /d vulkan /f
wineserver -w

# Copy the installer:
INSTALLER_SRC="$PWD/FUJIFILM_PixelShiftCombiner1070.exe"
if [ ! -f "$INSTALLER_SRC" ]; then
    echo "Error: FUJIFILM_PixelShiftCombiner1070.exe not found."
    exit 1
fi

INSTALLER_DEST="$WINEPREFIX/drive_c/Installers/FUJIFILM_PixelShiftCombiner1070.exe"
mkdir -p "$(dirname "$INSTALLER_DEST")"
echo "Copying the installer..."
cp "$INSTALLER_SRC" "$INSTALLER_DEST"

echo "Running the FUJIFILM PixelShiftCombiner installer..."
wine "$INSTALLER_DEST"
wineserver -w

echo "Installation completed. Run the software with:"
echo "WINEPREFIX=\"$WINEPREFIX\" wine \"$WINEPREFIX/drive_c/Program Files/FUJIFILM Pixel Shift Combiner/PixelShiftCombiner.exe\""
