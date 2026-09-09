import Foundation

enum ComboKind: String, Codable, CaseIterable, Sendable, Identifiable {
    case berryBoost
    case teaPairing
    case bentoPair
    case garnish
    case sweetLine
    case colorVariety
    case fullTray

    var id: String { rawValue }

    var title: String {
        switch self {
        case .berryBoost: "Berry Boost"
        case .teaPairing: "Tea Pairing"
        case .bentoPair: "Bento Pair"
        case .garnish: "Fresh Garnish"
        case .sweetLine: "Sweet Line"
        case .colorVariety: "Color Variety"
        case .fullTray: "Full Tray"
        }
    }

    var rule: String {
        switch self {
        case .berryBoost: "A strawberry next to a cookie or pancake adds 40."
        case .teaPairing: "Tea next to a cookie adds 180."
        case .bentoPair: "Onigiri next to salmon adds 160."
        case .garnish: "A leaf next to tea adds 90."
        case .sweetLine: "Strawberry, cookie, and pancake in one row or column adds 600."
        case .colorVariety: "Five colors add 400, six add 800, seven add 1,200."
        case .fullTray: "Filling every cell adds 500."
        }
    }

    var symbol: String {
        switch self {
        case .berryBoost: "leaf.fill"
        case .teaPairing: "cup.and.saucer.fill"
        case .bentoPair: "fork.knife"
        case .garnish: "drop.fill"
        case .sweetLine: "square.grid.3x3.fill"
        case .colorVariety: "swatchpalette.fill"
        case .fullTray: "checkmark.seal.fill"
        }
    }

    var pointsLabel: String {
        switch self {
        case .berryBoost: "+40"
        case .teaPairing: "+180"
        case .bentoPair: "+160"
        case .garnish: "+90"
        case .sweetLine: "+600"
        case .colorVariety: "+400 / +800 / +1,200"
        case .fullTray: "+500"
        }
    }
}

struct ComboHit: Equatable, Sendable, Identifiable {
    var kind: ComboKind
    var points: Int
    var cells: [Cell]

    var id: String { kind.rawValue }
    var title: String { kind.title }
}

struct ScoreBreakdown: Equatable, Sendable {
    var base: Int
    var combos: [ComboHit]

    var comboTotal: Int { combos.reduce(0) { $0 + $1.points } }
    var total: Int { base + comboTotal }

    static let empty = ScoreBreakdown(base: 0, combos: [])
}

struct PlacementPreview: Equatable, Sendable {
    var snack: SnackID
    var cell: Cell
    var baseGain: Int
    var comboGain: Int
    var newCombos: [ComboHit]
    var totalAfter: Int

    var bonus: Int { comboGain }
}

enum ScoreEngine {
    static let berryBoostPoints: Int = 40
    static let teaPairingPoints: Int = 180
    static let bentoPairPoints: Int = 160
    static let garnishPoints: Int = 90
    static let sweetLinePoints: Int = 600
    static let fullTrayPoints: Int = 500

    static func evaluate(_ board: Board) -> ScoreBreakdown {
        let base = board.placed().reduce(0) { $0 + $1.1.baseScore }
        var combos: [ComboHit] = []

        if let berry = berryBoost(on: board) { combos.append(berry) }
        if let tea = teaPairing(on: board) { combos.append(tea) }
        if let bento = bentoPair(on: board) { combos.append(bento) }
        if let garnishHit = garnish(on: board) { combos.append(garnishHit) }
        combos.append(contentsOf: sweetLines(on: board))
        if let color = colorVariety(on: board) { combos.append(color) }
        if board.isFull {
            combos.append(ComboHit(kind: .fullTray, points: fullTrayPoints, cells: Cell.all))
        }

        return ScoreBreakdown(base: base, combos: combos)
    }

    static func preview(placing snack: SnackID, at cell: Cell, on board: Board) -> PlacementPreview {
        let before = evaluate(board)
        var next = board
        next.place(snack, at: cell)
        let after = evaluate(next)
        let comboGain = after.comboTotal - before.comboTotal
        let newCombos = after.combos.filter { later in
            guard let earlier = before.combos.first(where: { $0.kind == later.kind && $0.kind != .sweetLine }) else {
                return later.points > 0
            }
            return later.points > earlier.points
        }
        return PlacementPreview(
            snack: snack,
            cell: cell,
            baseGain: snack.baseScore,
            comboGain: comboGain,
            newCombos: newCombos,
            totalAfter: after.total
        )
    }

