import Foundation

enum SnackKind: String, Codable, Sendable {
    case dessert
    case drink
    case savory
    case garnish
}

enum SnackColor: String, Codable, CaseIterable, Sendable {
    case red, brown, gold, green, white, orange, yellow, purple
}

enum SnackID: String, Codable, CaseIterable, Identifiable, Sendable {
    case strawberry, cookie, pancake, tea, onigiri, salmon, cheese, leaf
    case blueberry, mochi, tamago, shrimp, tomato, avocado, bacon
    case soySauce, lime, coconut, hummus, pita, pasta
    case tortilla, beans, chili, mango, curry, naan
    case garlic, mushroom, corn, yogurt, olive, ginger

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .strawberry: "Strawberry"
        case .cookie: "Cookie"
        case .pancake: "Pancake"
        case .tea: "Tea"
        case .onigiri: "Onigiri"
        case .salmon: "Salmon"
        case .cheese: "Cheese"
        case .leaf: "Shiso"
        case .blueberry: "Blueberry"
        case .mochi: "Mochi"
        case .tamago: "Tamagoyaki"
        case .shrimp: "Shrimp"
        case .tomato: "Tomato"
        case .avocado: "Avocado"
        case .bacon: "Bacon"
        case .soySauce: "Soy Sauce"
        case .lime: "Lime"
        case .coconut: "Coconut"
        case .hummus: "Hummus"
        case .pita: "Pita"
        case .pasta: "Pasta"
        case .tortilla: "Tortilla"
        case .beans: "Black Beans"
        case .chili: "Chili"
        case .mango: "Mango"
        case .curry: "Curry"
        case .naan: "Naan"
        case .garlic: "Garlic"
        case .mushroom: "Mushroom"
        case .corn: "Sweet Corn"
        case .yogurt: "Yogurt"
        case .olive: "Olives"
        case .ginger: "Ginger"
        }
    }

    var assetName: String {
        switch self {
        case .strawberry: "SnackStrawberry"
        case .cookie: "SnackCookie"
        case .pancake: "SnackPancake"
        case .tea: "SnackTea"
        case .onigiri: "SnackOnigiri"
        case .salmon: "SnackSalmon"
        case .cheese: "SnackCheese"
        case .leaf: "SnackLeaf"
        case .blueberry: "SnackBlueberry"
        case .mochi: "SnackMochi"
        case .tamago: "SnackTamago"
        case .shrimp: "SnackShrimp"
        case .tomato: "SnackTomato"
        case .avocado: "SnackAvocado"
        case .bacon: "SnackBacon"
        case .soySauce: "SnackSoySauce"
        case .lime: "SnackLime"
        case .coconut: "SnackCoconut"
        case .hummus: "SnackHummus"
        case .pita: "SnackPita"
        case .pasta: "SnackPasta"
        case .tortilla: "SnackTortilla"
        case .beans: "SnackBeans"
        case .chili: "SnackChili"
        case .mango: "SnackMango"
        case .curry: "SnackCurry"
        case .naan: "SnackNaan"
        case .garlic: "SnackGarlic"
        case .mushroom: "SnackMushroom"
        case .corn: "SnackCorn"
        case .yogurt: "SnackYogurt"
        case .olive: "SnackOlive"
        case .ginger: "SnackGinger"
        }
    }

    var kind: SnackKind {
        switch self {
        case .strawberry, .cookie, .pancake, .blueberry, .mochi, .mango: .dessert
        case .tea, .coconut, .yogurt: .drink
        case .onigiri, .salmon, .cheese, .tamago, .shrimp, .bacon, .hummus, .pita, .pasta, .tortilla, .beans, .curry, .naan, .mushroom, .corn: .savory
        case .leaf, .tomato, .avocado, .soySauce, .lime, .chili, .garlic, .olive, .ginger: .garnish
        }
    }

    var color: SnackColor {
        switch self {
        case .strawberry, .tomato, .chili: .red
        case .cookie, .bacon, .soySauce, .hummus, .beans, .mushroom: .brown
        case .pancake, .tamago, .curry, .ginger: .gold
        case .tea, .leaf, .avocado, .lime: .green
        case .onigiri, .mochi, .coconut, .garlic, .yogurt: .white
        case .salmon, .shrimp, .mango: .orange
        case .cheese, .pita, .pasta, .tortilla, .naan, .corn: .yellow
        case .blueberry, .olive: .purple
        }
    }

    var baseScore: Int {
        switch self {
        case .strawberry: 140
        case .cookie, .pancake, .blueberry, .mochi, .mango: 120
        case .onigiri, .salmon, .tamago, .shrimp, .pasta, .curry, .mushroom: 110
        case .tea, .bacon, .pita, .coconut, .tortilla, .naan: 100
        case .cheese, .avocado, .tomato, .hummus, .beans, .corn, .yogurt: 90
        case .leaf, .soySauce, .lime, .chili, .garlic, .olive, .ginger: 70
        }
    }

    var blurb: String {
        switch self {
        case .strawberry: "A sweet start to something great."
        case .cookie: "Crisp, chocolatey, and tea’s best friend."
        case .pancake: "Fluffy gold. Loves a dessert lineup."
        case .tea: "Steams happily next to cookies."
        case .onigiri: "A little rice buddy looking for salmon."
        case .salmon: "Glossy, savory, and made for a bento pair."
        case .cheese: "A bright cube that helps the tray’s colors sing."
        case .leaf: "Shiso. Tea tastes brighter beside it."
        case .blueberry: "Tiny midnight jewels for a hotcake stack."
        case .mochi: "Chewy, pink, and happiest next to matcha."
        case .tamago: "Sweet rolled omelette. A bento classic."
        case .shrimp: "Coral and crisp. Loves a rice neighbor."
        case .tomato: "A little sun for a garden plate."
        case .avocado: "Creamy green. Wants a tomato friend."
        case .bacon: "Rainy-morning crunch."
        case .soySauce: "A glossy little bottle of deep umami."
        case .lime: "Bright, sharp, and ready to wake up a plate."
        case .coconut: "Soft tropical sweetness in a snowy shell."
        case .hummus: "Creamy chickpeas with an olive-oil swirl."
        case .pita: "Warm pocket bread made for sharing."
        case .pasta: "Golden ribbons waiting for a sauce."
        case .tortilla: "Warm corn rounds ready to fold around a filling."
        case .beans: "Glossy, earthy, and generous enough to anchor a taco."
        case .chili: "A bright red spark that wakes up savory neighbors."
        case .mango: "Golden fruit with a soft tropical sweetness."
        case .curry: "A warm bowl of spice, color, and comfort."
        case .naan: "Blistered flatbread made for scooping every last bit."
        case .garlic: "A tiny aromatic bulb that makes simple food sing."
        case .mushroom: "Earthy, tender, and ready to deepen a warm plate."
        case .corn: "Sunny kernels with a sweet market crunch."
        case .yogurt: "Cool, creamy, and perfect beside something spicy."
        case .olive: "Glossy, briny little bites for a shared table."
        case .ginger: "Golden warmth with a clean, fragrant spark."
        }
    }

    var comboHint: String {
        switch self {
        case .strawberry: "Boosts nearby cookies, pancakes, and blueberries."
        case .cookie: "Pairs with adjacent tea. Completes Afternoon Tea."
        case .pancake: "Helps complete a sweet line and hotcakes."
        case .tea: "Bonus next to cookies. Leaf makes it brighter."
        case .onigiri: "Pairs with salmon, shrimp, or tamagoyaki."
        case .salmon: "Pairs with adjacent onigiri — shake onigiri."
        case .cheese: "Adds a yellow for color variety."
        case .leaf: "Bonus next to tea. Fresh on a garden plate."
        case .blueberry: "A dessert. Loves pancakes."
        case .mochi: "Completes Matcha Daifuku next to tea."
        case .tamago: "Completes Tamagoyaki Bento next to onigiri."
        case .shrimp: "Completes Ebi Bento next to onigiri."
        case .tomato: "Completes Garden Salad next to avocado."
        case .avocado: "Completes Garden Salad next to tomato."
        case .bacon: "Completes a rainy breakfast next to tamagoyaki."
        case .soySauce: "Adds Umami Drizzle beside rice or seafood."
        case .lime: "Adds Lime Lift beside shrimp, tomato, or avocado."
        case .coconut: "Pairs with shrimp or lime in Thai recipes."
        case .hummus: "Makes a Mezze Pair beside warm pita."
        case .pita: "Pairs with hummus; also holds tomato or tamagoyaki."
        case .pasta: "Gets Saucy beside tomato or cheese."
        case .tortilla: "Makes a Taco Base beside beans or avocado."
        case .beans: "Pair with tortilla; chili adds an extra kick."
        case .chili: "Adds Chili Spark beside beans, curry, or tomato."
        case .mango: "Pairs with coconut or lime for a tropical bonus."
        case .curry: "Makes a Spice Pair beside naan; chili turns up the heat."
        case .naan: "Pairs with curry and completes Indian plates."
        case .garlic: "Adds Garlic Aroma beside pasta, mushroom, or curry."
        case .mushroom: "Pairs with garlic or pasta for an earthy bonus."
        case .corn: "Adds Corn Crunch beside tortilla, chili, or lime."
        case .yogurt: "Cools mango, chili, or curry in a Creamy Cool pair."
        case .olive: "Adds Olive Garden beside tomato, cheese, or hummus."
        case .ginger: "Adds Ginger Zing beside shrimp, curry, or tea."
        }
    }

    var isDessert: Bool { kind == .dessert }

    var origin: WorldID {
        switch self {
        case .strawberry, .cookie, .pancake, .tea, .leaf, .mochi: .tea
        case .onigiri, .salmon, .cheese, .tamago, .shrimp, .soySauce: .bento
        case .lime, .coconut, .ginger: .thai
        case .hummus, .pita, .tomato, .avocado, .yogurt: .israeli
        case .pasta, .garlic, .mushroom, .olive: .italian
        case .tortilla, .beans, .chili, .corn: .mexican
        case .mango, .curry, .naan: .indian
        case .blueberry: .garden
        case .bacon: .kitchen
        }
    }
}

