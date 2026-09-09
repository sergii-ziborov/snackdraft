# Snackdraft

**Build a delicious combo.**

Each turn you pick one of three snacks and place it on a 4×4 tray. Sixteen placements later the tray scores. Combos light up before you commit — a strawberry next to a cookie is visibly better than a strawberry in the corner.

[![Platform](https://img.shields.io/badge/platform-iPhone%20%C2%B7%20iPad%20%C2%B7%20iOS%2018%2B-000000)](#app-target)
[![Language](https://img.shields.io/badge/Swift-6-F05138)](#build-and-run)
[![UI](https://img.shields.io/badge/UI-SwiftUI-0A84FF)](#build-and-run)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Play

A round is one tray:

1. Three snacks appear.
2. Choose one.
3. Empty cells that would form a combo show the bonus.
4. Place it.
5. Repeat until the tray is full.

Then the combos highlight one by one and the score lands.

There is no restaurant, no staff, no cooking timer. You are building a lunch.

## Combos

Eight snacks, seven readable rules:

| Combo | What it is |
| --- | --- |
| **Berry Boost** | Strawberry next to a cookie or pancake: **+40** |
| **Tea Pairing** | Tea next to a cookie: **+180** |
| **Bento Pair** | Onigiri next to salmon: **+160** |
| **Fresh Garnish** | Leaf next to tea: **+90** |
| **Sweet Line** | Strawberry, cookie, and pancake in one row or column: **+600** |
| **Color Variety** | 5 / 6 / 7 distinct colors: **+400 / +800 / +1,200** |
| **Full Tray** | Every cell filled: **+500** |

Adjacency is orthogonal — no diagonals, no hidden multipliers. The number on a cell is the number you will get.

The first party is just a pretty snack. A few turns later you start saving a hole for the tea that will finish two pairings at once.

## Worlds

1. **Tea & Treats** — steam, cookies, dessert lines
2. **Bento Journey** — rice buddies and salmon (unlocks after six tea trays or 12 stars)
3. **Sweet Garden** — 18 stars
4. **Cozy Kitchen** — 30 stars

A daily tray uses the day’s date as a seed so everyone shares the same puzzle.

## App target

- iPhone and iPad (universal)
- iOS 18+
- Portrait on iPhone; portrait and landscape on iPad
- No account, no tracking, no network

Bundle ID: `com.sergiiziborov.snackdraft`

## Build and run

```bash
brew install xcodegen   # if needed
cd snackdraft
xcodegen generate
open Snackdraft.xcodeproj
```

Select an iPhone or iPad simulator, then Run.

Unit tests cover scoring, draft uniqueness, and a greedy bot that can still reach two stars on the opening trays:

```bash
xcodebuild test \
  -scheme Snackdraft \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>'
```

## Project layout

```
Snackdraft/
  App/              # scene, navigation, play session
  Game/Engine/      # snacks, board, scoring, draft, levels
  Game/Food/        # tray and snack art
  Features/         # home, play, result, worlds, collection, settings
  Persistence/      # local stars and collection
  DesignSystem/     # color, type, buttons
  Resources/        # asset catalog, privacy manifest
```

## Why this shape

The player builds their own result. A second tray is different because the combinations were different, not because the wallpaper changed. The set is small on purpose: eight snacks, one board, bonuses you can see.

## License

MIT. See [LICENSE](LICENSE). Privacy notes live in [PRIVACY.md](PRIVACY.md).
