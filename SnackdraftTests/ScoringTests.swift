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

    @Test("New pantry ingredients create cuisine-specific bonuses")
    func worldKitchenBonuses() {
        var board = Board()
        board.place(.soySauce, at: Cell(row: 0, col: 0))
        board.place(.salmon, at: Cell(row: 0, col: 1))
        board.place(.lime, at: Cell(row: 1, col: 2))
        board.place(.shrimp, at: Cell(row: 1, col: 1))
        board.place(.hummus, at: Cell(row: 3, col: 0))
        board.place(.pita, at: Cell(row: 3, col: 1))

        let score = ScoreEngine.evaluate(board)
        #expect(score.combos.contains { $0.kind == .umamiDrizzle && $0.points == ScoreEngine.umamiPoints })
        #expect(score.combos.contains { $0.kind == .limeLift && $0.points == ScoreEngine.limeLiftPoints })
        #expect(score.combos.contains { $0.kind == .mezzePair && $0.points == ScoreEngine.mezzePairPoints })
    }

    @Test("Mercado and spice-house ingredients create their own bonuses")
    func expandedWorldBonuses() {
        var board = Board()
        board.place(.tortilla, at: Cell(row: 0, col: 0))
        board.place(.beans, at: Cell(row: 0, col: 1))
        board.place(.chili, at: Cell(row: 1, col: 1))
        board.place(.curry, at: Cell(row: 2, col: 2))
        board.place(.naan, at: Cell(row: 2, col: 3))
        board.place(.mango, at: Cell(row: 3, col: 0))
        board.place(.lime, at: Cell(row: 3, col: 1))

        let score = ScoreEngine.evaluate(board)
        #expect(score.combos.contains { $0.kind == .tacoBase && $0.points == ScoreEngine.tacoBasePoints })
        #expect(score.combos.contains { $0.kind == .chiliSpark && $0.points == ScoreEngine.chiliSparkPoints })
        #expect(score.combos.contains { $0.kind == .spicePair && $0.points == ScoreEngine.spicePairPoints })
        #expect(score.combos.contains { $0.kind == .mangoCooler && $0.points == ScoreEngine.mangoCoolerPoints })
    }

    @Test("Expanded pantry ingredients create five new flavor bonuses")
    func newestPantryBonuses() {
        var board = Board()
        board.place(.garlic, at: Cell(row: 0, col: 0))
        board.place(.mushroom, at: Cell(row: 0, col: 1))
        board.place(.corn, at: Cell(row: 1, col: 0))
        board.place(.lime, at: Cell(row: 2, col: 0))
        board.place(.yogurt, at: Cell(row: 2, col: 1))
        board.place(.mango, at: Cell(row: 2, col: 2))
        board.place(.olive, at: Cell(row: 3, col: 2))
        board.place(.tomato, at: Cell(row: 3, col: 3))
        board.place(.ginger, at: Cell(row: 1, col: 3))
        board.place(.shrimp, at: Cell(row: 0, col: 3))

        let score = ScoreEngine.evaluate(board)
        #expect(score.combos.contains { $0.kind == .garlicAroma && $0.points == ScoreEngine.garlicAromaPoints })
        #expect(score.combos.contains { $0.kind == .cornCrunch && $0.points == ScoreEngine.cornCrunchPoints })
        #expect(score.combos.contains { $0.kind == .creamyCool && $0.points == ScoreEngine.creamyCoolPoints })
        #expect(score.combos.contains { $0.kind == .oliveGarden && $0.points == ScoreEngine.oliveGardenPoints })
        #expect(score.combos.contains { $0.kind == .gingerZing && $0.points == ScoreEngine.gingerZingPoints })
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
        #expect(SnackID.allCases.count == 33)
        #expect(LevelCatalog.levels(for: .tea).count == 12)
        #expect(LevelCatalog.levels(for: .bento).count == 12)
        #expect(LevelCatalog.levels(for: .thai).count == 6)
        #expect(LevelCatalog.levels(for: .israeli).count == 6)
        #expect(LevelCatalog.levels(for: .italian).count == 6)
        #expect(LevelCatalog.levels(for: .garden).count == 8)
        #expect(LevelCatalog.levels(for: .kitchen).count == 8)
        #expect(LevelCatalog.levels(for: .mexican).count == 6)
        #expect(LevelCatalog.levels(for: .indian).count == 6)
        for world in WorldID.allCases {
            for (index, level) in LevelCatalog.levels(for: world).enumerated() {
                #expect(level.index == index)
                #expect(level.pool.count >= 3)
                #expect(level.starThree > level.starTwo)
            }
        }
    }

    @Test("Free play opens the accumulated pantry without mutating the journey")
    func freePlayPantry() {
        let free = LevelCatalog.freeLevel(world: .italian)
        let pantry = LevelCatalog.pantry(for: .italian)
        #expect(Set(free.pool) == Set(pantry))
        #expect(free.pool.contains(.garlic))
        #expect(free.pool.contains(.mushroom))
        #expect(free.pool.contains(.olive))

        var progress = ProgressState.fresh
        progress.recordFree(snacks: [.garlic, .mushroom], recipes: [])
        #expect(progress.totalStars == 0)
        #expect(progress.hasSeen(.garlic))
        #expect(progress.hasSeen(.mushroom))

        let context = PlayContext(world: .italian, levelIndex: 0, seed: 99, isDaily: false, isFree: true)
        #expect(context.isFree)
        #expect(context.level.title == "Free kitchen")
        #expect(Set(context.level.pool) == Set(pantry))
    }

    @Test("New ingredients arrive on later journey stops")
    func pantryRevealOrder() {
        #expect(!LevelCatalog.level(world: .italian, index: 0).pool.contains(.garlic))
        #expect(LevelCatalog.level(world: .italian, index: 1).pool.contains(.garlic))
        #expect(!LevelCatalog.level(world: .italian, index: 2).pool.contains(.mushroom))
        #expect(LevelCatalog.level(world: .italian, index: 3).pool.contains(.mushroom))
        #expect(!LevelCatalog.level(world: .mexican, index: 0).pool.contains(.corn))
        #expect(LevelCatalog.level(world: .mexican, index: 1).pool.contains(.corn))
    }

    @Test("A greedy placer can reach two stars on the opening trays")
    func greedyClearsOpeners() {
        let openers = [
            LevelCatalog.level(world: .tea, index: 0),
            LevelCatalog.level(world: .tea, index: 1),
            LevelCatalog.level(world: .bento, index: 0),
            LevelCatalog.level(world: .mexican, index: 0),
            LevelCatalog.level(world: .indian, index: 0),
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

struct RecipeTests {
    @Test("Every plated recipe is saved and revealed, not only the first")
    func multipleRecipesReveal() {
        var board = Board()
        board.place(.tea, at: Cell(row: 0, col: 0))
        board.place(.cookie, at: Cell(row: 0, col: 1))
        board.place(.strawberry, at: Cell(row: 0, col: 2))

        let dishes = RecipeBook.matches(board: board, world: .tea)
        #expect(Set(dishes.map(\.id)) == ["afternoon-tea", "ichigo-afternoon"])

        var progress = ProgressState.fresh
        progress.record(level: LevelCatalog.level(world: .tea, index: 0), stars: 1,
                        snacks: [.tea, .cookie, .strawberry], recipes: dishes)
        #expect(dishes.allSatisfy(progress.hasDiscovered))

        var reveal = RecipeRevealSequence(dishes: dishes)
        #expect(reveal.current?.id == dishes[0].id)
        reveal.advance()
        #expect(reveal.current?.id == dishes[1].id)
        reveal.advance()
        #expect(reveal.current == nil)
    }

    @Test("Every recipe is unique and playable in its own kitchen")
    func recipesAreReachable() {
        #expect(RecipeBook.all.count >= 70)
        #expect(Set(RecipeBook.all.map(\.id)).count == RecipeBook.all.count)
        for recipe in RecipeBook.all {
            let reachable = LevelCatalog.levels(for: recipe.world).contains { level in
                recipe.ingredients.allSatisfy(level.pool.contains)
            }
            #expect(reachable, "\(recipe.id) is not offered by any \(recipe.world.rawValue) level")
        }
    }

    @Test("Legacy progress enables ambient music by default")
    func legacyProgressMigration() throws {
        let json = Data(#"{"starsByLevel":{},"seenSnacks":[],"hapticsEnabled":true,"soundEnabled":true,"discoveredRecipes":[]}"#.utf8)
        let progress = try JSONDecoder().decode(ProgressState.self, from: json)
        #expect(progress.musicEnabled)
    }

    @Test("Tea next to a cookie plates Afternoon Tea")
    func afternoonTea() {
        var board = Board()
        board.place(.tea, at: Cell(row: 0, col: 0))
        board.place(.cookie, at: Cell(row: 0, col: 1))
        let dish = RecipeBook.match(board: board, world: .tea)
        #expect(dish?.id == "afternoon-tea")
    }

    @Test("Diagonal ingredients do not count")
    func noDiagonal() {
        var board = Board()
        board.place(.onigiri, at: Cell(row: 0, col: 0))
        board.place(.salmon, at: Cell(row: 1, col: 1))
        #expect(RecipeBook.match(board: board, world: .bento) == nil)
    }

    @Test("Recipe progress counts only side-connected ingredients")
    func connectedRecipeProgress() {
        let recipe = RecipeBook.recipes(for: .tea).first { $0.id == "ichigo-afternoon" }!
        var board = Board()
        board.place(.tea, at: Cell(row: 1, col: 1))
        board.place(.cookie, at: Cell(row: 1, col: 2))
        board.place(.strawberry, at: Cell(row: 2, col: 3))
        #expect(recipe.connectedIngredients(on: board) == Set([.tea, .cookie]))
        #expect(!recipe.matches(board))

        board.place(.strawberry, at: Cell(row: 2, col: 2))
        #expect(recipe.connectedIngredients(on: board) == Set([.tea, .cookie, .strawberry]))
        #expect(recipe.matches(board))
        #expect(Set(RecipeBook.matches(board: board, world: .tea).map(\.id)) == ["afternoon-tea", "ichigo-afternoon"])
    }

    @Test("An unrelated ingredient cannot bridge recipe pieces")
    func unrelatedSnackDoesNotConnectRecipe() {
        let recipe = RecipeBook.recipes(for: .tea).first { $0.id == "afternoon-tea" }!
        var board = Board()
        board.place(.tea, at: Cell(row: 0, col: 0))
        board.place(.pancake, at: Cell(row: 0, col: 1))
        board.place(.cookie, at: Cell(row: 0, col: 2))
        #expect(recipe.connectedIngredients(on: board).count == 1)
        #expect(!recipe.matches(board))
    }

    @Test("World prefers its own dish when several match")
    func prefersTheme() {
        var board = Board()
        board.place(.tea, at: Cell(row: 0, col: 0))
        board.place(.cookie, at: Cell(row: 0, col: 1))
        board.place(.onigiri, at: Cell(row: 2, col: 2))
        board.place(.salmon, at: Cell(row: 2, col: 3))
        #expect(RecipeBook.match(board: board, world: .tea)?.id == "afternoon-tea")
        #expect(RecipeBook.match(board: board, world: .bento)?.id == "shake-onigiri")
    }

    @Test("Recipes never leak across locked cuisines")
    func recipesStayInTheirWorld() {
        var board = Board()
        board.place(.hummus, at: Cell(row: 0, col: 0))
        board.place(.pita, at: Cell(row: 0, col: 1))
        #expect(RecipeBook.match(board: board, world: .tea) == nil)
    }

    @Test("Ingredients and levels reveal progressively")
    func progressivePantry() {
        var progress = ProgressState.fresh
        let teaOne = LevelCatalog.level(world: .tea, index: 0)
        let teaTwo = LevelCatalog.level(world: .tea, index: 1)
        #expect(progress.isLevelUnlocked(teaOne))
        #expect(!progress.isLevelUnlocked(teaTwo))
        #expect(!progress.isAvailable(.mochi))

        progress.record(level: teaOne, stars: 1, snacks: [])
        #expect(progress.isLevelUnlocked(teaTwo))
        #expect(progress.isAvailable(.mochi))
        #expect(!progress.isAvailable(.soySauce))
    }

    @Test("A three-piece cluster beats the two-piece snack")
    func clusterBeatsPair() {
        var board = Board()
        board.place(.onigiri, at: Cell(row: 1, col: 1))
        board.place(.salmon, at: Cell(row: 1, col: 2))
        board.place(.tamago, at: Cell(row: 1, col: 0))
        #expect(RecipeBook.match(board: board, world: .bento)?.id == "makunouchi")
    }

    @Test("World cuisines match their own connected dishes")
    func worldCuisineRecipes() {
        var thai = Board()
        thai.place(.shrimp, at: Cell(row: 0, col: 0))
        thai.place(.lime, at: Cell(row: 0, col: 1))
        thai.place(.leaf, at: Cell(row: 0, col: 2))
        #expect(RecipeBook.match(board: thai, world: .thai)?.id == "tom-yum")

        var israeli = Board()
        israeli.place(.hummus, at: Cell(row: 1, col: 1))
        israeli.place(.pita, at: Cell(row: 1, col: 2))
        #expect(RecipeBook.match(board: israeli, world: .israeli)?.id == "hummus-pita")

        var italian = Board()
        italian.place(.pasta, at: Cell(row: 2, col: 2))
        italian.place(.tomato, at: Cell(row: 2, col: 3))
        #expect(RecipeBook.match(board: italian, world: .italian)?.id == "pasta-pomodoro")

        var mexican = Board()
        mexican.place(.tortilla, at: Cell(row: 0, col: 0))
        mexican.place(.beans, at: Cell(row: 0, col: 1))
        #expect(RecipeBook.match(board: mexican, world: .mexican)?.id == "bean-taco")

        var indian = Board()
        indian.place(.curry, at: Cell(row: 1, col: 0))
        indian.place(.naan, at: Cell(row: 1, col: 1))
        #expect(RecipeBook.match(board: indian, world: .indian)?.id == "curry-naan")
    }

    @Test("A connected recipe makes a tray serveable before it is full")
    @MainActor
    func earlyServe() {
        let context = PlayContext(world: .tea, levelIndex: 0, seed: 7, isDaily: false)
        let session = PlaySession(context: context)
        session.board.place(.tea, at: Cell(row: 0, col: 0))
        session.board.place(.cookie, at: Cell(row: 0, col: 1))
        #expect(session.board.filledCount == 2)
        #expect(session.canServe)
        session.serve()
        #expect(session.phase == .revealing)
    }

    @Test("App model starts a true free-play session")
    @MainActor
    func startsFreePlay() {
        let model = AppModel()
        model.playFree(world: .tea)
        #expect(model.screen == .play)
        #expect(model.session?.context.isFree == true)
        #expect(model.session?.level.title == "Free kitchen")
    }
}
