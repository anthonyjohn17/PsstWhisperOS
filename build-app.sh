#!/bin/bash
# =============================================================================
# RELEASE BUILD SCRIPT
#
# Supports two signing modes:
#   1. Developer ID (for notarized distribution): requires DEVELOPER_ID env var
#   2. Ad-hoc (for local testing): used when DEVELOPER_ID is not set
#
# Usage:
#   # Ad-hoc (local only, no notarization)
#   ./build-app.sh
#
#   # Developer ID signed + notarized
#   DEVELOPER_ID="Developer ID Application: John Anthony (TEAM_ID)" \
#   APPLE_ID="your@email.com" \
#   TEAM_ID="YOUR_TEAM_ID" \
#   APP_PASSWORD="xxxx-xxxx-xxxx-xxxx" \
#   ./build-app.sh
#
# Environment variables for notarization:
#   DEVELOPER_ID  — Full signing identity (from `security find-identity -v`)
#   APPLE_ID      — Apple ID email for notarytool
#   TEAM_ID       — Apple Developer Team ID
#   APP_PASSWORD   — App-specific password (generate at appleid.apple.com)
# =============================================================================
set -e

APP_NAME="PsstWhisperOS"
BUNDLE_NAME="PsstWhisperOS"
BUILD_DIR=".build/release"
APP_DIR="dist/${APP_NAME}.app"
VERSION=$(defaults read "$(pwd)/Sources/PsstWhisperOS/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "1.0.0")
DMG_NAME="PsstWhisperOS-${VERSION}"

echo "=== Building PsstWhisperOS v${VERSION} ==="

# Determine signing mode
if [ -n "$DEVELOPER_ID" ]; then
    SIGN_MODE="developer-id"
    echo "=== Signing mode: Developer ID ==="
    echo "    Identity: ${DEVELOPER_ID}"
else
    SIGN_MODE="adhoc"
    echo "=== Signing mode: Ad-hoc (local only) ==="
    echo "    Set DEVELOPER_ID env var for distribution builds"
fi

echo "=== Building release binary ==="
swift build -c release

echo "=== Creating .app bundle ==="
rm -rf dist
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

# Copy binary
cp "${BUILD_DIR}/${BUNDLE_NAME}" "${APP_DIR}/Contents/MacOS/${BUNDLE_NAME}"

# Copy Info.plist
cp Sources/PsstWhisperOS/Info.plist "${APP_DIR}/Contents/Info.plist"

# Copy Resources (if any compiled resources exist)
if [ -d "${BUILD_DIR}/PsstWhisperOS_PsstWhisperOS.bundle" ]; then
    cp -R "${BUILD_DIR}/PsstWhisperOS_PsstWhisperOS.bundle" "${APP_DIR}/Contents/Resources/"
fi

# Copy Sparkle.framework into Frameworks/
SPARKLE_FW=".build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"
if [ -d "$SPARKLE_FW" ]; then
    mkdir -p "${APP_DIR}/Contents/Frameworks"
    cp -R "$SPARKLE_FW" "${APP_DIR}/Contents/Frameworks/"
fi

# Fix rpath so the binary finds Sparkle.framework in Frameworks/
install_name_tool -add_rpath @executable_path/../Frameworks "${APP_DIR}/Contents/MacOS/${BUNDLE_NAME}" 2>/dev/null || true

# --- Code Signing ---
echo "=== Signing app ==="

if [ "$SIGN_MODE" = "developer-id" ]; then
    # Developer ID signing with hardened runtime (required for notarization)
    codesign --force --options runtime --timestamp \
        --sign "$DEVELOPER_ID" \
        --entitlements Sources/PsstWhisperOS/PsstWhisperOS.entitlements \
        "${APP_DIR}/Contents/MacOS/${BUNDLE_NAME}"

    codesign --force --options runtime --timestamp \
        --sign "$DEVELOPER_ID" \
        --entitlements Sources/PsstWhisperOS/PsstWhisperOS.entitlements \
        "${APP_DIR}"
else
    # Ad-hoc signing (local testing only)
    codesign --force --sign - \
        --entitlements Sources/PsstWhisperOS/PsstWhisperOS.entitlements \
        "${APP_DIR}/Contents/MacOS/${BUNDLE_NAME}"

    codesign --force --sign - \
        --entitlements Sources/PsstWhisperOS/PsstWhisperOS.entitlements \
        "${APP_DIR}"
fi

# Verify
echo "=== Verifying code signature ==="
codesign --verify --verbose=2 "${APP_DIR}" 2>&1 || true
codesign -d --entitlements - "${APP_DIR}/Contents/MacOS/${BUNDLE_NAME}" 2>&1 || true

# --- Create DMG ---
echo "=== Creating DMG ==="
DMG_TEMP="dist/dmg_temp"
mkdir -p "${DMG_TEMP}"
cp -R "${APP_DIR}" "${DMG_TEMP}/"
ln -s /Applications "${DMG_TEMP}/Applications"

hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DMG_TEMP}" \
    -ov -format UDZO \
    "dist/${DMG_NAME}.dmg"

rm -rf "${DMG_TEMP}"

# --- Notarization (Developer ID only) ---
if [ "$SIGN_MODE" = "developer-id" ]; then
    if [ -n "$APPLE_ID" ] && [ -n "$TEAM_ID" ] && [ -n "$APP_PASSWORD" ]; then
        echo "=== Submitting for notarization ==="
        xcrun notarytool submit "dist/${DMG_NAME}.dmg" \
            --apple-id "$APPLE_ID" \
            --team-id "$TEAM_ID" \
            --password "$APP_PASSWORD" \
            --wait

        echo "=== Stapling notarization ticket ==="
        xcrun stapler staple "dist/${DMG_NAME}.dmg"

        echo ""
        echo "=== Notarization complete! ==="
    else
        echo ""
        echo "=== WARNING: Developer ID signed but NOT notarized ==="
        echo "    Missing APPLE_ID, TEAM_ID, or APP_PASSWORD env vars."
        echo "    To notarize manually:"
        echo "    xcrun notarytool submit dist/${DMG_NAME}.dmg \\"
        echo "        --apple-id YOUR_EMAIL --team-id TEAM_ID --password APP_PASSWORD --wait"
        echo "    xcrun stapler staple dist/${DMG_NAME}.dmg"
    fi
fi

echo ""
echo "=== Done! ==="
echo "App:     dist/${APP_NAME}.app"
echo "DMG:     dist/${DMG_NAME}.dmg"
echo "Version: ${VERSION}"
echo ""
if [ "$SIGN_MODE" = "adhoc" ]; then
    echo "Note: Ad-hoc signed — for distribution, rebuild with DEVELOPER_ID set."
fi
echo "Users will need to grant Accessibility + Microphone permissions on first launch."
