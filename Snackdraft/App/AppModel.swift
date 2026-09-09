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

@MainActor
@Observable
final class AppModel {
    var screen: Screen = .home
    var progress: ProgressState
    var session: PlaySession?
    var lastOutcome: TrayOutcome?

    private let store: ProgressStore

    init(store: ProgressStore = ProgressStore()) {
        self.store = store
        self.progress = store.load()
    }

    func playTapped() {
        let next = progress.nextPlayable()
        startPlay(world: next.0, index: next.1, daily: false)
    }

    func playDaily() {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 1
        let worlds = WorldID.allCases.filter { progress.isUnlocked($0) }
        let world = worlds[day % max(worlds.count, 1)]
        let levels = LevelCatalog.levels(for: world)
        let index = day % levels.count
        startPlay(world: world, index: index, daily: true, seed: UInt64(day) &* 1_000_003)
    }

    func play(world: WorldID, index: Int) {
        guard progress.isUnlocked(world) else { return }
        startPlay(world: world, index: index, daily: false)
    }

    func retry() {
        guard let session else { return }
        startPlay(
            world: session.context.world,
            index: session.context.levelIndex,
            daily: session.context.isDaily,
            seed: session.context.isDaily ? session.context.seed : nil
        )
    }

    func nextLevel() {
        guard let session else {
            screen = .home
            return
        }
        if let next = LevelCatalog.next(after: session.context), progress.isUnlocked(next.0) {
            startPlay(world: next.0, index: next.1, daily: false)
        } else {
            screen = .worlds
            self.session = nil
        }
    }

    func finishTray() {
        guard let session else { return }
        let breakdown = session.breakdown
        let stars = ScoreEngine.stars(score: breakdown.total, level: session.context.level)
        let snacks = session.board.placed().map(\.1)
        progress.record(level: session.context.level, stars: stars, snacks: snacks)
        store.save(progress)
        lastOutcome = TrayOutcome(
            breakdown: breakdown,
            stars: stars,
            board: session.board,
            world: session.context.world,
            levelIndex: session.context.levelIndex,
            isDaily: session.context.isDaily
        )
        if progress.hapticsEnabled {
            Feedback.success()
        }
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
        session = nil
        lastOutcome = nil
        screen = .home
    }

    var uiTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("ui-testing")
    }

    private func startPlay(world: WorldID, index: Int, daily: Bool, seed: UInt64? = nil) {
        let context = PlayContext(
            world: world,
            levelIndex: index,
            seed: seed ?? UInt64.random(in: 1...UInt64.max),
            isDaily: daily
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

    func select(_ snack: SnackID) {
        guard phase == .picking, offer.contains(snack) else { return }
        if selected == snack {
            selected = nil
        } else {
            selected = snack
        }
        tipCell = nil
    }

    func preview(at cell: Cell) -> PlacementPreview? {
        guard let selected, board[cell] == nil else { return nil }
        return ScoreEngine.preview(placing: selected, at: cell, on: board)
    }

    func place(at cell: Cell) {
        guard phase == .picking, let snack = selected, board[cell] == nil else { return }
        history.append(Snapshot(board: board, offer: offer, turn: turn, undosLeft: undosLeft, tipsLeft: tipsLeft))
        board.place(snack, at: cell)
        selected = nil
        tipCell = nil
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
    }

    func useTip() {
        guard phase == .picking, tipsLeft > 0 else { return }
        guard let best = ScoreEngine.bestPlacement(board: board, offer: offer) else { return }
        selected = best.0
        tipCell = best.1
        tipsLeft -= 1
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
