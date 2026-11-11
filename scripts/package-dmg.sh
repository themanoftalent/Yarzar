#!/bin/bash
# Package Yarzar.app into a drag-to-Applications DMG.
# Usage: ./scripts/package-dmg.sh <Yarzar.app> <output.dmg>
set -euo pipefail

APP_PATH="${1:?Usage: package-dmg.sh <Yarzar.app> <output.dmg>}"
OUTPUT_DMG="${2:?Usage: package-dmg.sh <Yarzar.app> <output.dmg>}"

if [ ! -d "$APP_PATH" ]; then
  echo "✗ App not found: $APP_PATH"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="/tmp/lm-dmg-source-$$"
mkdir -p "$SOURCE"
trap 'rm -rf "$SOURCE"' EXIT

ditto "$APP_PATH" "$SOURCE/Yarzar.app"

rm -f "$OUTPUT_DMG"
mkdir -p "$(dirname "$OUTPUT_DMG")"

"$SCRIPT_DIR/create-dmg" \
  --volname "Yarzar" \
  --window-size 600 320 \
  --icon-size 100 \
  --icon "Yarzar.app" 150 160 \
  --hide-extension "Yarzar.app" \
  --app-drop-link 450 160 \
  "$OUTPUT_DMG" \
  "$SOURCE/"

echo "✓ DMG packaged: $OUTPUT_DMG"