struct Cell: Hashable, Codable, Sendable, Identifiable {
    var row: Int
    var col: Int

    var id: String { "\(row)-\(col)" }

    var index: Int { row * Board.size + col }

    var isValid: Bool {
        (0..<Board.size).contains(row) && (0..<Board.size).contains(col)
    }

    var neighbors: [Cell] {
        [Cell(row: row - 1, col: col),
         Cell(row: row + 1, col: col),
         Cell(row: row, col: col - 1),
         Cell(row: row, col: col + 1)]
            .filter(\.isValid)
    }

    static var all: [Cell] {
        (0..<Board.size).flatMap { row in
            (0..<Board.size).map { col in Cell(row: row, col: col) }
        }
    }

    static func row(_ r: Int) -> [Cell] {
        (0..<Board.size).map { Cell(row: r, col: $0) }
    }

    static func column(_ c: Int) -> [Cell] {
        (0..<Board.size).map { Cell(row: $0, col: c) }
    }
}

struct Board: Equatable, Sendable {
    static let size = 4
    static let capacity = size * size

    private var cells: [SnackID?]

    init(cells: [SnackID?] = Array(repeating: nil, count: Board.capacity)) {
        precondition(cells.count == Board.capacity)
        self.cells = cells
    }

    subscript(_ cell: Cell) -> SnackID? {
        get { cells[cell.index] }
        set { cells[cell.index] = newValue }
    }

