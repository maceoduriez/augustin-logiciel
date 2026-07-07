#!/bin/bash
# Package the freshly built wxgui/fityk binary into a self-contained
# macOS application bundle (dist/Fityk.app) with all non-system dylibs
# bundled inside, so it can be copied to another Mac (same CPU arch).
#
# Prerequisites: the project must already be built (see BUILD_MAC.md), and
#   brew install dylibbundler
#
# Usage:  ./dist/make_app.sh
set -e
cd "$(dirname "$0")/.."          # repo root
ROOT="$PWD"
APP="$ROOT/dist/Fityk +.app"

test -x wxgui/.libs/fityk || { echo "Build first (make). wxgui/.libs/fityk missing."; exit 1; }

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/libs"
cp wxgui/.libs/fityk "$APP/Contents/MacOS/fityk"

# libfityk's recorded install name is /usr/local/lib/... (default prefix);
# repoint it to the in-tree dylib so dylibbundler can find it.
install_name_tool -change /usr/local/lib/libfityk.4.dylib \
    "$ROOT/fityk/.libs/libfityk.4.dylib" "$APP/Contents/MacOS/fityk"

dylibbundler -od -b -x "$APP/Contents/MacOS/fityk" \
    -d "$APP/Contents/libs" -p @executable_path/../libs \
    -s "$ROOT/fityk/.libs"

# icon
ICON=/tmp/fityk.iconset
rm -rf "$ICON"; mkdir -p "$ICON"
for s in 16 32 128 256 512; do
  sips -z $s $s fityk.png --out "$ICON/icon_${s}x${s}.png" >/dev/null 2>&1 || true
  d=$((s*2)); sips -z $d $d fityk.png --out "$ICON/icon_${s}x${s}@2x.png" >/dev/null 2>&1 || true
done
iconutil -c icns "$ICON" -o "$APP/Contents/Resources/fityk.icns" 2>/dev/null || true

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Fityk +</string>
  <key>CFBundleDisplayName</key><string>Fityk +</string>
  <key>CFBundleExecutable</key><string>fityk</string>
  <key>CFBundleIdentifier</key><string>pl.nieto.fityk.custom</string>
  <key>CFBundleVersion</key><string>1.3.2</string>
  <key>CFBundleShortVersionString</key><string>1.3.2</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleIconFile</key><string>fityk.icns</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>NSRequiresAquaSystemAppearance</key><false/>
</dict>
</plist>
PLIST

# ad-hoc code signature (lets Gatekeeper run it after right-click > Open)
codesign --force --deep -s - "$APP" >/dev/null 2>&1 || true

echo "Built $APP"
echo "External (non-system) deps remaining in the executable:"
otool -L "$APP/Contents/MacOS/fityk" | grep -vE "@executable_path|/usr/lib|/System" | tail -n +2 || echo "  (none - fully self-contained)"
