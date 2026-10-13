#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
MODE="${1:-prepare}"
case "$MODE" in prepare|upload) ;; *) echo 'Usage: scripts/testflight.sh [prepare|upload]' >&2; exit 2 ;; esac
: "${ASC_KEY_ID:?Set ASC_KEY_ID for your App Store Connect API key}"
: "${ASC_ISSUER_ID:?Set ASC_ISSUER_ID for your App Store Connect account}"
SNACKDRAFT_KEY_PATH="${ASC_KEY_PATH:-$HOME/.private_keys/AuthKey_${ASC_KEY_ID}.p8}"
SNACKDRAFT_RELEASE_DIR="${SNACKDRAFT_RELEASE_DIR:-DerivedData/TestFlight}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
mkdir -p "$SNACKDRAFT_RELEASE_DIR"
xcodebuild -project Snackdraft.xcodeproj -scheme Snackdraft -configuration Release \
  -destination 'generic/platform=iOS' -archivePath "$SNACKDRAFT_RELEASE_DIR/Snackdraft.xcarchive" \
  -derivedDataPath "$SNACKDRAFT_RELEASE_DIR/Build" -allowProvisioningUpdates \
  -authenticationKeyPath "$SNACKDRAFT_KEY_PATH" -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID" archive
xcodebuild -exportArchive -archivePath "$SNACKDRAFT_RELEASE_DIR/Snackdraft.xcarchive" \
  -exportPath "$SNACKDRAFT_RELEASE_DIR/Export" -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates -authenticationKeyPath "$SNACKDRAFT_KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" -authenticationKeyIssuerID "$ASC_ISSUER_ID"
if [ "$MODE" = upload ]; then
  xcrun altool --upload-app -f "$SNACKDRAFT_RELEASE_DIR/Export/Snackdraft.ipa" \
    --type ios --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
fi
