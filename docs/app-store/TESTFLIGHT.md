# Snackdraft 1.0.0 (2)

Bundle ID: `com.sergiiziborov.snackdraft`
Team: `XMS5ZC28UJ`
SKU for the new App Store Connect record: `snackdraft-ios`
Primary language: English (U.S.)
Platform: iOS (iPhone and iPad)
Feedback email: sergii.ziborov@gmail.com

## Beta description

Pick one bite. Build a delicious little world.

Snackdraft is a cozy food puzzle game. Choose one of three ingredients, place it on a 4×4 tasting tray, and connect ingredients side-to-side to make recipes and delicious combos. Travel through nine kitchens in Journey, relax with Free Play, or try the daily tray.

This beta includes 70 levels, 33 ingredients, 71 recipes, and 10 achievements. No account is required. All gameplay is free, and this beta has no advertisements or paid upgrades.

## What to test

- Home screen readability and navigation on different iPhone and iPad sizes.
- Full-screen backgrounds and reachable controls at the top and bottom of every screen.
- Pick, tap, and drag ingredients; make several recipes on one tray.
- Journey unlocks, Free Play, daily trays, and Cookbook discoveries.
- Sound, music, haptics, and local progress after restarting the app.
- About, Privacy Policy, Terms of Use, and Help & Support in Settings, including scrolling to their ends.

## Beta review notes

Snackdraft is a single-player puzzle game. No sign-in, demo account, server, or special hardware is needed. Select Continue Journey to play; the first game presents a replayable illustrated guide. A recipe uses side-connected ingredients, can bend into an L, and can share ingredients with another recipe. Serving is available when a recipe is complete; filling the tray is optional.

This build includes no advertising SDK and does not offer an in-app purchase. The planned one-time Remove Ads upgrade is gated off until a release actually enables advertising. StoreKit testing files belong only to the test target and are not included in the release app.

The app declares no non-exempt encryption. Apple operates TestFlight diagnostics. The in-app privacy policy describes the local game data and beta feedback.

## Public documents

- Privacy: https://github.com/sergii-ziborov/snackdraft/blob/main/PRIVACY.md
- Terms: https://github.com/sergii-ziborov/snackdraft/blob/main/TERMS.md
- Support: https://github.com/sergii-ziborov/snackdraft/blob/main/SUPPORT.md
- Apple Standard EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

The root documents mirror the app's bundled files in `Snackdraft/Resources/Legal/`. Keep both copies synchronized.

## Build and upload

Preparation status on October 13, 2026: the bundle identifier is registered, a local iOS App Store distribution profile is active, and version 1.0.0 (2) has been archived and exported as a signed IPA. An upload attempt was rejected because the account has no app record for this bundle ID. A signed-in App Store Connect website session is required to create that record before upload and tester distribution.

Create the iOS app record on the App Store Connect website using the registered bundle identifier above. Apple does not expose app-record creation through the public API. Set beta contact information and add a tester group after the uploaded build is processed. External testing may require Beta App Review; do not describe an uploaded build as distributed until the group has access.

Load existing App Store Connect credentials into the environment without committing them, then run:

```sh
scripts/testflight.sh prepare
scripts/testflight.sh upload
```

`prepare` produces a signed archive and App Store IPA under `DerivedData/TestFlight/`. `upload` rebuilds and uploads using Apple's command-line uploader. It does not submit the app to the public App Store or invite testers.

Required environment variables: `ASC_KEY_ID`, `ASC_ISSUER_ID`. Optional: `ASC_KEY_PATH`, `SNACKDRAFT_RELEASE_DIR`, `DEVELOPER_DIR`. The helper uses the stable Xcode installation by default and exports with the local Apple Distribution certificate and the Snackdraft App Store provisioning profile. Use a new build number after every accepted upload.

## Planned monetization

The download and all gameplay remain free. Use a third-party in-app ad network; Apple's former iAd App Network was discontinued. Select the provider and supply its real application/ad-unit identifiers before enabling release advertisements.

Create the product `com.sergiiziborov.snackdraft.removeads` as a **non-consumable** with reference name **Snackdraft Remove Ads**. Proposed U.S. base price: **USD 1.99**. Use App Store localization and `Product.displayPrice` in the purchase UI. Product description: “Remove all Snackdraft advertisements with one purchase.”

The StoreKit implementation verifies transactions, recognizes existing entitlements, supports restoration, handles pending/cancelled purchases, and stops recognizing refunded or revoked purchases. Purchase controls remain disabled in the current ad-free beta. Before enabling monetization, connect the ad gating to `hasRemovedAds`, finish provider consent/privacy configuration, update bundled and public policies and App Store privacy disclosures, and test actual sandbox product availability. Do not sell removal of advertisements that are not present.

## Apple references

- https://developer.apple.com/news/?id=01152016a
- https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/
- https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/
- https://developer.apple.com/app-store/review/guidelines/

## Verification for this beta

The 34 game-rule tests passed. The two beta/document unit tests passed. All eight UI scenarios passed across the initial run and focused reruns: full-tray play, kitchen navigation, recipe collection, Free Play, safe-area controls, the recipe guide, settings, and complete document scrolling. The focused Free Play rerun verifies the corrected card hit area. Signed Release archive and App Store IPA export succeeded; the release bundle contains all four legal/help documents and no StoreKit test configuration.

The optional StoreKit integration run could not finish in the available local testing service. Purchase, restore, and refund behavior still require successful StoreKit/sandbox validation before enabling a monetized release. Purchases and advertisements are disabled in this beta.
