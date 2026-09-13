import Foundation

enum LevelCatalog {
    static let desserts: [SnackID] = [.strawberry, .cookie, .pancake, .tea]
    static let teaSet: [SnackID] = [.strawberry, .cookie, .pancake, .tea, .leaf, .mochi]
    static let bentoSet: [SnackID] = [.onigiri, .salmon, .tamago, .shrimp, .cheese, .leaf, .soySauce]
    static let thaiSet: [SnackID] = [.shrimp, .coconut, .lime, .leaf, .tea, .tomato, .ginger]
    static let israeliSet: [SnackID] = [.hummus, .pita, .tomato, .leaf, .lime, .tamago, .avocado, .yogurt, .olive]
    static let italianSet: [SnackID] = [.pasta, .tomato, .cheese, .leaf, .avocado, .lime, .garlic, .mushroom, .olive]
    static let gardenSet: [SnackID] = [.strawberry, .blueberry, .pancake, .avocado, .tomato, .leaf, .mochi]
    static let kitchenSet: [SnackID] = [.cookie, .pancake, .bacon, .cheese, .tamago, .tea]
    static let mexicanSet: [SnackID] = [.tortilla, .beans, .chili, .tomato, .avocado, .lime, .mango, .corn]
    static let indianSet: [SnackID] = [.curry, .naan, .chili, .mango, .coconut, .tomato, .lime, .yogurt, .ginger]

    static func levels(for world: WorldID) -> [LevelDef] {
        switch world {
        case .tea: teaLevels
        case .bento: bentoLevels
        case .thai: thaiLevels
        case .israeli: israeliLevels
        case .italian: italianLevels
        case .garden: gardenLevels
        case .kitchen: kitchenLevels
        case .mexican: mexicanLevels
        case .indian: indianLevels
        }
    }

    static func level(world: WorldID, index: Int) -> LevelDef {
        let list = levels(for: world)
        return list[min(max(0, index), list.count - 1)]
    }

    static func pantry(for world: WorldID) -> [SnackID] {
        var pantry: [SnackID] = []
        for snack in levels(for: world).flatMap(\.pool) where !pantry.contains(snack) {
            pantry.append(snack)
        }
        return pantry
    }

