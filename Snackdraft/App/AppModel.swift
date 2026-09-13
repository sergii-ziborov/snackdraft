import Foundation
import SwiftUI

enum Screen: Equatable {
    case home
    case play
    case result
    case worlds
    case collection
    case settings
}

enum WorldBrowseMode: String, CaseIterable, Identifiable {
    case journey = "Journey"
    case free = "Free Play"

    var id: String { rawValue }
}

@MainActor
@Observable
final class AppModel {
    var screen: Screen = .home
    var progress: ProgressState
    var session: PlaySession?
    var lastOutcome: TrayOutcome?
    var worldBrowseMode: WorldBrowseMode = .journey

    private let store: ProgressStore

    init(store: ProgressStore = ProgressStore()) {
        self.store = store
        self.progress = store.load()
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("ui-testing-multiple-recipes") {
            var board = Board()
            board.place(.tea, at: Cell(row: 0, col: 0))
            board.place(.cookie, at: Cell(row: 0, col: 1))
            board.place(.strawberry, at: Cell(row: 0, col: 2))
            let dishes = RecipeBook.matches(board: board, world: .tea)
            progress.recordFree(snacks: [.tea, .cookie, .strawberry], recipes: dishes)
            lastOutcome = TrayOutcome(
                breakdown: ScoreEngine.evaluate(board),
                stars: 2,
                board: board,
                world: .tea,
                levelIndex: 0,
                isDaily: false,
                isFree: false,
                dishes: dishes,
                newDishIDs: Set(dishes.map(\.id)),
                newAchievements: []
            )
            screen = .result
        }
#endif
    }

    func playTapped() {
        let next = progress.nextPlayable()
        startPlay(world: next.0, index: next.1, daily: false)
    }

    func playDaily() {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 1
        let worlds = WorldID.allCases.filter { progress.isUnlocked($0) }
        let world = worlds[day % max(worlds.count, 1)]
        let levels = LevelCatalog.levels(for: world).filter { progress.isLevelUnlocked($0) }
        let level = levels[day % max(levels.count, 1)]
        startPlay(world: world, index: level.index, daily: true, seed: UInt64(day) &* 1_000_003)
    }

    func play(world: WorldID, index: Int) {
        let level = LevelCatalog.level(world: world, index: index)
        guard progress.isLevelUnlocked(level) else { return }
        startPlay(world: world, index: index, daily: false)
    }

    func playFree(world: WorldID) {
        guard progress.isUnlocked(world) else { return }
        startPlay(world: world, index: 0, daily: false, free: true)
    }

    func retry() {
        guard let session else { return }
        startPlay(
            world: session.context.world,
            index: session.context.levelIndex,
            daily: session.context.isDaily,
            free: session.context.isFree,
            seed: session.context.isDaily ? session.context.seed : nil
        )
    }

    func nextLevel() {
        guard let session else {
            screen = .home
            return
        }
        if session.context.isFree {
            worldBrowseMode = .free
            screen = .worlds
            self.session = nil
            return
        }
        if let next = LevelCatalog.next(after: session.context),
           progress.isLevelUnlocked(LevelCatalog.level(world: next.0, index: next.1)) {
            startPlay(world: next.0, index: next.1, daily: false)
        } else {
            screen = .worlds
            self.session = nil
        }
    }

    func finishTray() {
        guard let session else { return }
        let breakdown = session.breakdown
        let dishes = RecipeBook.matches(board: session.board, world: session.context.world)
        let newDishIDs = Set(dishes.filter { !progress.hasDiscovered($0) }.map(\.id))
        let achievementsBefore = Set(AchievementBook.unlocked(in: progress).map(\.id))
        let total = breakdown.total + dishes.reduce(0) { $0 + $1.bonus }
        let stars = ScoreEngine.stars(score: total, level: session.context.level)
        let snacks = session.board.placed().map(\.1)
        if session.context.isFree {
            progress.recordFree(snacks: snacks, recipes: dishes)
        } else {
            progress.record(level: session.context.level, stars: stars, snacks: snacks, recipes: dishes)
        }
        let newAchievements = AchievementBook.unlocked(in: progress).filter { !achievementsBefore.contains($0.id) }
        store.save(progress)
        lastOutcome = TrayOutcome(
            breakdown: breakdown,
            stars: stars,
            board: session.board,
            world: session.context.world,
            levelIndex: session.context.levelIndex,
            isDaily: session.context.isDaily,
            isFree: session.context.isFree,
            dishes: dishes,
            newDishIDs: newDishIDs,
            newAchievements: newAchievements
        )
        if progress.hapticsEnabled {
            Feedback.success()
        }
        GameAudio.shared.stopAmbient()
        GameAudio.shared.play(newAchievements.isEmpty ? .result : .unlock, world: session.context.world, enabled: progress.soundEnabled)
        screen = .result
    }

