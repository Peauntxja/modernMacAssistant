#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/build/现代 Mac 工具箱.app"
BIN="$ROOT/build/ModernMacAssistant"

cd "$ROOT"
rm -rf "$ROOT/build"
mkdir -p "$ROOT/build"

xcrun swiftc \
  -parse-as-library \
  -O \
  -target arm64-apple-macosx14.0 \
  -framework SwiftUI \
  -framework AppKit \
  -framework Foundation \
  Sources/ModernMacAssistant/*.swift \
  -o "$BIN"

mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/ModernMacAssistant"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
cp "$ROOT/Resources/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"

/usr/bin/codesign --force --deep --sign - "$APP"
echo "$APP"
