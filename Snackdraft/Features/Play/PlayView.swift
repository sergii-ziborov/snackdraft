import SwiftUI

struct PlayView: View {
    @Environment(AppModel.self) private var model
    @State private var revealTask: Task<Void, Never>?

    var body: some View {
        if let session = model.session {
            GeometryReader { geo in
                let short = geo.size.height < 740
                ZStack {
                    background(session)
                    VStack(spacing: short ? 8 : 12) {
                        topBar(session)
                        mission(session, short: short)
                        offerRow(session, short: short)
                        tray(session)
                        bottomBar(session, short: short)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)

                    if session.phase == .revealing {
                        revealOverlay(session)
                    }
                }
            }
            .onAppear { startRevealIfNeeded() }
            .onChange(of: model.session?.phase) { _, _ in startRevealIfNeeded() }
            .onChange(of: model.session?.board.filledCount) { _, _ in startRevealIfNeeded() }
            .onDisappear { revealTask?.cancel() }
        } else {
            Color.black.onAppear { model.goHome() }
        }
    }

    private func background(_ session: PlaySession) -> some View {
        Palette.navy
            .ignoresSafeArea()
            .overlay {
                Image(session.context.world.backgroundAsset)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.38)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
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
            }
            .accessibilityIdentifier("back-button")

            Spacer()

            VStack(spacing: 2) {
                Text(session.context.isDaily ? "Daily tray" : "Level \(session.level.number)")
                    .font(.sdBody(16))
                    .foregroundStyle(.white)
                Text(session.context.world.title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Text("\(session.board.filledCount)/16")
                .font(.sdBody(13))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.12), in: Capsule())
        }
        .padding(.top, 8)
    }

    private func mission(_ session: PlaySession, short: Bool) -> some View {
        VStack(spacing: 4) {
            Text(session.selected == nil ? "Choose one snack" : "Place it on the tray")
                .font(.sdBody(short ? 14 : 16))
                .foregroundStyle(.white)
            Text(session.level.prompt)
                .font(.system(size: short ? 12 : 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.horizontal, 8)
    }

    private func offerRow(_ session: PlaySession, short: Bool) -> some View {
        HStack(spacing: 10) {
            ForEach(Array(session.offer.enumerated()), id: \.offset) { index, snack in
                let isOn = session.selected == snack
                Button {
                    session.select(snack)
                    if model.progress.hapticsEnabled { Feedback.tap() }
                } label: {
                    VStack(spacing: 6) {
                        SnackArt(snack: snack)
                            .frame(height: short ? 64 : 78)
                        Text(snack.displayName)
                            .font(.sdBody(12))
                            .foregroundStyle(isOn ? Palette.ink : .white)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(isOn ? Color.white : Color.white.opacity(0.10))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isOn ? Palette.gold : Color.white.opacity(0.18), lineWidth: isOn ? 3 : 1)
                    }
                }
                .buttonStyle(.plain)
                .disabled(session.phase != .picking)
                .accessibilityIdentifier("offer-\(index)")
                .accessibilityLabel(snack.displayName)
            }
        }
        .opacity(session.phase == .picking ? 1 : 0.35)
    }

    private func tray(_ session: PlaySession) -> some View {
        TrayGrid(
            board: session.board,
            selected: session.selected,
            tipCell: session.tipCell,
            highlight: Set(session.currentReveal?.cells ?? []),
            interactive: session.phase == .picking,
            previewBonus: { cell in
                session.preview(at: cell).map(\.bonus)
            },
            onPlace: { cell in
                session.place(at: cell)
                if model.progress.hapticsEnabled { Feedback.place() }
            }
        )
        .frame(maxHeight: 420)
    }

    private func bottomBar(_ session: PlaySession, short: Bool) -> some View {
        HStack(spacing: 12) {
            utilityButton("Undo", icon: "arrow.uturn.backward", count: session.undosLeft) {
                session.undo()
            }
            .accessibilityIdentifier("undo-button")
            .disabled(session.undosLeft == 0 || session.phase != .picking)

            VStack(spacing: 2) {
                Text(session.level.featured.title)
                    .font(.sdBody(13))
                    .foregroundStyle(Palette.gold)
                Text(session.level.featured.pointsLabel)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)

            utilityButton("Tip", icon: "lightbulb.fill", count: session.tipsLeft) {
                session.useTip()
                if model.progress.hapticsEnabled { Feedback.tap() }
            }
            .accessibilityIdentifier("tips-button")
            .disabled(session.tipsLeft == 0 || session.phase != .picking)
        }
        .padding(.bottom, short ? 4 : 8)
    }

    private func utilityButton(_ title: String, icon: String, count: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                    Text("\(count)")
                        .font(.sdBody(10))
                        .foregroundStyle(Palette.navy)
                        .padding(5)
                        .background(Palette.gold, in: Circle())
                        .offset(x: 6, y: -4)
                }
                Text(title)
                    .font(.sdBody(11))
                    .foregroundStyle(.white.opacity(0.8))
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
                        .font(.sdDisplay(28))
                        .foregroundStyle(.white)
                    Text("+\(hit.points.formatted())")
                        .font(.sdBody(20))
                        .foregroundStyle(Palette.gold)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.bottom, 28)
            }
        }
        .allowsHitTesting(false)
    }

    private func startRevealIfNeeded() {
        guard let session = model.session, session.phase == .revealing else { return }
        revealTask?.cancel()
        let fast = model.uiTesting
        revealTask = Task { @MainActor in
            let delay: UInt64 = fast ? 80_000_000 : 700_000_000
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
}