    static func stars(score: Int, level: LevelDef) -> Int {
        if score >= level.starThree { return 3 }
        if score >= level.starTwo { return 2 }
        return 1
    }

    static func bestPlacement(board: Board, offer: [SnackID]) -> (SnackID, Cell, PlacementPreview)? {
        var best: (SnackID, Cell, PlacementPreview)?
        for snack in offer {
            for cell in board.empties {
                let preview = preview(placing: snack, at: cell, on: board)
                if let current = best {
                    if preview.totalAfter > current.2.totalAfter
                        || (preview.totalAfter == current.2.totalAfter && preview.comboGain > current.2.comboGain)
                    {
                        best = (snack, cell, preview)
                    }
                } else {
                    best = (snack, cell, preview)
                }
            }
        }
        return best
    }

    // MARK: - Combos

    private static func berryBoost(on board: Board) -> ComboHit? {
        var points = 0
        var cells = Set<Cell>()
        for (cell, snack) in board.placed() where snack == .strawberry {
            for neighbor in cell.neighbors {
                if let other = board[neighbor], other == .cookie || other == .pancake {
                    points += berryBoostPoints
                    cells.insert(cell)
                    cells.insert(neighbor)
                }
            }
        }
        guard points > 0 else { return nil }
        return ComboHit(kind: .berryBoost, points: points, cells: Array(cells))
    }

    private static func teaPairing(on board: Board) -> ComboHit? {
        pairBonus(on: board, a: .tea, b: .cookie, kind: .teaPairing, pointsEach: teaPairingPoints)
    }

    private static func bentoPair(on board: Board) -> ComboHit? {
        pairBonus(on: board, a: .onigiri, b: .salmon, kind: .bentoPair, pointsEach: bentoPairPoints)
    }

    private static func garnish(on board: Board) -> ComboHit? {
        pairBonus(on: board, a: .leaf, b: .tea, kind: .garnish, pointsEach: garnishPoints)
    }

    private static func pairBonus(
        on board: Board,
        a: SnackID,
        b: SnackID,
        kind: ComboKind,
        pointsEach: Int
    ) -> ComboHit? {
        var points = 0
        var cells = Set<Cell>()
        for cell in Cell.all {
            for neighbor in cell.neighbors where neighbor.index > cell.index {
                guard let first = board[cell], let second = board[neighbor] else { continue }
                if (first == a && second == b) || (first == b && second == a) {
                    points += pointsEach
                    cells.insert(cell)
                    cells.insert(neighbor)
                }
            }
        }
        guard points > 0 else { return nil }
        return ComboHit(kind: kind, points: points, cells: Array(cells))
    }

    private static func sweetLines(on board: Board) -> [ComboHit] {
        var hits: [ComboHit] = []
        var cells = Set<Cell>()
        var count = 0

        for r in 0..<Board.size {
            let line = Cell.row(r)
            if hasSweetTrio(line, on: board) {
                count += 1
                line.forEach { cells.insert($0) }
            }
        }
        for c in 0..<Board.size {
            let line = Cell.column(c)
            if hasSweetTrio(line, on: board) {
                count += 1
                line.forEach { cells.insert($0) }
            }
        }
        if count > 0 {
            hits.append(ComboHit(kind: .sweetLine, points: sweetLinePoints * count, cells: Array(cells)))
        }
        return hits
    }

    private static func hasSweetTrio(_ line: [Cell], on board: Board) -> Bool {
        let desserts = Set(line.compactMap { board[$0] }.filter(\.isDessert))
        return desserts.contains(.strawberry)
            && desserts.contains(.cookie)
            && desserts.contains(.pancake)
    }

    private static func colorVariety(on board: Board) -> ComboHit? {
        let colors = Set(board.placed().map { $0.1.color })
        let points: Int
        switch colors.count {
        case 7...: points = 1200
        case 6: points = 800
        case 5: points = 400
        default: return nil
        }
        return ComboHit(kind: .colorVariety, points: points, cells: board.placed().map(\.0))
    }
}