    var filledCount: Int { cells.reduce(0) { $0 + ($1 == nil ? 0 : 1) } }
    var isFull: Bool { filledCount == Board.capacity }
    var empties: [Cell] { Cell.all.filter { self[$0] == nil } }

    func placed() -> [(Cell, SnackID)] {
        Cell.all.compactMap { cell in
            guard let snack = self[cell] else { return nil }
            return (cell, snack)
        }
    }

    mutating func place(_ snack: SnackID, at cell: Cell) {
        self[cell] = snack
    }
}

enum WorldID: String, Codable, CaseIterable, Identifiable, Sendable {
    case tea
    case bento
    case thai
    case israeli
    case italian
    case garden
    case kitchen
    case mexican
    case indian

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tea: "Tea & Treats"
        case .bento: "Bento Journey"
        case .thai: "Thai Night Market"
        case .israeli: "Israeli Table"
        case .italian: "Italian Trattoria"
        case .garden: "Sweet Garden"
        case .kitchen: "Cozy Kitchen"
        case .mexican: "Mexican Mercado"
        case .indian: "Indian Spice House"
        }
    }

    var subtitle: String {
        switch self {
        case .tea: "Cookies, steam, and a little strategy."
        case .bento: "Rice, salmon, and tidy pairs."
        case .thai: "Coconut, lime, and bright street-food energy."
        case .israeli: "Warm pita, hummus, and a generous table."
        case .italian: "Pasta, tomato, and simple good things."
        case .garden: "Berries in the wisteria light."
        case .kitchen: "Rain on the window. Combos on the tray."
        case .mexican: "Tortillas, beans, chili, and a market at dusk."
        case .indian: "Curry, naan, mango, and a courtyard full of spice."
        }
    }

    var backgroundAsset: String {
        switch self {
        case .tea: "TeaHouseBackground"
        case .bento: "BentoKitchenBackground"
        case .thai: "ThaiKitchenBackground"
        case .israeli: "IsraeliKitchenBackground"
        case .italian: "ItalianKitchenBackground"
        case .garden: "SweetGardenBackground"
        case .kitchen: "CozyKitchenBackground"
        case .mexican: "MexicanKitchenBackground"
        case .indian: "IndianKitchenBackground"
        }
    }

    var caption: String {
        switch self {
        case .tea: "Good combinations make a happier day"
        case .bento: "Small bites. Big combos."
        case .thai: "Sweet, sour, salty, bright"
        case .israeli: "Every plate belongs in the middle"
        case .italian: "A few good ingredients are enough"
        case .garden: "A sweet start to something great"
        case .kitchen: "Good food brings good mood"
        case .mexican: "Fold the bright flavors together"
        case .indian: "Warm spice, generous table"
        }
    }
}