    static func freeLevel(world: WorldID) -> LevelDef {
        make(
            world,
            0,
            "Free kitchen",
            "The full pantry is open. Build any connected recipe and serve when it feels ready.",
            pool: pantry(for: world),
            featured: .colorVariety,
            two: 3_500,
            three: 5_500,
            undos: 4,
            tips: 4
        )
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

    static func introduction(for snack: SnackID) -> LevelDef? {
        for world in WorldID.allCases {
            if let level = levels(for: world).first(where: { $0.pool.contains(snack) }) {
                return level
            }
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
        make(.tea, 4, "Open kitchen", "The full tea pantry is open. Watch the colors.",
             pool: teaSet, featured: .colorVariety, two: 3200, three: 5000, undos: 2, tips: 2),
        make(.tea, 5, "Cookie service", "Tea and cookies keep showing up. Use them.",
             pool: teaSet, featured: .teaPairing, two: 3400, three: 5200, undos: 2, tips: 2,
             weights: [.cookie: 3, .tea: 3, .strawberry: 1]),
        make(.tea, 6, "Berry season", "Strawberries are shy. Make the ones you get count.",
             pool: teaSet, featured: .berryBoost, two: 3300, three: 5100, undos: 2, tips: 2,
             weights: [.strawberry: 1, .cookie: 2, .pancake: 2]),
        make(.tea, 7, "Dessert bar", "A tight sweet pool. Lines are everything.",
             pool: teaSet, featured: .sweetLine, two: 3600, three: 5600, undos: 2, tips: 1),
        make(.tea, 8, "Afternoon set", "Mix drinks, sweets, and a little garnish.",
             pool: teaSet, featured: .teaPairing, two: 3600, three: 5600, undos: 2, tips: 1,
             weights: [.tea: 3, .leaf: 3, .cookie: 2]),
        make(.tea, 9, "Crowded tray", "Every cell still matters. Don’t force one combo.",
             pool: teaSet, featured: .colorVariety, two: 3800, three: 5800, undos: 1, tips: 1),
        make(.tea, 10, "High tea", "The offers get awkward. Plan two turns ahead.",
             pool: teaSet, featured: .sweetLine, two: 4000, three: 6200, undos: 1, tips: 1,
             weights: [.strawberry: 1, .mochi: 3, .leaf: 3]),
        make(.tea, 11, "Last cup", "Build a tray you would actually want to eat.",
             pool: teaSet, featured: .fullTray, two: 4200, three: 6400, undos: 1, tips: 1),
    ]

    private static let bentoLevels: [LevelDef] = [
        make(.bento, 0, "Rice buddy", "Onigiri wants salmon right next door.",
             pool: [.onigiri, .salmon, .tamago], featured: .bentoPair, two: 2400, three: 3800, undos: 3, tips: 3),
        make(.bento, 1, "Packed lunch", "Savory pairs plus a little tea.",
             pool: [.onigiri, .salmon, .tamago, .shrimp, .tea, .cookie], featured: .bentoPair, two: 2600, three: 4000, undos: 2, tips: 2),
        make(.bento, 2, "Yellow cube", "Cheese is for color. Don’t ignore it.",
             pool: [.onigiri, .salmon, .tamago, .shrimp, .cheese, .leaf], featured: .colorVariety, two: 3200, three: 5000, undos: 2, tips: 2,
             weights: [.cheese: 3, .onigiri: 3, .salmon: 3]),
        make(.bento, 3, "Umami bottle", "Soy sauce beside rice or seafood adds an umami bonus.",
             pool: bentoSet, featured: .umamiDrizzle, two: 3400, three: 5200, undos: 2, tips: 2),
        make(.bento, 4, "Nori side", "Leaves and rice. Keep the garnish honest.",
             pool: bentoSet + [.tea], featured: .garnish, two: 3300, three: 5100, undos: 2, tips: 2,
             weights: [.leaf: 3, .onigiri: 2]),
        make(.bento, 5, "Street stall", "Salmon shows up often. Feed the onigiri.",
             pool: bentoSet, featured: .bentoPair, two: 3600, three: 5400, undos: 2, tips: 1,
             weights: [.salmon: 3, .onigiri: 3, .strawberry: 1]),
        make(.bento, 6, "Picnic mix", "Sweets sneak into the bento. Use a line if it appears.",
             pool: bentoSet + [.strawberry, .cookie, .pancake], featured: .sweetLine, two: 3600, three: 5600, undos: 2, tips: 1),
        make(.bento, 7, "Tight box", "Fewer treats. More placement discipline.",
             pool: bentoSet,
             featured: .bentoPair, two: 3400, three: 5200, undos: 1, tips: 1),
        make(.bento, 8, "Market day", "A noisy pool. Color variety is the quiet win.",
             pool: bentoSet + [.tomato], featured: .colorVariety, two: 3800, three: 5800, undos: 1, tips: 1),
        make(.bento, 9, "Train lunch", "One obvious combo is a trap. Split your attention.",
             pool: bentoSet, featured: .bentoPair, two: 4000, three: 6000, undos: 1, tips: 1,
             weights: [.cheese: 3, .leaf: 3, .salmon: 2]),
        make(.bento, 10, "Festival tray", "Big offers, tight stars.",
             pool: bentoSet, featured: .fullTray, two: 4200, three: 6400, undos: 1, tips: 1),
        make(.bento, 11, "Master bento", "Sixteen placements. Make them all talk to each other.",
             pool: bentoSet, featured: .bentoPair, two: 4400, three: 6800, undos: 1, tips: 1),
    ]

    private static let gardenLevels: [LevelDef] = [
        make(.garden, 0, "Berry patch", "The garden is dessert-heavy. Boost, don’t hoard.",
             pool: gardenSet, featured: .berryBoost, two: 3000, three: 4800, undos: 2, tips: 2,
             weights: [.strawberry: 3, .pancake: 2]),
        make(.garden, 1, "Wisteria tea", "Leaves everywhere. Park them beside tea.",
             pool: gardenSet + [.tea], featured: .garnish, two: 3000, three: 4800, undos: 2, tips: 2,
             weights: [.leaf: 3, .tea: 3]),
        make(.garden, 2, "Picnic cloth", "A sweet line through the flowers.",
             pool: gardenSet + [.cookie], featured: .sweetLine, two: 3400, three: 5400, undos: 2, tips: 1),
        make(.garden, 3, "Sunset tarts", "Full pantry, garden light.",
             pool: gardenSet, featured: .colorVariety, two: 3800, three: 5800, undos: 2, tips: 1),
        make(.garden, 4, "Bee path", "Strawberries are common. Cookies are not.",
             pool: gardenSet + [.cookie], featured: .berryBoost, two: 3600, three: 5600, undos: 1, tips: 1,
             weights: [.strawberry: 3, .cookie: 1, .pancake: 2]),
        make(.garden, 5, "Long table", "You can still force a line if you save a cell.",
             pool: gardenSet + [.cookie], featured: .sweetLine, two: 4000, three: 6200, undos: 1, tips: 1),
        make(.garden, 6, "Lantern hour", "Color first, then the leftover pairs.",
             pool: gardenSet, featured: .colorVariety, two: 4200, three: 6400, undos: 1, tips: 1),
        make(.garden, 7, "Last bloom", "A pretty tray that also scores.",
             pool: gardenSet, featured: .fullTray, two: 4400, three: 6800, undos: 1, tips: 1),
    ]

    private static let thaiLevels: [LevelDef] = [
        make(.thai, 0, "Lime spark", "Lime beside shrimp earns a bright Lime Lift.",
             pool: [.shrimp, .lime, .leaf, .tea], featured: .limeLift, two: 2500, three: 3900, undos: 3, tips: 3),
        make(.thai, 1, "Coconut cart", "Connect coconut and shrimp, then decide whether to serve.",
             pool: [.shrimp, .coconut, .lime, .leaf], featured: .limeLift, two: 2700, three: 4200, undos: 3, tips: 2),
        make(.thai, 2, "Ginger steam", "Ginger beside shrimp or tea adds a fragrant Ginger Zing.",
             pool: thaiSet, featured: .gingerZing, two: 3100, three: 4800, undos: 2, tips: 2,
             weights: [.shrimp: 3, .ginger: 3, .lime: 2]),
        make(.thai, 3, "Night market", "Two small recipes can share ingredients on one tray.",
             pool: thaiSet, featured: .colorVariety, two: 3400, three: 5200, undos: 2, tips: 2),
        make(.thai, 4, "Sweet & sour", "Balance coconut, lime, and the colors around them.",
             pool: thaiSet, featured: .colorVariety, two: 3700, three: 5700, undos: 1, tips: 1),
        make(.thai, 5, "Last lantern", "Serve early for safety or finish the tray for the feast bonus.",
             pool: thaiSet, featured: .fullTray, two: 4100, three: 6300, undos: 1, tips: 1),
    ]

    private static let israeliLevels: [LevelDef] = [
        make(.israeli, 0, "Open table", "Hummus and pita are the first shared plate.",
             pool: [.hummus, .pita, .tomato, .leaf], featured: .mezzePair, two: 2500, three: 3900, undos: 3, tips: 3),
        make(.israeli, 1, "Chopped bright", "Tomato, lime, and herbs make a fresh cluster.",
             pool: [.tomato, .lime, .leaf, .pita], featured: .limeLift, two: 2700, three: 4200, undos: 3, tips: 2),
        make(.israeli, 2, "Cool labneh", "Yogurt cools a spicy or fruity neighbor.",
             pool: [.hummus, .pita, .tomato, .leaf, .lime, .tamago, .avocado, .yogurt], featured: .creamyCool, two: 3100, three: 4800, undos: 2, tips: 2),
        make(.israeli, 3, "Olive mezze", "Olives beside hummus or tomato grow the shared plate.",
             pool: israeliSet, featured: .oliveGarden, two: 3400, three: 5200, undos: 2, tips: 2),
        make(.israeli, 4, "Market lunch", "A varied pantry rewards flexible placement.",
             pool: israeliSet, featured: .mezzePair, two: 3700, three: 5700, undos: 1, tips: 1),
        make(.israeli, 5, "Long table", "Plate a recipe, then stay for the full-table bonus if the layout can take it.",
             pool: israeliSet, featured: .fullTray, two: 4100, three: 6300, undos: 1, tips: 1),
    ]

    private static let italianLevels: [LevelDef] = [
        make(.italian, 0, "Pomodoro", "Pasta beside tomato becomes a finished dish.",
             pool: [.pasta, .tomato, .cheese, .leaf], featured: .pastaPair, two: 2500, three: 3900, undos: 3, tips: 3),
        make(.italian, 1, "Aglio aroma", "Garlic beside pasta starts a simple, powerful plate.",
             pool: [.pasta, .tomato, .cheese, .leaf, .garlic], featured: .garlicAroma, two: 2700, three: 4200, undos: 3, tips: 2),
        make(.italian, 2, "Olive caprese", "Olives add a briny bonus beside tomato or cheese.",
             pool: [.pasta, .tomato, .cheese, .leaf, .garlic, .olive], featured: .oliveGarden, two: 3100, three: 4800, undos: 2, tips: 2),
        make(.italian, 3, "Woodland pasta", "Mushroom, garlic, and pasta make an earthy cluster.",
             pool: italianSet, featured: .garlicAroma, two: 3400, three: 5200, undos: 2, tips: 2),
        make(.italian, 4, "Trattoria rush", "The same tomato can finish two dishes if the cluster stays connected.",
             pool: italianSet, featured: .pastaPair, two: 3700, three: 5700, undos: 1, tips: 1),
        make(.italian, 5, "Family service", "Serve a plate now, or build all sixteen bites for maximum stars.",
             pool: italianSet, featured: .fullTray, two: 4100, three: 6300, undos: 1, tips: 1),
    ]

    private static let kitchenLevels: [LevelDef] = [
        make(.kitchen, 0, "Rainy oven", "Cookies cooling. Tea waiting.",
             pool: kitchenSet, featured: .teaPairing, two: 3000, three: 4800, undos: 2, tips: 2,
             weights: [.cookie: 3, .tea: 3]),
        make(.kitchen, 1, "Copper pans", "A full house of snacks.",
             pool: kitchenSet, featured: .colorVariety, two: 3600, three: 5400, undos: 2, tips: 2),
        make(.kitchen, 2, "Late bake", "Pancakes keep coming. Build a line.",
             pool: kitchenSet + [.strawberry], featured: .sweetLine, two: 3800, three: 5800, undos: 2, tips: 1,
             weights: [.pancake: 3, .strawberry: 2, .cookie: 2]),
        make(.kitchen, 3, "Shelf raid", "Savory leftovers join dessert.",
             pool: kitchenSet + [.onigiri, .salmon], featured: .bentoPair, two: 3800, three: 5800, undos: 1, tips: 1),
        make(.kitchen, 4, "Midnight crumb", "Awkward offers. Undo is scarce.",
             pool: kitchenSet + [.leaf], featured: .teaPairing, two: 4000, three: 6200, undos: 1, tips: 1,
             weights: [.cheese: 3, .leaf: 3, .tea: 1]),
        make(.kitchen, 5, "Sunday tray", "Everything is fair. Nothing is free.",
             pool: kitchenSet, featured: .colorVariety, two: 4200, three: 6400, undos: 1, tips: 1),
        make(.kitchen, 6, "Storm snack", "Save a cell. The right tea is coming.",
             pool: kitchenSet + [.leaf], featured: .garnish, two: 4200, three: 6600, undos: 1, tips: 1),
        make(.kitchen, 7, "Lights out", "Last kitchen tray. Make it delicious.",
             pool: kitchenSet, featured: .fullTray, two: 4600, three: 7200, undos: 1, tips: 1),
    ]

    private static let mexicanLevels: [LevelDef] = [
        make(.mexican, 0, "First taco", "Tortilla beside beans makes a strong Taco Base.",
             pool: [.tortilla, .beans, .tomato, .lime], featured: .tacoBase, two: 2600, three: 4100, undos: 3, tips: 3),
        make(.mexican, 1, "Corn cart", "Corn beside tortilla, chili, or lime adds a market crunch.",
             pool: [.tortilla, .beans, .avocado, .lime, .tomato, .corn], featured: .cornCrunch, two: 2800, three: 4400, undos: 3, tips: 2),
        make(.mexican, 2, "Salsa spark", "Chili beside beans or tomato adds a Chili Spark.",
             pool: [.tortilla, .beans, .chili, .tomato, .lime], featured: .chiliSpark, two: 3100, three: 4800, undos: 2, tips: 2,
             weights: [.chili: 3, .tomato: 3, .beans: 2]),
        make(.mexican, 3, "Market rush", "One tortilla can anchor several connected recipes.",
             pool: mexicanSet, featured: .colorVariety, two: 3500, three: 5400, undos: 2, tips: 2),
        make(.mexican, 4, "Mango heat", "Mango cools lime, while chili heats the other side.",
             pool: mexicanSet, featured: .mangoCooler, two: 3800, three: 5900, undos: 1, tips: 1,
             weights: [.mango: 3, .lime: 3, .chili: 2]),
        make(.mexican, 5, "Fiesta table", "Serve a finished plate, or fill all sixteen market bites.",
             pool: mexicanSet, featured: .fullTray, two: 4200, three: 6500, undos: 1, tips: 1),
    ]

    private static let indianLevels: [LevelDef] = [
        make(.indian, 0, "Curry & naan", "Curry beside naan makes the first Spice Pair.",
             pool: [.curry, .naan, .chili, .tomato], featured: .spicePair, two: 2700, three: 4200, undos: 3, tips: 3),
        make(.indian, 1, "Coconut pot", "Coconut softens curry; chili adds another scoring edge.",
             pool: [.curry, .naan, .coconut, .chili, .tomato], featured: .chiliSpark, two: 2900, three: 4500, undos: 3, tips: 2),
        make(.indian, 2, "Mango lassi", "Yogurt beside mango makes a true cooling pair.",
             pool: [.mango, .coconut, .lime, .naan, .curry, .yogurt], featured: .creamyCool, two: 3200, three: 4900, undos: 2, tips: 2),
        make(.indian, 3, "Ginger route", "Ginger warms curry while yogurt cools the other side.",
             pool: indianSet, featured: .gingerZing, two: 3500, three: 5400, undos: 2, tips: 2),
        make(.indian, 4, "Courtyard feast", "Seven pantry colors reward a flexible layout.",
             pool: indianSet, featured: .colorVariety, two: 3900, three: 6000, undos: 1, tips: 1),
        make(.indian, 5, "Last tandoor", "Plate your recipe early, or stay for a complete feast tray.",
             pool: indianSet, featured: .fullTray, two: 4300, three: 6600, undos: 1, tips: 1),
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
