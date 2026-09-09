import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        GeometryReader { geo in
            let short = geo.size.height < 720
            Palette.cream
                .ignoresSafeArea()
                .overlay {
                    Image("TeaHouseBackground")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.28)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
                .overlay {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: short ? 12 : 22) {
                            header(short: short)
                            featureRow(short: short)
                            quote(short: short)
                            actions
                            Text("Good food brings good mood")
                                .font(.sdScript(16))
                                .foregroundStyle(Palette.inkSoft)
                                .padding(.top, short ? 2 : 8)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, short ? 10 : 28)
                        .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
                        .frame(maxWidth: .infinity)
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func header(short: Bool) -> some View {
        VStack(spacing: short ? 6 : 10) {
            Image("BrandMark")
                .resizable()
                .scaledToFit()
                .frame(width: short ? 72 : 96, height: short ? 72 : 96)
                .clipShape(RoundedRectangle(cornerRadius: short ? 18 : 24, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 10, y: 6)

            Text("Snackdraft")
                .font(.sdDisplay(short ? 32 : 38))
                .foregroundStyle(Palette.ink)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text("Build a delicious combo")
                .font(.sdScript(short ? 17 : 20))
                .foregroundStyle(Palette.wood)
        }
        .padding(.top, short ? 4 : 12)
    }

    private func featureRow(short: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            FeaturePill(icon: "hand.draw.fill", title: "Pick & place", subtitle: "one snack each turn", tint: Palette.coral, compact: short)
            FeaturePill(icon: "sparkles", title: "Build combos", subtitle: "see the bonus first", tint: Palette.moss, compact: short)
            FeaturePill(icon: "leaf.fill", title: "Cozy worlds", subtitle: "tea, bento, garden", tint: Palette.wood, compact: short)
        }
        .padding(.top, short ? 2 : 8)
    }

    private func quote(short: Bool) -> some View {
        VStack(spacing: 2) {
            Text("Small choices.")
            Text("Big combos.")
        }
        .font(.sdScript(short ? 18 : 22))
        .foregroundStyle(Palette.inkSoft)
        .multilineTextAlignment(.center)
        .padding(.vertical, short ? 2 : 6)
    }

    private var actions: some View {
        VStack(spacing: 12) {
            SDButton(title: "Play", kind: .play, icon: "fork.knife") {
                model.playTapped()
            }
            .accessibilityIdentifier("play-button")

            HStack(spacing: 10) {
                miniButton("Themes", icon: "square.grid.2x2.fill") { model.screen = .worlds }
                miniButton("Recipes", icon: "book.fill") { model.screen = .collection }
                miniButton("Settings", icon: "gearshape.fill") { model.screen = .settings }
            }

            Button {
                model.playDaily()
            } label: {
                Label("Today's tray", systemImage: "sun.max.fill")
                    .font(.sdBody(15))
                    .foregroundStyle(Palette.wood)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("daily-button")
        }
    }

    private func miniButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.sdBody(12))
            }
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(title)
    }
}