struct LevelDef: Equatable, Sendable, Identifiable {
    var world: WorldID
    var index: Int
    var title: String
    var prompt: String
    var pool: [SnackID]
    var weights: [SnackID: Int]
    var featured: ComboKind
    var starTwo: Int
    var starThree: Int
    var undos: Int
    var tips: Int

    var id: String { "\(world.rawValue)-\(index)" }

    var number: Int { index + 1 }

    func weight(for snack: SnackID) -> Int {
        max(1, weights[snack] ?? 2)
    }
}

struct PlayContext: Equatable, Sendable {
    var world: WorldID
    var levelIndex: Int
    var seed: UInt64
    var isDaily: Bool
    var isFree: Bool = false

    var level: LevelDef {
        isFree ? LevelCatalog.freeLevel(world: world) : LevelCatalog.level(world: world, index: levelIndex)
    }
}

struct ProgressState: Codable, Equatable, Sendable {
    var starsByLevel: [String: Int]
    var seenSnacks: [SnackID]
    var hapticsEnabled: Bool
    var soundEnabled: Bool
    var musicEnabled: Bool
    var discoveredRecipes: [String]

    static let fresh = ProgressState(
        starsByLevel: [:],
        seenSnacks: [],
        hapticsEnabled: true,
        soundEnabled: true,
        musicEnabled: true,
        discoveredRecipes: []
    )

    enum CodingKeys: String, CodingKey {
        case starsByLevel, seenSnacks, hapticsEnabled, soundEnabled, musicEnabled, discoveredRecipes
    }

    init(starsByLevel: [String: Int], seenSnacks: [SnackID], hapticsEnabled: Bool, soundEnabled: Bool, musicEnabled: Bool = true, discoveredRecipes: [String]) {
        self.starsByLevel = starsByLevel
        self.seenSnacks = seenSnacks
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
        self.musicEnabled = musicEnabled
        self.discoveredRecipes = discoveredRecipes
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        starsByLevel = try c.decodeIfPresent([String: Int].self, forKey: .starsByLevel) ?? [:]
        seenSnacks = try c.decodeIfPresent([SnackID].self, forKey: .seenSnacks) ?? []
        hapticsEnabled = try c.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? true
        soundEnabled = try c.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? true
        musicEnabled = try c.decodeIfPresent(Bool.self, forKey: .musicEnabled) ?? true
        discoveredRecipes = try c.decodeIfPresent([String].self, forKey: .discoveredRecipes) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(starsByLevel, forKey: .starsByLevel)
        try c.encode(seenSnacks, forKey: .seenSnacks)
        try c.encode(hapticsEnabled, forKey: .hapticsEnabled)
        try c.encode(soundEnabled, forKey: .soundEnabled)
        try c.encode(musicEnabled, forKey: .musicEnabled)
        try c.encode(discoveredRecipes, forKey: .discoveredRecipes)
    }

    var totalStars: Int { starsByLevel.values.reduce(0, +) }

    func stars(for level: LevelDef) -> Int {
        starsByLevel[level.id] ?? 0
    }

    func clearedCount(in world: WorldID) -> Int {
        LevelCatalog.levels(for: world).filter { (starsByLevel[$0.id] ?? 0) > 0 }.count
    }

    func isUnlocked(_ world: WorldID) -> Bool {
        switch world {
        case .tea: true
        case .bento: clearedCount(in: .tea) >= 4 || totalStars >= 8
        case .thai: totalStars >= 14
        case .israeli: totalStars >= 22
        case .italian: totalStars >= 30
        case .garden: totalStars >= 38
        case .kitchen: totalStars >= 50
        case .mexican: totalStars >= 62
        case .indian: totalStars >= 74
        }
    }

    func isAvailable(_ snack: SnackID) -> Bool {
        if hasSeen(snack) { return true }
        guard let introduction = LevelCatalog.introduction(for: snack) else { return false }
        return isLevelUnlocked(introduction)
    }

    func isLevelUnlocked(_ level: LevelDef) -> Bool {
        guard isUnlocked(level.world) else { return false }
        guard level.index > 0 else { return true }
        let previous = LevelCatalog.level(world: level.world, index: level.index - 1)
        return stars(for: previous) > 0
    }

