import SwiftUI

struct PlayDrag: Equatable {
    var snack: SnackID
    var point: CGPoint
}

struct PlayView: View {
    @Environment(AppModel.self) private var model
    @AppStorage("didSeeRecipeGuideV1") private var didSeeRecipeGuide = false
    @State private var revealTask: Task<Void, Never>?
    @State private var cellFrames: [Cell: CGRect] = [:]
    @State private var drag: PlayDrag?
    @State private var showRecipeGuide = false

    var body: some View {
        if let session = model.session {
            GeometryReader { geo in
                let short = geo.size.height < 760
                let trayCap = min(geo.size.width - 28, max(180, geo.size.height * 0.46))
                ZStack {
                    ScreenBackground(image: session.context.world.backgroundAsset, dim: 0.28)
                    VStack(spacing: 0) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: short ? 6 : 10) {
                                topBar(session)
                                mission(session, short: short)
                                offerRow(session, short: short)
                                tray(session)
                                    .frame(width: trayCap, height: trayCap)
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 4)
                            .padding(.bottom, 12)
                            .frame(maxWidth: .infinity)
                        }
                        .scrollBounceBehavior(.basedOnSize)

                        if session.phase != .revealing {
                            bottomBar(session, short: short)
                                .padding(.horizontal, 14)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                                .frame(maxWidth: .infinity)
                                .background(Palette.navy.ignoresSafeArea(edges: .bottom))
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)

                    if let drag {
                        SnackArt(snack: drag.snack, popping: true)
                            .frame(width: 76, height: 76)
                            .position(drag.point)
                            .allowsHitTesting(false)
                            .zIndex(20)
                    }

                    if session.phase == .revealing {
                        revealOverlay(session)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .coordinateSpace(name: "play")
                .onPreferenceChange(CellFramesKey.self) { cellFrames = $0 }
            }
            .onAppear {
                startRevealIfNeeded()
                GameAudio.shared.startAmbient(world: session.context.world, enabled: model.progress.musicEnabled)
                if ProcessInfo.processInfo.arguments.contains("ui-testing-onboarding") || (!didSeeRecipeGuide && !model.uiTesting) {
                    showRecipeGuide = true
                }
            }
            .onChange(of: model.session?.phase) { _, phase in
                startRevealIfNeeded()
                if phase == .revealing, model.session?.currentReveal != nil {
                    playSound(.combo, session: session)
                }
            }
            .onChange(of: model.session?.board.filledCount) { _, _ in startRevealIfNeeded() }
            .onChange(of: model.session?.canServe) { wasReady, isReady in
                if wasReady != true, isReady == true {
                    playSound(.recipeReady, session: session)
                }
            }
            .onChange(of: model.session?.revealIndex) { oldIndex, newIndex in
                if let oldIndex, let newIndex, newIndex > oldIndex {
                    playSound(.combo, session: session)
                }
            }
            .onDisappear {
                revealTask?.cancel()
                GameAudio.shared.stopAmbient()
            }
            .sheet(isPresented: $showRecipeGuide, onDismiss: { didSeeRecipeGuide = true }) {
                RecipeGuideView {
                    didSeeRecipeGuide = true
                    showRecipeGuide = false
                }
            }
        } else {
            Color.black.onAppear { model.goHome() }
        }
    }

    private func topBar(_ session: PlaySession) -> some View {
        HStack {
            Button {
                model.goHome()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.black.opacity(0.28), in: Circle())
            }
            .accessibilityIdentifier("back-button")

            Spacer()

            VStack(spacing: 2) {
                Text(session.context.isFree ? "Free play" : (session.context.isDaily ? "Daily tray" : "Level \(session.level.number)"))
                    .font(.sdBody(16))
                    .foregroundStyle(.white)
                    .accessibilityIdentifier("play-mode-label")
                Text(session.context.world.title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            VStack(spacing: 1) {
                Text("\(session.board.filledCount)/16")
                    .font(.sdBody(13))
                Text("bites")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .opacity(0.75)
            }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.black.opacity(0.35), in: Capsule())
        }
        .padding(.top, 4)
    }

