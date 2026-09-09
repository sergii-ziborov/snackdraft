import SwiftUI

struct ResultView: View {
    @Environment(AppModel.self) private var model
    @State private var shareImage: UIImage?

    var body: some View {
        if let outcome = model.lastOutcome {
            GeometryReader { geo in
                let short = geo.size.height < 740
                ZStack {
                    Palette.navy.ignoresSafeArea()
                    Image(outcome.world.backgroundAsset)
                        .resizable()
                        .scaledToFill()
                        .opacity(0.32)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: short ? 12 : 18) {
                            VStack(spacing: 6) {
                                Text(title(for: outcome.stars))
                                    .font(.sdDisplay(short ? 32 : 40))
                                    .foregroundStyle(.white)
                                    .accessibilityIdentifier("result-title")
                                StarRow(stars: outcome.stars, size: short ? 22 : 28)
                                Text("Score \(outcome.breakdown.total.formatted())")
                                    .font(.sdBody(20))
                                    .foregroundStyle(Palette.gold)
                            }
                            .padding(.top, 20)

                            TrayGrid(board: outcome.board, compact: true)
                                .frame(maxWidth: short ? 260 : 300)
                                .allowsHitTesting(false)

                            comboList(outcome.breakdown)
                                .padding(.horizontal, 8)

                            VStack(spacing: 10) {
                                SDButton(title: "Next tray", kind: .success, icon: "arrow.right") {
                                    model.nextLevel()
                                }
                                .accessibilityIdentifier("next-tray-button")

                                HStack(spacing: 10) {
                                    quiet("Replay", icon: "arrow.counterclockwise") { model.retry() }
                                    quiet("Share", icon: "square.and.arrow.up") { share(outcome) }
                                    quiet("Home", icon: "house.fill") { model.goHome() }
                                }
                            }
                            .padding(.bottom, 24)
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: 560)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { shareImage != nil },
                set: { if !$0 { shareImage = nil } }
            )) {
                if let shareImage {
                    ShareSheet(items: [shareImage])
                }
            }
        } else {
            Color.black.onAppear { model.goHome() }
        }
    }

    private func title(for stars: Int) -> String {
        switch stars {
        case 3: "Delicious!"
        case 2: "Tasty!"
        default: "Nice tray"
        }
    }

    private func comboList(_ breakdown: ScoreBreakdown) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            row("Tray", points: breakdown.base, symbol: "square.grid.3x3")
            ForEach(breakdown.combos) { hit in
                row(hit.title, points: hit.points, symbol: hit.kind.symbol)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func row(_ title: String, points: Int, symbol: String) -> some View {
        HStack {
            Image(systemName: symbol)
                .foregroundStyle(Palette.gold)
                .frame(width: 22)
            Text(title)
                .font(.sdBody(15))
                .foregroundStyle(.white)
            Spacer()
            Text("+\(points.formatted())")
                .font(.sdBody(15))
                .foregroundStyle(Palette.moss)
        }
    }

    private func quiet(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.sdBody(13))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func share(_ outcome: TrayOutcome) {
        let view = VStack(spacing: 12) {
            Text("Snackdraft")
                .font(.sdDisplay(28))
            TrayGrid(board: outcome.board, compact: true)
                .frame(width: 280, height: 280)
            Text("Score \(outcome.breakdown.total.formatted())")
                .font(.sdBody(18))
        }
        .padding(24)
        .background(Palette.cream)
        .environment(\.colorScheme, .light)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3
        shareImage = renderer.uiImage
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
