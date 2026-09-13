import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        GeometryReader { geo in
            let short = geo.size.height < 800
            ZStack {
                Palette.cream.ignoresSafeArea()
                ScreenBackground(image: "TeaHouseBackground", dim: 0, opacity: 0.28)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: short ? 12 : 22) {
                        header(short: short)
                        featureRow(short: short)
                        quote(short: short)
                        progressSnapshot
                        actions(short: short)
                        Text("Good food brings good mood")
                            .font(.sdScript(16))
                            .foregroundStyle(Palette.inkSoft)
                            .padding(.top, short ? 2 : 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, short ? 10 : 28)
                    .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
                    .frame(width: geo.size.width)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }

    private func header(short: Bool) -> some View {
        VStack(spacing: short ? 6 : 10) {
            Image("BrandMark")
                .resizable()
                .scaledToFit()
                .frame(width: short ? 72 : 96, height: short ? 72 : 96)
                .clipShape(RoundedRectangle(cornerRadius: short ? 18 : 24, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
                .phaseAnimator([false, true]) { view, lifted in
                    view.offset(y: lifted ? -3 : 3).rotationEffect(.degrees(lifted ? -1 : 1))
                } animation: { _ in
                    .easeInOut(duration: 2.2)
                }

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
            FeaturePill(icon: "globe.europe.africa.fill", title: "World kitchens", subtitle: "nine cuisines", tint: Palette.wood, compact: short)
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

    private func actions(short: Bool) -> some View {
        VStack(spacing: 12) {
            SDButton(title: "Continue Journey", kind: .play, icon: "point.topleft.down.to.point.bottomright.curvepath", compact: short) {
                model.playTapped()
            }
            .accessibilityIdentifier("play-button")

            HStack(spacing: 10) {
                miniButton("Journey", icon: "map.fill") {
                    model.worldBrowseMode = .journey
                    model.screen = .worlds
                }
                miniButton("Free Play", icon: "sparkles") {
                    model.worldBrowseMode = .free
                    model.screen = .worlds
                }
            }
            HStack(spacing: 10) {
                miniButton("Cookbook", icon: "book.fill") { model.screen = .collection }
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

    private var progressSnapshot: some View {
        HStack(spacing: 0) {
            progressStat(value: "\(model.progress.totalStars)", label: "stars", icon: "star.fill", tint: Palette.gold)
            Divider().frame(height: 34)
            progressStat(value: "\(model.progress.discoveredRecipes.count)/\(RecipeBook.all.count)", label: "recipes", icon: "fork.knife", tint: Palette.coral)
            Divider().frame(height: 34)
            progressStat(value: "\(AchievementBook.unlocked(in: model.progress).count)/\(AchievementBook.all.count)", label: "awards", icon: "trophy.fill", tint: Palette.moss)
        }
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .contentTransition(.numericText())
    }

    private func progressStat(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(tint)
                Text(value)
                    .font(.sdBody(13))
                    .foregroundStyle(Palette.ink)
            }
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.inkSoft)
        }
        .frame(maxWidth: .infinity)
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
