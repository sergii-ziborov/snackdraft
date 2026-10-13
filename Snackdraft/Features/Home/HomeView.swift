import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        GeometryReader { geo in
            let compact = geo.size.height < 720
            ScrollView(showsIndicators: false) {
                VStack(spacing: compact ? 14 : 20) {
                    header(compact: compact)
                    journeyCard
                    destinations
                    dailyTray
                    Text("Small choices. Big combos.")
                        .font(.sdScript(16))
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.top, 2)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, compact ? 16 : 24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity, minHeight: geo.size.height, alignment: .center)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background {
            ScreenBackground(image: "TeaHouseBackground", dim: 0, opacity: 0.48)
                .overlay {
                    LinearGradient(stops: [
                        .init(color: Palette.cream.opacity(0.18), location: 0),
                        .init(color: Palette.cream.opacity(0.65), location: 0.35),
                        .init(color: Palette.cream, location: 0.75)
                    ], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                }
        }
    }

    private func header(compact: Bool) -> some View {
        VStack(spacing: 8) {
            Image("BrandMark")
                .resizable()
                .scaledToFit()
                .frame(width: compact ? 68 : 84, height: compact ? 68 : 84)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: Palette.woodDark.opacity(0.16), radius: 12, y: 6)
                .accessibilityHidden(true)

            Text("Snackdraft")
                .font(.sdDisplay(compact ? 32 : 36))
                .foregroundStyle(Palette.ink)
                .accessibilityIdentifier("home-title")

            Text("Build a delicious combo")
                .font(.sdScript(17))
                .foregroundStyle(Palette.woodDark)
        }
    }

    private var journeyCard: some View {
        let next = model.progress.nextPlayable()
        return VStack(spacing: 14) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("YOUR NEXT TRAY")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(Palette.inkSoft)
                    Text(next.0.title)
                        .font(.sdDisplay(19))
                        .foregroundStyle(Palette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                Text("Level \(next.1 + 1)")
                    .font(.sdBody(12))
                    .foregroundStyle(Palette.woodDark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Palette.cream, in: Capsule())
                    .fixedSize()
            }

            SDButton(title: "Continue Journey", icon: "arrow.right", compact: true) {
                model.playTapped()
            }
            .accessibilityIdentifier("play-button")

            Rectangle()
                .fill(Palette.wood.opacity(0.12))
                .frame(height: 1)
            progressSnapshot
        }
        .padding(18)
        .background(Color.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Palette.wood.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: Palette.woodDark.opacity(0.08), radius: 16, y: 6)
    }

    private var destinations: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                destination("Journey", subtitle: "Explore kitchens", icon: "map.fill", tint: Palette.woodDark) {
                    model.worldBrowseMode = .journey
                    model.screen = .worlds
                }
                destination("Free Play", subtitle: "Cook at your pace", icon: "sparkles", tint: Palette.mossPressed) {
                    model.worldBrowseMode = .free
                    model.screen = .worlds
                }
            }
            HStack(spacing: 10) {
                destination("Cookbook", subtitle: "Recipes & rewards", icon: "book.closed.fill", tint: Palette.coral) {
                    model.screen = .collection
                }
                destination("Settings", subtitle: "Make it yours", icon: "slider.horizontal.3", tint: Palette.inkSoft) {
                    model.screen = .settings
                }
            }
        }
    }

    private func destination(_ title: String, subtitle: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 38)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.sdBody(14))
                        .foregroundStyle(Palette.ink)
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Palette.inkSoft)
                }
                .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
            .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Palette.wood.opacity(0.10), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityIdentifier(title)
    }

    private var dailyTray: some View {
        Button {
            model.playDaily()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 23))
                    .foregroundStyle(Palette.wood)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Today's tray").font(.sdBody(15))
                    Text("A fresh little challenge every day")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Palette.woodDark)
            .padding(16)
            .background(Palette.gold.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("daily-button")
    }

    private var progressSnapshot: some View {
        HStack(spacing: 0) {
            progressStat(value: "\(model.progress.totalStars)", label: "stars", icon: "star.fill", tint: Palette.gold)
            progressStat(value: "\(model.progress.discoveredRecipes.count)/\(RecipeBook.all.count)", label: "recipes", icon: "fork.knife", tint: Palette.coral)
            progressStat(value: "\(AchievementBook.unlocked(in: model.progress).count)/\(AchievementBook.all.count)", label: "awards", icon: "trophy.fill", tint: Palette.mossPressed)
        }
        .contentTransition(.numericText())
    }

    private func progressStat(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tint)
                Text(value)
                    .font(.sdBody(16))
                    .foregroundStyle(Palette.ink)
            }
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(value) \(label)")
    }
}
