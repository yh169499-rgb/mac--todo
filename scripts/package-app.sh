#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/dist/TodaysTodoApp.app"
PRODUCT="TodaysTodoApp"

cd "$ROOT_DIR"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp ".build/arm64-apple-macosx/release/$PRODUCT" "$APP_DIR/Contents/MacOS/$PRODUCT"
cp "AppResources/Info.plist" "$APP_DIR/Contents/Info.plist"
chmod +x "$APP_DIR/Contents/MacOS/$PRODUCT"

# Ad-hoc signing is enough for local launch and keeps the bundle structure valid.
codesign --force --deep --sign - "$APP_DIR" >/dev/null

echo "Created: $APP_DIR"
