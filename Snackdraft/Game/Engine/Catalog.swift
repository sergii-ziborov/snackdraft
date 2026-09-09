import Foundation

enum LevelCatalog {
    static let desserts: [SnackID] = [.strawberry, .cookie, .pancake, .tea]
    static let teaSet: [SnackID] = [.strawberry, .cookie, .pancake, .tea, .leaf]
    static let bentoSet: [SnackID] = [.onigiri, .salmon, .cheese, .leaf, .tea]
    static let full: [SnackID] = SnackID.allCases

    static func levels(for world: WorldID) -> [LevelDef] {
        switch world {
        case .tea: teaLevels
        case .bento: bentoLevels
        case .garden: gardenLevels
        case .kitchen: kitchenLevels
        }
    }

    static func level(world: WorldID, index: Int) -> LevelDef {
        let list = levels(for: world)
        return list[min(max(0, index), list.count - 1)]
    }

    static func next(after context: PlayContext) -> (WorldID, Int)? {
        let list = levels(for: context.world)
        let nextIndex = context.levelIndex + 1
        if nextIndex < list.count {
            return (context.world, nextIndex)
        }
        if let worldIndex = WorldID.allCases.firstIndex(of: context.world),
           worldIndex + 1 < WorldID.allCases.count
        {
            return (WorldID.allCases[worldIndex + 1], 0)
        }
        return nil
    }

    private static let teaLevels: [LevelDef] = [
        make(.tea, 0, "First tray", "Strawberries make nearby cookies and pancakes tastier.",
             pool: desserts, featured: .berryBoost, two: 2200, three: 3400, undos: 3, tips: 3),
        make(.tea, 1, "Steam rising", "Tea next to a cookie is a pairing. Leave space for it.",
             pool: teaSet, featured: .teaPairing, two: 2400, three: 3800, undos: 3, tips: 3),
        make(.tea, 2, "Sweet line", "Strawberry, cookie, and pancake in one row or column.",
             pool: teaSet, featured: .sweetLine, two: 2800, three: 4400, undos: 2, tips: 2),
        make(.tea, 3, "A little green", "A leaf beside tea is a fresh garnish.",
             pool: teaSet, featured: .garnish, two: 2600, three: 4000, undos: 2, tips: 2),
        make(.tea, 4, "Open kitchen", "All eight snacks. Watch the colors.",
             pool: full, featured: .colorVariety, two: 3200, three: 5000, undos: 2, tips: 2),
        make(.tea, 5, "Cookie service", "Tea and cookies keep showing up. Use them.",
             pool: full, featured: .teaPairing, two: 3400, three: 5200, undos: 2, tips: 2,
             weights: [.cookie: 3, .tea: 3, .strawberry: 1]),
        make(.tea, 6, "Berry season", "Strawberries are shy. Make the ones you get count.",
             pool: full, featured: .berryBoost, two: 3300, three: 5100, undos: 2, tips: 2,
             weights: [.strawberry: 1, .cookie: 2, .pancake: 2]),
        make(.tea, 7, "Dessert bar", "A tight sweet pool. Lines are everything.",
             pool: teaSet, featured: .sweetLine, two: 3600, three: 5600, undos: 2, tips: 1),
        make(.tea, 8, "Afternoon set", "Mix drinks, sweets, and a little garnish.",
             pool: full, featured: .teaPairing, two: 3600, three: 5600, undos: 2, tips: 1,
             weights: [.tea: 3, .leaf: 3, .cookie: 2]),
        make(.tea, 9, "Crowded tray", "Every cell still matters. Don’t force one combo.",
             pool: full, featured: .colorVariety, two: 3800, three: 5800, undos: 1, tips: 1),
        make(.tea, 10, "High tea", "The offers get awkward. Plan two turns ahead.",
             pool: full, featured: .sweetLine, two: 4000, three: 6200, undos: 1, tips: 1,
             weights: [.strawberry: 1, .cheese: 3, .leaf: 3]),
        make(.tea, 11, "Last cup", "Build a tray you would actually want to eat.",
             pool: full, featured: .fullTray, two: 4200, three: 6400, undos: 1, tips: 1),
    ]

    private static let bentoLevels: [LevelDef] = [
        make(.bento, 0, "Rice buddy", "Onigiri wants salmon right next door.",
             pool: bentoSet, featured: .bentoPair, two: 2400, three: 3800, undos: 3, tips: 3),
        make(.bento, 1, "Packed lunch", "Savory pairs plus a little tea.",
             pool: bentoSet + [.cookie], featured: .bentoPair, two: 2600, three: 4000, undos: 2, tips: 2),
        make(.bento, 2, "Yellow cube", "Cheese is for color. Don’t ignore it.",
             pool: full, featured: .colorVariety, two: 3200, three: 5000, undos: 2, tips: 2,
             weights: [.cheese: 3, .onigiri: 3, .salmon: 3]),
        make(.bento, 3, "Two kitchens", "Bento pairs and tea pairings can share a tray.",
             pool: full, featured: .teaPairing, two: 3400, three: 5200, undos: 2, tips: 2),
        make(.bento, 4, "Nori side", "Leaves and rice. Keep the garnish honest.",
             pool: full, featured: .garnish, two: 3300, three: 5100, undos: 2, tips: 2,
             weights: [.leaf: 3, .onigiri: 2]),
        make(.bento, 5, "Street stall", "Salmon shows up often. Feed the onigiri.",
             pool: full, featured: .bentoPair, two: 3600, three: 5400, undos: 2, tips: 1,
             weights: [.salmon: 3, .onigiri: 3, .strawberry: 1]),
        make(.bento, 6, "Picnic mix", "Sweets sneak into the bento. Use a line if it appears.",
             pool: full, featured: .sweetLine, two: 3600, three: 5600, undos: 2, tips: 1),
        make(.bento, 7, "Tight box", "Fewer treats. More placement discipline.",
             pool: [.onigiri, .salmon, .cheese, .leaf, .tea, .cookie],
             featured: .bentoPair, two: 3400, three: 5200, undos: 1, tips: 1),
        make(.bento, 8, "Market day", "A noisy pool. Color variety is the quiet win.",
             pool: full, featured: .colorVariety, two: 3800, three: 5800, undos: 1, tips: 1),
        make(.bento, 9, "Train lunch", "One obvious combo is a trap. Split your attention.",
             pool: full, featured: .bentoPair, two: 4000, three: 6000, undos: 1, tips: 1,
             weights: [.cheese: 3, .leaf: 3, .salmon: 2]),
        make(.bento, 10, "Festival tray", "Big offers, tight stars.",
             pool: full, featured: .fullTray, two: 4200, three: 6400, undos: 1, tips: 1),
        make(.bento, 11, "Master bento", "Sixteen placements. Make them all talk to each other.",
             pool: full, featured: .bentoPair, two: 4400, three: 6800, undos: 1, tips: 1),
    ]