    func saveProgress() {
        store.save(progress)
    }

    func resetProgress() {
        progress = .fresh
        store.save(progress)
    }

    func goHome() {
        GameAudio.shared.stopAmbient()
        session = nil
        lastOutcome = nil
        screen = .home
    }

    var uiTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("ui-testing")
    }

    private func startPlay(world: WorldID, index: Int, daily: Bool, free: Bool = false, seed: UInt64? = nil) {
        let context = PlayContext(
            world: world,
            levelIndex: index,
            seed: seed ?? UInt64.random(in: 1...UInt64.max),
            isDaily: daily,
            isFree: free
        )
        session = PlaySession(context: context)
        lastOutcome = nil
        screen = .play
    }
}

@MainActor
@Observable
final class PlaySession {
    let context: PlayContext
    var board = Board()
    var offer: [SnackID]
    var selected: SnackID?
    var undosLeft: Int
    var tipsLeft: Int
    var turn: Int = 0
    var phase: Phase = .picking
    var revealIndex: Int = 0
    var tipCell: Cell?
    var hoverCell: Cell?
    var lastPlaced: Cell?

    private var history: [Snapshot] = []

    enum Phase: Equatable {
        case picking
        case revealing
    }

    private struct Snapshot {
        var board: Board
        var offer: [SnackID]
        var turn: Int
        var undosLeft: Int
        var tipsLeft: Int
    }

    init(context: PlayContext) {
        self.context = context
        self.undosLeft = context.level.undos
        self.tipsLeft = context.level.tips
        self.offer = Draft.deal(level: context.level, seed: context.seed, turn: 0)
    }

    var level: LevelDef { context.level }
    var breakdown: ScoreBreakdown { ScoreEngine.evaluate(board) }
    var placementsLeft: Int { Board.capacity - board.filledCount }
    var completedRecipes: [DishRecipe] { RecipeBook.matches(board: board, world: context.world) }
    var suggestedRecipe: DishRecipe? { RecipeBook.suggested(for: level) }
    var canServe: Bool { phase == .picking && !completedRecipes.isEmpty }

    func select(_ snack: SnackID) {
        guard phase == .picking, offer.contains(snack) else { return }
        if selected == snack {
            selected = nil
        } else {
            selected = snack
        }
        tipCell = nil
    }

    func preview(placing snack: SnackID? = nil, at cell: Cell) -> PlacementPreview? {
        guard let piece = snack ?? selected, board[cell] == nil else { return nil }
        return ScoreEngine.preview(placing: piece, at: cell, on: board)
    }

    func place(_ snack: SnackID? = nil, at cell: Cell) {
        guard phase == .picking, board[cell] == nil else { return }
        guard let piece = snack ?? selected else { return }
        if snack != nil && !offer.contains(piece) { return }
        history.append(Snapshot(board: board, offer: offer, turn: turn, undosLeft: undosLeft, tipsLeft: tipsLeft))
        board.place(piece, at: cell)
        lastPlaced = cell
        selected = nil
        tipCell = nil
        hoverCell = nil
        if board.isFull {
            phase = .revealing
            revealIndex = 0
        } else {
            turn += 1
            offer = Draft.deal(level: context.level, seed: context.seed, turn: turn)
        }
    }

    func undo() {
        guard phase == .picking, undosLeft > 0, let snap = history.popLast() else { return }
        board = snap.board
        offer = snap.offer
        turn = snap.turn
        undosLeft -= 1
        tipsLeft = snap.tipsLeft
        selected = nil
        tipCell = nil
        hoverCell = nil
        lastPlaced = nil
    }

    func useTip() {
        guard phase == .picking, tipsLeft > 0 else { return }
        guard let best = ScoreEngine.bestPlacement(board: board, offer: offer) else { return }
        selected = best.0
        tipCell = best.1
        tipsLeft -= 1
    }

    func serve() {
        guard canServe else { return }
        selected = nil
        tipCell = nil
        hoverCell = nil
        phase = .revealing
        revealIndex = 0
    }

    func advanceReveal() -> Bool {
        let combos = breakdown.combos
        if revealIndex + 1 < combos.count {
            revealIndex += 1
            return false
        }
        return true
    }

    var currentReveal: ComboHit? {
        let combos = breakdown.combos
        guard phase == .revealing, revealIndex < combos.count else { return nil }
        return combos[revealIndex]
    }
}
