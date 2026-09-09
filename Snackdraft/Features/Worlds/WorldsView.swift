import SwiftUI

struct WorldsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            Palette.cream.ignoresSafeArea()
            VStack(spacing: 0) {
                ScreenHeader(title: "Themes") { model.screen = .home }
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(WorldID.allCases) { world in
                            worldCard(world)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func worldCard(_ world: WorldID) -> some View {
        let unlocked = model.progress.isUnlocked(world)
        let levels = LevelCatalog.levels(for: world)
        let cleared = model.progress.clearedCount(in: world)
        let stars = levels.reduce(0) { $0 + model.progress.stars(for: $1) }

        return VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                Image(world.backgroundAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 132)
                    .clipped()
                    .overlay {
                        LinearGradient(
                            colors: [.clear, Palette.navy.opacity(0.72)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .overlay {
                        if !unlocked {
                            Color.black.opacity(0.35)
                        }
                    }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(world.title)
                            .font(.sdDisplay(22))
                            .foregroundStyle(.white)
                        Text(world.subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                    if unlocked {
                        Text("\(cleared)/\(levels.count)")
                            .font(.sdBody(13))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.18), in: Capsule())
                    } else {
                        Label("Locked", systemImage: "lock.fill")
                            .font(.sdBody(12))
                            .foregroundStyle(.white)
                    }
                }
                .padding(14)
            }

            if unlocked {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(levels) { level in
                            Button {
                                model.play(world: world, index: level.index)
                            } label: {
                                VStack(spacing: 4) {
                                    Text("\(level.number)")
                                        .font(.sdBody(14))
                                        .foregroundStyle(Palette.ink)
                                    StarRow(stars: model.progress.stars(for: level), size: 8)
                                }
                                .frame(width: 52, height: 52)
                                .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("level-\(world.rawValue)-\(level.index)")
                        }
                    }
                }
                Text("\(stars) stars in this theme")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Palette.inkSoft)
            } else {
                Text(lockCopy(world))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Palette.inkSoft)
            }
        }
        .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }

    private func lockCopy(_ world: WorldID) -> String {
        switch world {
        case .tea: "Open."
        case .bento: "Clear 6 tea trays or earn 12 stars."
        case .garden: "Earn 18 stars to unlock the garden."
        case .kitchen: "Earn 30 stars to unlock the kitchen."
        }
    }
}