    func nextPlayable() -> (WorldID, Int) {
        for world in WorldID.allCases where isUnlocked(world) {
            let levels = LevelCatalog.levels(for: world)
            if let index = levels.firstIndex(where: { (starsByLevel[$0.id] ?? 0) == 0 }) {
                return (world, index)
            }
        }
        if isUnlocked(.tea) {
            return (.tea, 0)
        }
        return (.tea, 0)
    }

    mutating func record(level: LevelDef, stars: Int, snacks: [SnackID], recipes: [DishRecipe] = []) {
        let current = starsByLevel[level.id] ?? 0
        starsByLevel[level.id] = max(current, stars)
        for snack in snacks where !seenSnacks.contains(snack) {
            seenSnacks.append(snack)
        }
        for recipe in recipes where !discoveredRecipes.contains(recipe.id) {
            discoveredRecipes.append(recipe.id)
        }
    }

    mutating func recordFree(snacks: [SnackID], recipes: [DishRecipe] = []) {
        for snack in snacks where !seenSnacks.contains(snack) {
            seenSnacks.append(snack)
        }
        for recipe in recipes where !discoveredRecipes.contains(recipe.id) {
            discoveredRecipes.append(recipe.id)
        }
    }

    func hasSeen(_ snack: SnackID) -> Bool {
        seenSnacks.contains(snack)
    }

    func hasDiscovered(_ recipe: DishRecipe) -> Bool {
        discoveredRecipes.contains(recipe.id)
    }
}

struct TrayOutcome: Equatable, Sendable {
    var breakdown: ScoreBreakdown
    var stars: Int
    var board: Board
    var world: WorldID
    var levelIndex: Int
    var isDaily: Bool
    var isFree: Bool
    var dishes: [DishRecipe]
    var newDishIDs: Set<String>
    var newAchievements: [Achievement]

    var recipeBonus: Int { dishes.reduce(0) { $0 + $1.bonus } }
    var totalScore: Int { breakdown.total + recipeBonus }
}

struct Achievement: Identifiable, Equatable, Sendable {
    var id: String
    var title: String
    var detail: String
    var symbol: String
    var target: Int
    var progress: @Sendable (ProgressState) -> Int

    static func == (lhs: Achievement, rhs: Achievement) -> Bool { lhs.id == rhs.id }
}

enum AchievementBook {
    static let all: [Achievement] = [
        Achievement(id: "first-plate", title: "First Plate", detail: "Discover your first recipe.", symbol: "fork.knife", target: 1) { $0.discoveredRecipes.count },
        Achievement(id: "recipe-hunter", title: "Recipe Hunter", detail: "Discover 8 different recipes.", symbol: "book.closed.fill", target: 8) { $0.discoveredRecipes.count },
        Achievement(id: "full-pantry", title: "Full Pantry", detail: "Use 15 different ingredients.", symbol: "basket.fill", target: 15) { $0.seenSnacks.count },
        Achievement(id: "star-chef", title: "Star Chef", detail: "Earn 30 stars.", symbol: "star.circle.fill", target: 30) { $0.totalStars },
        Achievement(id: "world-table", title: "World Table", detail: "Unlock five kitchens.", symbol: "globe.europe.africa.fill", target: 5) { progress in
            WorldID.allCases.filter(progress.isUnlocked).count
        },
        Achievement(id: "master-menu", title: "Master Menu", detail: "Discover 24 recipes.", symbol: "crown.fill", target: 24) { $0.discoveredRecipes.count },
        Achievement(id: "golden-service", title: "Golden Service", detail: "Earn three stars on 24 levels.", symbol: "medal.fill", target: 24) { progress in
            progress.starsByLevel.values.filter { $0 == 3 }.count
        },
        Achievement(id: "pantry-curator", title: "Pantry Curator", detail: "Use all 33 ingredients.", symbol: "cabinet.fill", target: 33) { $0.seenSnacks.count },
        Achievement(id: "world-chef", title: "World Chef", detail: "Unlock all nine kitchens.", symbol: "globe.americas.fill", target: 9) { progress in
            WorldID.allCases.filter(progress.isUnlocked).count
        },
        Achievement(id: "recipe-legend", title: "Recipe Legend", detail: "Discover 50 different recipes.", symbol: "sparkles.rectangle.stack.fill", target: 50) { $0.discoveredRecipes.count },
    ]

    static func unlocked(in progress: ProgressState) -> [Achievement] {
        all.filter { $0.progress(progress) >= $0.target }
    }
}