    private func mission(_ session: PlaySession, short: Bool) -> some View {
        VStack(spacing: short ? 4 : 6) {
            HStack(spacing: 6) {
                Image(systemName: session.canServe ? "bell.fill" : "hand.draw.fill")
                    .foregroundStyle(session.canServe ? Palette.gold : .white)
                Text(session.canServe
                     ? "\(session.completedRecipes.count) \(session.completedRecipes.count == 1 ? "recipe" : "recipes") ready — serve or add more"
                     : (drag != nil ? "Drop it on an empty cell" : "Pick one bite, then place it"))
                    .font(.sdBody(short ? 13 : 15))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 0)
                Button {
                    showRecipeGuide = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Palette.gold)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("How to make recipes")
                .accessibilityIdentifier("recipe-guide-button")
            }
            Text(session.level.prompt)
                .font(.system(size: short ? 12 : 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            if let recipe = session.suggestedRecipe {
                let connected = recipe.connectedIngredients(on: session.board)
                HStack(spacing: 5) {
                    Text("Try")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                    ForEach(recipe.ingredients) { snack in
                        let placed = connected.contains(snack)
                        SnackArt(snack: snack)
                            .frame(width: short ? 22 : 26, height: short ? 22 : 26)
                            .opacity(placed ? 1 : 0.48)
                            .overlay(alignment: .bottomTrailing) {
                                if placed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(Palette.moss)
                                        .background(Color.white, in: Circle())
                                }
                            }
                    }
                    Text(recipe.name)
                        .font(.sdBody(11))
                        .foregroundStyle(session.completedRecipes.contains(recipe) ? Palette.gold : .white.opacity(0.82))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text("\(connected.count)/\(recipe.required.count) linked")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.gold)
                        .fixedSize()
                }
            }
            Text(session.canServe
                 ? "Serve now, or keep building. Filling 16 cells is optional."
                 : "Recipe pieces touch by sides — any shape, not corners.")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.94))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func offerRow(_ session: PlaySession, short: Bool) -> some View {
        HStack(spacing: 10) {
            ForEach(Array(session.offer.enumerated()), id: \.offset) { index, snack in
                let isOn = session.selected == snack && drag == nil
                let lifting = drag?.snack == snack
                Button {
                    session.select(snack)
                    if model.progress.hapticsEnabled { Feedback.tap() }
                    playSound(.select, session: session)
                } label: {
                    VStack(spacing: 6) {
                        SnackArt(snack: snack, popping: isOn)
                            .frame(width: short ? 58 : 68, height: short ? 58 : 68)
                        Text(snack.displayName)
                            .font(.sdBody(12))
                            .foregroundStyle(Palette.ink)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Palette.cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isOn ? snack.accent : Color.black.opacity(0.08), lineWidth: isOn ? 3 : 1)
                    }
                    .shadow(color: snack.accent.opacity(isOn ? 0.45 : 0.12), radius: isOn ? 10 : 4, y: 3)
                    .opacity(lifting ? 0.35 : 1)
                    .scaleEffect(isOn ? 1.04 : 1)
                }
                .buttonStyle(.plain)
                .disabled(session.phase != .picking)
                .simultaneousGesture(dragGesture(snack, session: session))
                .accessibilityIdentifier("offer-\(index)")
                .accessibilityLabel(snack.displayName)
            }
        }
        .opacity(session.phase == .picking ? 1 : 0.35)
        .animation(.spring(duration: 0.28, bounce: 0.3), value: session.offer)
    }

    private func dragGesture(_ snack: SnackID, session: PlaySession) -> some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .named("play"))
            .onChanged { value in
                guard session.phase == .picking else { return }
                if session.selected != snack { session.select(snack) }
                let hit = hitCell(at: value.location)
                session.hoverCell = (hit != nil && session.board[hit!] == nil) ? hit : nil
                drag = PlayDrag(snack: snack, point: value.location)
            }
            .onEnded { value in
                defer {
                    drag = nil
                    session.hoverCell = nil
                }
                guard session.phase == .picking else { return }
                if let cell = hitCell(at: value.location), session.board[cell] == nil {
                    session.place(snack, at: cell)
                    if model.progress.hapticsEnabled { Feedback.place() }
                    playSound(.place, session: session)
                }
            }
    }

    private func hitCell(at point: CGPoint) -> Cell? {
        cellFrames.first { $0.value.insetBy(dx: -8, dy: -8).contains(point) }?.key
    }

    private func tray(_ session: PlaySession) -> some View {
        TrayGrid(
            board: session.board,
            selected: session.selected,
            tipCell: session.tipCell,
            hoverCell: session.hoverCell,
            lastPlaced: session.lastPlaced,
            highlight: Set(session.currentReveal?.cells ?? []),
            highlightColor: session.currentReveal?.kind.tint ?? Palette.gold,
            interactive: session.phase == .picking,
            previewBonus: { cell in
                session.preview(placing: drag?.snack, at: cell).map(\.bonus)
            },
            onPlace: { cell in
                let before = session.board.filledCount
                session.place(at: cell)
                if session.board.filledCount > before {
                    if model.progress.hapticsEnabled { Feedback.place() }
                    playSound(.place, session: session)
                }
            }
        )
    }

    private func bottomBar(_ session: PlaySession, short: Bool) -> some View {
        VStack(spacing: 7) {
            if let ready = session.completedRecipes.first {
                Button {
                    session.serve()
                    if model.progress.hapticsEnabled { Feedback.success() }
                    playSound(.serve, session: session)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                        Text(session.completedRecipes.count == 1
                             ? "Serve \(ready.name)"
                             : "Serve \(session.completedRecipes.count) recipes")
                        Spacer()
                        Text("+\(session.completedRecipes.reduce(0) { $0 + $1.bonus }.formatted())")
                    }
                    .font(.sdBody(short ? 14 : 16))
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 18)
                    .padding(.vertical, short ? 10 : 12)
                    .background(Palette.gold, in: Capsule())
                    .shadow(color: Palette.gold.opacity(0.32), radius: 10, y: 4)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("serve-button")
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            HStack(spacing: 12) {
                utilityButton("Undo", icon: "arrow.uturn.backward", count: session.undosLeft) {
                    let before = session.board.filledCount
                    session.undo()
                    if session.board.filledCount < before { playSound(.undo, session: session) }
                }
                .accessibilityIdentifier("undo-button")
                .disabled(session.undosLeft == 0 || session.phase != .picking)

                VStack(spacing: 2) {
                    Text(session.canServe ? "Full tray is optional" : session.level.featured.title)
                        .font(.sdBody(13))
                        .foregroundStyle(session.canServe ? Palette.gold : session.level.featured.tint)
                    Text(session.canServe ? "Keep going for +500" : session.level.featured.pointsLabel)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)

                utilityButton("Tip", icon: "lightbulb.fill", count: session.tipsLeft) {
                    session.useTip()
                    if model.progress.hapticsEnabled { Feedback.tap() }
                    playSound(.tip, session: session)
                }
                .accessibilityIdentifier("tips-button")
                .disabled(session.tipsLeft == 0 || session.phase != .picking)
            }
        }
        .animation(.spring(duration: 0.38, bounce: 0.24), value: session.canServe)
    }

    private func utilityButton(_ title: String, icon: String, count: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                    Text("\(count)")
                        .font(.sdBody(10))
                        .foregroundStyle(Palette.navy)
                        .padding(5)
                        .background(Palette.gold, in: Circle())
                        .offset(x: 6, y: -4)
                }
                Text(title)
                    .font(.sdBody(11))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }

    private func revealOverlay(_ session: PlaySession) -> some View {
        VStack {
            Spacer()
            if let hit = session.currentReveal {
                VStack(spacing: 6) {
                    Text(hit.title)
                        .font(.sdDisplay(26))
                        .foregroundStyle(.white)
                    Text("+\(hit.points.formatted())")
                        .font(.sdBody(20))
                        .foregroundStyle(hit.kind.tint)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(hit.kind.tint.opacity(0.28), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(hit.kind.tint, lineWidth: 2)
                }
                .padding(.bottom, 24)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.35, bounce: 0.28), value: session.revealIndex)
        .allowsHitTesting(false)
    }

    private func startRevealIfNeeded() {
        guard let session = model.session, session.phase == .revealing else { return }
        revealTask?.cancel()
        let fast = model.uiTesting
        revealTask = Task { @MainActor in
            let delay: UInt64 = fast ? 80_000_000 : 650_000_000
            if session.breakdown.combos.isEmpty {
                try? await Task.sleep(nanoseconds: delay)
                model.finishTray()
                return
            }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: delay)
                guard let session = model.session, session.phase == .revealing else { return }
                if session.advanceReveal() {
                    try? await Task.sleep(nanoseconds: delay)
                    model.finishTray()
                    return
                }
            }
        }
    }

    private func playSound(_ cue: SoundCue, session: PlaySession) {
        GameAudio.shared.play(cue, world: session.context.world, enabled: model.progress.soundEnabled)
    }
}

