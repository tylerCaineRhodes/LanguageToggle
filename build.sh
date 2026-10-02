#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

app="build/Language Toggle.app"

swift build -c release
rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
cp .build/release/LanguageToggle "$app/Contents/MacOS/"
cp Info.plist "$app/Contents/"
codesign --force --sign - "$app"

if [[ "${1:-}" == "install" ]]; then
    mkdir -p ~/Applications
    rm -rf ~/Applications/"Language Toggle.app"
    cp -R "$app" ~/Applications/
    echo "Installed to ~/Applications/Language Toggle.app"
else
    echo "Built $app"
fi
