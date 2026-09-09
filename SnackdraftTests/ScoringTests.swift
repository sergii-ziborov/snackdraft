import Foundation
import Testing
@testable import Snackdraft

struct ScoringTests {
    @Test("Empty board scores nothing")
    func emptyBoard() {
        let score = ScoreEngine.evaluate(Board())
        #expect(score.base == 0)
        #expect(score.combos.isEmpty)
        #expect(score.total == 0)
    }

    @Test("Base score sums the snacks")
    func baseScore() {
        var board = Board()
        board.place(.strawberry, at: Cell(row: 0, col: 0))
        board.place(.cheese, at: Cell(row: 3, col: 3))
        let score = ScoreEngine.evaluate(board)
        #expect(score.base == SnackID.strawberry.baseScore + SnackID.cheese.baseScore)
        #expect(score.combos.isEmpty)
    }

    @Test("Strawberry boosts adjacent cookie, not diagonal, not another strawberry")
    func berryBoostNeighbors() {
        var board = Board()
        board.place(.strawberry, at: Cell(row: 1, col: 1))
        board.place(.cookie, at: Cell(row: 1, col: 2))
        board.place(.pancake, at: Cell(row: 3, col: 3))
        board.place(.strawberry, at: Cell(row: 1, col: 0))

        let score = ScoreEngine.evaluate(board)
        let berry = score.combos.first { $0.kind == .berryBoost }
        #expect(berry?.points == ScoreEngine.berryBoostPoints)
        #expect(berry?.cells.contains(Cell(row: 1, col: 1)) == true)
        #expect(berry?.cells.contains(Cell(row: 1, col: 2)) == true)
        #expect(berry?.cells.contains(Cell(row: 3, col: 3)) == false)
    }

    @Test("Tea pairing is counted once per orthogonal pair")
    func teaPairOnce() {
        var board = Board()
        board.place(.tea, at: Cell(row: 0, col: 0))
        board.place(.cookie, at: Cell(row: 0, col: 1))
        board.place(.cookie, at: Cell(row: 1, col: 0))
        let score = ScoreEngine.evaluate(board)
        let tea = score.combos.first { $0.kind == .teaPairing }
        #expect(tea?.points == ScoreEngine.teaPairingPoints * 2)
    }

    @Test("Bento pair needs onigiri beside salmon")
    func bentoPair() {
        var board = Board()
        board.place(.onigiri, at: Cell(row: 2, col: 2))
        board.place(.salmon, at: Cell(row: 2, col: 3))
        board.place(.cheese, at: Cell(row: 3, col: 2))
        let score = ScoreEngine.evaluate(board)
        #expect(score.combos.contains { $0.kind == .bentoPair && $0.points == ScoreEngine.bentoPairPoints })
        #expect(!score.combos.contains { $0.kind == .berryBoost })
    }

    @Test("Leaf next to tea is garnish")
    func garnish() {
        var board = Board()
        board.place(.leaf, at: Cell(row: 0, col: 1))
        board.place(.tea, at: Cell(row: 0, col: 2))
        let score = ScoreEngine.evaluate(board)
        #expect(score.combos.contains { $0.kind == .garnish && $0.points == ScoreEngine.garnishPoints })
    }

    @Test("Sweet line needs all three desserts in the same row")
    func sweetLine() {
        var almost = Board()
        almost.place(.strawberry, at: Cell(row: 0, col: 0))
        almost.place(.cookie, at: Cell(row: 0, col: 1))
        almost.place(.tea, at: Cell(row: 0, col: 2))
        almost.place(.pancake, at: Cell(row: 1, col: 0))
        #expect(!ScoreEngine.evaluate(almost).combos.contains { $0.kind == .sweetLine })

        var full = almost
        full.place(.pancake, at: Cell(row: 0, col: 3))
        let hit = ScoreEngine.evaluate(full).combos.first { $0.kind == .sweetLine }
        #expect(hit?.points == ScoreEngine.sweetLinePoints)
    }

    @Test("Color variety uses distinct colors, and tea shares green with leaf")
    func colors() {
        var board = Board()
        board.place(.strawberry, at: Cell(row: 0, col: 0))
        board.place(.cookie, at: Cell(row: 0, col: 1))
        board.place(.pancake, at: Cell(row: 0, col: 2))
        board.place(.tea, at: Cell(row: 0, col: 3))
        board.place(.onigiri, at: Cell(row: 1, col: 0))
        #expect(ScoreEngine.evaluate(board).combos.contains { $0.kind == .colorVariety && $0.points == 400 })

        board.place(.leaf, at: Cell(row: 1, col: 1))
        #expect(ScoreEngine.evaluate(board).combos.contains { $0.kind == .colorVariety && $0.points == 400 })

        board.place(.salmon, at: Cell(row: 1, col: 2))
        #expect(ScoreEngine.evaluate(board).combos.contains { $0.kind == .colorVariety && $0.points == 800 })
    }

