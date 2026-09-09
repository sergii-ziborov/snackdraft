import Foundation

enum SnackKind: String, Codable, Sendable {
    case dessert
    case drink
    case savory
    case garnish
}

enum SnackColor: String, Codable, CaseIterable, Sendable {
    case red, brown, gold, green, white, orange, yellow
}

enum SnackID: String, Codable, CaseIterable, Identifiable, Sendable {
    case strawberry
    case cookie
    case pancake
    case tea
    case onigiri
    case salmon
    case cheese
    case leaf

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
        case .leaf: "Leaf"
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
        }
    }

    var kind: SnackKind {
        switch self {
        case .strawberry, .cookie, .pancake: .dessert
        case .tea: .drink
        case .onigiri, .salmon, .cheese: .savory
        case .leaf: .garnish
        }
    }

    var color: SnackColor {
        switch self {
        case .strawberry: .red
        case .cookie: .brown
        case .pancake: .gold
        case .tea, .leaf: .green
        case .onigiri: .white
        case .salmon: .orange
        case .cheese: .yellow
        }
    }

    var baseScore: Int {
        switch self {
        case .strawberry: 140
        case .cookie: 120
        case .pancake: 120
        case .tea: 100
        case .onigiri: 110
        case .salmon: 110
        case .cheese: 90
        case .leaf: 70
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
        case .leaf: "A fresh garnish. Tea tastes better beside it."
        }
    }

    var comboHint: String {
        switch self {
        case .strawberry: "Boosts nearby cookies and pancakes."
        case .cookie: "Pairs with adjacent tea."
        case .pancake: "Helps complete a sweet line."
        case .tea: "Bonus next to cookies. Leaf makes it brighter."
        case .onigiri: "Pairs with adjacent salmon."
        case .salmon: "Pairs with adjacent onigiri."
        case .cheese: "Adds a yellow for color variety."
        case .leaf: "Bonus next to tea."
        }
    }

    var isDessert: Bool { kind == .dessert }
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
    case garden
    case kitchen

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tea: "Tea & Treats"
        case .bento: "Bento Journey"
        case .garden: "Sweet Garden"
        case .kitchen: "Cozy Kitchen"
        }
    }

    var subtitle: String {
        switch self {
        case .tea: "Cookies, steam, and a little strategy."
        case .bento: "Rice, salmon, and tidy pairs."
        case .garden: "Berries in the wisteria light."
        case .kitchen: "Rain on the window. Combos on the tray."
        }
    }

    var backgroundAsset: String {
        switch self {
        case .tea: "TeaHouseBackground"
        case .bento: "BentoKitchenBackground"
        case .garden: "SweetGardenBackground"
        case .kitchen: "CozyKitchenBackground"
        }
    }

    var caption: String {
        switch self {
        case .tea: "Good combinations make a happier day"
        case .bento: "Small bites. Big combos."
        case .garden: "A sweet start to something great"
        case .kitchen: "Good food brings good mood"
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

    var level: LevelDef {
        LevelCatalog.level(world: world, index: levelIndex)
    }
}

struct ProgressState: Codable, Equatable, Sendable {
    var starsByLevel: [String: Int]
    var seenSnacks: [SnackID]
    var hapticsEnabled: Bool
    var soundEnabled: Bool

    static let fresh = ProgressState(
        starsByLevel: [:],
        seenSnacks: [],
        hapticsEnabled: true,
        soundEnabled: true
    )

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
        case .bento: clearedCount(in: .tea) >= 6 || totalStars >= 12
        case .garden: totalStars >= 18
        case .kitchen: totalStars >= 30
        }
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

    mutating func record(level: LevelDef, stars: Int, snacks: [SnackID]) {
        let current = starsByLevel[level.id] ?? 0
        starsByLevel[level.id] = max(current, stars)
        for snack in snacks where !seenSnacks.contains(snack) {
            seenSnacks.append(snack)
        }
    }

    func hasSeen(_ snack: SnackID) -> Bool {
        seenSnacks.contains(snack)
    }
}

struct TrayOutcome: Equatable, Sendable {
    var breakdown: ScoreBreakdown
    var stars: Int
    var board: Board
    var world: WorldID
    var levelIndex: Int
    var isDaily: Bool
}