    private static let gardenLevels: [LevelDef] = [
        make(.garden, 0, "Berry patch", "The garden is dessert-heavy. Boost, don’t hoard.",
             pool: teaSet + [.cheese], featured: .berryBoost, two: 3000, three: 4800, undos: 2, tips: 2,
             weights: [.strawberry: 3, .pancake: 2]),
        make(.garden, 1, "Wisteria tea", "Leaves everywhere. Park them beside tea.",
             pool: teaSet + [.cheese], featured: .garnish, two: 3000, three: 4800, undos: 2, tips: 2,
             weights: [.leaf: 3, .tea: 3]),
        make(.garden, 2, "Picnic cloth", "A sweet line through the flowers.",
             pool: teaSet, featured: .sweetLine, two: 3400, three: 5400, undos: 2, tips: 1),
        make(.garden, 3, "Sunset tarts", "Full pantry, garden light.",
             pool: full, featured: .colorVariety, two: 3800, three: 5800, undos: 2, tips: 1),
        make(.garden, 4, "Bee path", "Strawberries are common. Cookies are not.",
             pool: full, featured: .berryBoost, two: 3600, three: 5600, undos: 1, tips: 1,
             weights: [.strawberry: 3, .cookie: 1, .pancake: 2]),
        make(.garden, 5, "Long table", "You can still force a line if you save a cell.",
             pool: full, featured: .sweetLine, two: 4000, three: 6200, undos: 1, tips: 1),
        make(.garden, 6, "Lantern hour", "Color first, then the leftover pairs.",
             pool: full, featured: .colorVariety, two: 4200, three: 6400, undos: 1, tips: 1),
        make(.garden, 7, "Last bloom", "A pretty tray that also scores.",
             pool: full, featured: .fullTray, two: 4400, three: 6800, undos: 1, tips: 1),
    ]

    private static let kitchenLevels: [LevelDef] = [
        make(.kitchen, 0, "Rainy oven", "Cookies cooling. Tea waiting.",
             pool: teaSet + [.cookie], featured: .teaPairing, two: 3000, three: 4800, undos: 2, tips: 2,
             weights: [.cookie: 3, .tea: 3]),
        make(.kitchen, 1, "Copper pans", "A full house of snacks.",
             pool: full, featured: .colorVariety, two: 3600, three: 5400, undos: 2, tips: 2),
        make(.kitchen, 2, "Late bake", "Pancakes keep coming. Build a line.",
             pool: full, featured: .sweetLine, two: 3800, three: 5800, undos: 2, tips: 1,
             weights: [.pancake: 3, .strawberry: 2, .cookie: 2]),
        make(.kitchen, 3, "Shelf raid", "Savory leftovers join dessert.",
             pool: full, featured: .bentoPair, two: 3800, three: 5800, undos: 1, tips: 1),
        make(.kitchen, 4, "Midnight crumb", "Awkward offers. Undo is scarce.",
             pool: full, featured: .teaPairing, two: 4000, three: 6200, undos: 1, tips: 1,
             weights: [.cheese: 3, .leaf: 3, .tea: 1]),
        make(.kitchen, 5, "Sunday tray", "Everything is fair. Nothing is free.",
             pool: full, featured: .colorVariety, two: 4200, three: 6400, undos: 1, tips: 1),
        make(.kitchen, 6, "Storm snack", "Save a cell. The right tea is coming.",
             pool: full, featured: .garnish, two: 4200, three: 6600, undos: 1, tips: 1),
        make(.kitchen, 7, "Lights out", "Last kitchen tray. Make it delicious.",
             pool: full, featured: .fullTray, two: 4600, three: 7200, undos: 1, tips: 1),
    ]

    private static func make(
        _ world: WorldID,
        _ index: Int,
        _ title: String,
        _ prompt: String,
        pool: [SnackID],
        featured: ComboKind,
        two: Int,
        three: Int,
        undos: Int,
        tips: Int,
        weights: [SnackID: Int] = [:]
    ) -> LevelDef {
        var uniquePool: [SnackID] = []
        for snack in pool where !uniquePool.contains(snack) {
            uniquePool.append(snack)
        }
        return LevelDef(
            world: world,
            index: index,
            title: title,
            prompt: prompt,
            pool: uniquePool,
            weights: weights,
            featured: featured,
            starTwo: two,
            starThree: three,
            undos: undos,
            tips: tips
        )
    }
}