    @Test("Full tray bonus only when every cell is filled")
    func fullTray() {
        var board = Board()
        for cell in Cell.all.dropLast() {
            board.place(.cheese, at: cell)
        }
        #expect(!ScoreEngine.evaluate(board).combos.contains { $0.kind == .fullTray })
        board.place(.cheese, at: Cell.all.last!)
        #expect(ScoreEngine.evaluate(board).combos.contains { $0.kind == .fullTray && $0.points == ScoreEngine.fullTrayPoints })
    }

    @Test("Preview bonus equals the combo delta")
    func previewMatchesDelta() {
        var board = Board()
        board.place(.cookie, at: Cell(row: 0, col: 1))
        let before = ScoreEngine.evaluate(board)
        let preview = ScoreEngine.preview(placing: .tea, at: Cell(row: 0, col: 0), on: board)
        var next = board
        next.place(.tea, at: Cell(row: 0, col: 0))
        let after = ScoreEngine.evaluate(next)
        #expect(preview.baseGain == SnackID.tea.baseScore)
        #expect(preview.comboGain == after.comboTotal - before.comboTotal)
        #expect(preview.totalAfter == after.total)
        #expect(preview.bonus == ScoreEngine.teaPairingPoints)
    }

    @Test("Stars use the level thresholds")
    func starThresholds() {
        let level = LevelCatalog.level(world: .tea, index: 0)
        #expect(ScoreEngine.stars(score: 0, level: level) == 1)
        #expect(ScoreEngine.stars(score: level.starTwo, level: level) == 2)
        #expect(ScoreEngine.stars(score: level.starThree, level: level) == 3)
    }
}

struct DraftTests {
    @Test("Every deal is three unique snacks from the pool")
    func uniqueOffer() {
        let level = LevelCatalog.level(world: .tea, index: 0)
        for turn in 0..<16 {
            for seed: UInt64 in 1...40 {
                let offer = Draft.deal(level: level, seed: seed, turn: turn)
                #expect(offer.count == 3)
                #expect(Set(offer).count == 3)
                #expect(offer.allSatisfy { level.pool.contains($0) })
            }
        }
    }

    @Test("Same seed and turn is deterministic")
    func deterministic() {
        let level = LevelCatalog.level(world: .bento, index: 5)
        let a = Draft.deal(level: level, seed: 42, turn: 7)
        let b = Draft.deal(level: level, seed: 42, turn: 7)
        #expect(a == b)
        let c = Draft.deal(level: level, seed: 43, turn: 7)
        #expect(a != c)
    }
}

struct CatalogTests {
    @Test("Each world has a playable run of levels")
    func counts() {
        #expect(LevelCatalog.levels(for: .tea).count == 12)
        #expect(LevelCatalog.levels(for: .bento).count == 12)
        #expect(LevelCatalog.levels(for: .garden).count == 8)
        #expect(LevelCatalog.levels(for: .kitchen).count == 8)
        for world in WorldID.allCases {
            for (index, level) in LevelCatalog.levels(for: world).enumerated() {
                #expect(level.index == index)
                #expect(level.pool.count >= 3)
                #expect(level.starThree > level.starTwo)
            }
        }
    }

    @Test("A greedy placer can reach two stars on the opening trays")
    func greedyClearsOpeners() {
        let openers = [
            LevelCatalog.level(world: .tea, index: 0),
            LevelCatalog.level(world: .tea, index: 1),
            LevelCatalog.level(world: .bento, index: 0),
        ]
        for level in openers {
            var misses: [UInt64] = []
            for seed: UInt64 in 1...12 {
                let score = greedyScore(level: level, seed: seed &* 997)
                if score < level.starTwo {
                    misses.append(seed)
                }
            }
            #expect(misses.isEmpty, "\(level.id) missed 2 stars on seeds \(misses)")
        }
    }

    private func greedyScore(level: LevelDef, seed: UInt64) -> Int {
        var board = Board()
        var turn = 0
        while !board.isFull {
            let offer = Draft.deal(level: level, seed: seed, turn: turn)
            guard let best = ScoreEngine.bestPlacement(board: board, offer: offer) else { break }
            board.place(best.0, at: best.1)
            turn += 1
        }
        return ScoreEngine.evaluate(board).total
    }
}
