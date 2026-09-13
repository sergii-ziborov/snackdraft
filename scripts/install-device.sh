#!/bin/sh
set -euo pipefail
# Build and install onto a paired physical iPhone.
cd "$(dirname "$0")/.."
APP="DerivedDataDevice/Build/Products/Debug-iphoneos/Snackdraft.app"
DEVICE="${1:?Usage: SNACKDRAFT_TEAM_ID=<team-id> scripts/install-device.sh <device-udid>}"
TEAM="${SNACKDRAFT_TEAM_ID:?Set SNACKDRAFT_TEAM_ID to your Apple Developer Team ID}"

xcodebuild -project Snackdraft.xcodeproj \
  -scheme Snackdraft \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath DerivedDataDevice \
  -allowProvisioningUpdates \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM="$TEAM" \
  build

xcrun devicectl device install app --timeout 180 --device "$DEVICE" "$APP"
xcrun devicectl device process launch --device "$DEVICE" com.sergiiziborov.snackdraft