@MainActor
private struct RecipeGuideView: View {
    var close: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @State private var demoStep = 0
    @State private var demoTask: Task<Void, Never>?

    private let snacks: [SnackID] = [.tea, .cookie, .strawberry]
    private let cells = [Cell(row: 1, col: 1), Cell(row: 1, col: 2), Cell(row: 2, col: 2)]

    var body: some View {
        GeometryReader { geo in
            let compact = geo.size.height < 720
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("How to cook")
                            .font(.sdDisplay(26))
                            .foregroundStyle(Palette.ink)
                        Text("A quick visual guide")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Palette.inkSoft)
                    }
                    Spacer()
                    Button(action: close) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.85), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("guide-close-button")
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)
                .padding(.bottom, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: compact ? 10 : 15) {
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { index in
                                Capsule()
                                    .fill(index == page ? Palette.moss : Palette.inkSoft.opacity(0.25))
                                    .frame(width: index == page ? 34 : 14, height: 6)
                            }
                        }
                        .accessibilityLabel("Guide step \(page + 1) of 3")

                        Text(title)
                            .font(.sdDisplay(compact ? 23 : 27))
                            .foregroundStyle(Palette.ink)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("guide-step-title")

                        Text(explanation)
                            .font(.system(size: compact ? 13 : 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Palette.inkSoft)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        demo(compact: compact)

                        if page == 1 {
                            Label("Touching sides ✓     Corners only ✕", systemImage: "square.grid.2x2.fill")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(Palette.moss)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Palette.moss.opacity(0.11), in: Capsule())
                            Text("Only the separate Sweet Line bonus needs a straight row or column.")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Palette.inkSoft)
                                .multilineTextAlignment(.center)
                        }

                        if page == 2 {
                            HStack(spacing: 8) {
                                recipeBadge("Afternoon Tea", ready: demoStep >= 2)
                                recipeBadge("Strawberry Tea Set", ready: demoStep >= 3)
                            }
                            Text("Serve after the first recipe, or keep building. All 16 squares are optional (+500 if filled).")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Palette.inkSoft)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
                .scrollBounceBehavior(.basedOnSize)

                HStack(spacing: 10) {
                    if page > 0 {
                        Button("Back") { page -= 1 }
                            .font(.sdBody(15))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 82, height: 48)
                            .background(.white.opacity(0.85), in: Capsule())
                            .accessibilityIdentifier("guide-back-button")
                    }
                    Button(page == 2 ? "Let's cook" : "Next") {
                        if page == 2 { close() } else { page += 1 }
                    }
                    .font(.sdBody(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Palette.moss, in: Capsule())
                    .accessibilityIdentifier("guide-next-button")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 22)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .background(Palette.cream)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(Palette.cream.ignoresSafeArea())
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear { restartDemo() }
        .onChange(of: page) { _, _ in restartDemo() }
        .onDisappear { demoTask?.cancel() }
    }

    private var title: String {
        switch page {
        case 0: "Pick one, then place it"
        case 1: "Recipes can bend"
        default: "One tray, several recipes"
        }
    }

    private var explanation: String {
        switch page {
        case 0: "Choose one of three offered ingredients. Tap an empty square or drag it there. New choices appear after every placement."
        case 1: "Tea, cookie, and strawberry make an L. Each recipe ingredient touches another by a side; they do not need to form a straight line."
        default: "Tea + cookie makes one recipe. Add a connected strawberry and the same group makes a second recipe too. Both count when you serve."
        }
    }

    private func demo(compact: Bool) -> some View {
        let side: CGFloat = compact ? 184 : 220
        return VStack(spacing: compact ? 6 : 10) {
            HStack(spacing: 8) {
                Text("PICK 1")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.inkSoft)
                ForEach(Array(snacks.enumerated()), id: \.offset) { index, snack in
                    SnackArt(snack: snack)
                        .frame(width: 31, height: 31)
                        .padding(4)
                        .background(Color.white, in: Circle())
                        .overlay {
                            Circle()
                                .stroke(index == demoStep ? Palette.moss : Color.clear, lineWidth: 3)
                        }
                        .scaleEffect(index == demoStep ? 1.12 : 1)
                }
            }
            .animation(.spring(duration: 0.35, bounce: 0.24), value: demoStep)

            TrayGrid(
                board: demoBoard,
                lastPlaced: demoStep > 0 ? cells[demoStep - 1] : nil,
                highlight: page > 0 ? Set(cells.prefix(demoStep)) : [],
                highlightColor: Palette.gold,
                interactive: false,
                compact: true
            )
            .frame(width: side, height: side)
            .accessibilityIdentifier("guide-demo-board")

            HStack(spacing: 8) {
                Spacer(minLength: 0)
                Text(demoCaption)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.moss)
                    .accessibilityIdentifier("guide-demo-caption")
                Spacer(minLength: 0)
                Button {
                    restartDemo()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Palette.moss)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Replay example")
                .accessibilityIdentifier("guide-replay-button")
            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical, compact ? 8 : 12)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var demoBoard: Board {
        var board = Board()
        for index in 0..<demoStep {
            board.place(snacks[index], at: cells[index])
        }
        return board
    }

    private var demoCaption: String {
        if page == 2 {
            return demoStep < 3 ? "1 recipe ready — add strawberry" : "2 recipes ready on one tray!"
        }
        return switch demoStep {
        case 0: "Watch one ingredient land at a time"
        case 1: "Tea placed — next offer"
        case 2: "Tea + Cookie → Afternoon Tea"
        default: "L shape → 2 recipes ready!"
        }
    }

    private func recipeBadge(_ name: String, ready: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: ready ? "checkmark.circle.fill" : "circle.dotted")
            Text(name).lineLimit(2)
        }
        .font(.system(size: 11, weight: .bold, design: .rounded))
        .foregroundStyle(ready ? Palette.moss : Palette.inkSoft)
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 38)
        .background(ready ? Palette.moss.opacity(0.13) : Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
        .animation(.spring(duration: 0.35, bounce: 0.22), value: ready)
    }

    private func restartDemo() {
        demoTask?.cancel()
        let start = page == 0 ? 0 : 2
        demoStep = start
        guard !reduceMotion else {
            demoStep = 3
            return
        }
        demoTask = Task { @MainActor in
            for next in (start + 1)...3 {
                try? await Task.sleep(for: .milliseconds(900))
                guard !Task.isCancelled else { return }
                withAnimation(.spring(duration: 0.5, bounce: 0.3)) { demoStep = next }
            }
        }
    }
}
