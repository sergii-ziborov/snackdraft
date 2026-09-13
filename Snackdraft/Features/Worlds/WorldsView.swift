import SwiftUI

struct WorldsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        PageShell(title: "World Tour", onBack: { model.screen = .home }) {
            VStack(spacing: 0) {
                Picker("Game mode", selection: $model.worldBrowseMode) {
                    ForEach(WorldBrowseMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .accessibilityIdentifier("world-mode-picker")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        modeIntro
                        if model.worldBrowseMode == .journey {
                            journeyRoad
                        } else {
                            freePlayGrid
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                    .frame(maxWidth: 680)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var modeIntro: some View {
        VStack(spacing: 4) {
            Text(model.worldBrowseMode == .journey ? "Follow the flavor road" : "Your kitchen, your pace")
                .font(.sdDisplay(22))
                .foregroundStyle(Palette.ink)
            Text(model.worldBrowseMode == .journey
                 ? "Clear trays to travel onward. New kitchens and ingredients join the route."
                 : "Choose any unlocked kitchen. Its full pantry is open and campaign stars stay untouched.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.inkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 10)
    }

    private var journeyRoad: some View {
        let currentWorld = model.progress.nextPlayable().0
        return VStack(spacing: 0) {
            ForEach(Array(WorldID.allCases.enumerated()), id: \.element) { index, world in
                HStack(alignment: .top, spacing: 12) {
                    routeMarker(world, index: index, currentWorld: currentWorld)
                    journeyCard(world, isCurrent: world == currentWorld)
                        .offset(x: index.isMultiple(of: 2) ? 0 : 10)
                }
            }
        }
    }

    private func routeMarker(_ world: WorldID, index: Int, currentWorld: WorldID) -> some View {
        let unlocked = model.progress.isUnlocked(world)
        let complete = model.progress.clearedCount(in: world) == LevelCatalog.levels(for: world).count
        return VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(complete ? Palette.moss : (world == currentWorld ? Palette.gold : Color.white.opacity(0.92)))
                    .frame(width: 42, height: 42)
                    .shadow(color: .black.opacity(0.12), radius: 5, y: 3)
                Image(systemName: complete ? "checkmark" : (unlocked ? "fork.knife" : "lock.fill"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(complete ? .white : Palette.ink)
            }
            if index < WorldID.allCases.count - 1 {
                Rectangle()
                    .fill(unlocked ? Palette.gold.opacity(0.7) : Palette.inkSoft.opacity(0.25))
                    .frame(width: 4, height: 196)
            }
        }
        .frame(width: 44)
    }

    private func journeyCard(_ world: WorldID, isCurrent: Bool) -> some View {
        let unlocked = model.progress.isUnlocked(world)
        let levels = LevelCatalog.levels(for: world)
        let cleared = model.progress.clearedCount(in: world)
        let stars = levels.reduce(0) { $0 + model.progress.stars(for: $1) }

        return VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                Image(world.backgroundAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 112)
                    .clipped()
                    .overlay {
                        LinearGradient(colors: [.clear, Palette.navy.opacity(0.82)], startPoint: .top, endPoint: .bottom)
                    }
                    .overlay { if !unlocked { Color.black.opacity(0.42) } }

                VStack(alignment: .leading, spacing: 2) {
                    Text(world.title)
                        .font(.sdDisplay(20))
                        .foregroundStyle(.white)
                    Text(unlocked ? "\(cleared)/\(levels.count) trays · \(stars) stars" : lockCopy(world))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(2)
                }
                .padding(12)

                if isCurrent {
                    Text("CURRENT")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Palette.gold, in: Capsule())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(9)
                }
            }

            if unlocked {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(levels) { level in
                            let levelUnlocked = model.progress.isLevelUnlocked(level)
                            Button {
                                model.play(world: world, index: level.index)
                            } label: {
                                VStack(spacing: 4) {
                                    Text("\(level.number)")
                                        .font(.sdBody(13))
                                    StarRow(stars: model.progress.stars(for: level), size: 7)
                                }
                                .foregroundStyle(Palette.ink)
                                .frame(width: 50, height: 50)
                                .background(levelUnlocked ? Color.white : Color.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay { if !levelUnlocked { Image(systemName: "lock.fill").font(.system(size: 9)).foregroundStyle(Palette.inkSoft) } }
                            }
                            .buttonStyle(.plain)
                            .disabled(!levelUnlocked)
                            .accessibilityIdentifier("level-\(world.rawValue)-\(level.index)")
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
        .background(Color.white.opacity(0.64), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isCurrent ? Palette.gold : Color.clear, lineWidth: 2)
        }
        .shadow(color: .black.opacity(0.08), radius: 9, y: 4)
        .padding(.bottom, 14)
    }

    private var freePlayGrid: some View {
        LazyVStack(spacing: 14) {
            ForEach(WorldID.allCases) { world in
                freePlayCard(world)
            }
        }
    }

    private func freePlayCard(_ world: WorldID) -> some View {
        let unlocked = model.progress.isUnlocked(world)
        let pantry = LevelCatalog.pantry(for: world)
        let recipes = RecipeBook.recipes(for: world)
        let found = recipes.filter { model.progress.hasDiscovered($0) }.count

        return Button {
            model.playFree(world: world)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                Image(world.backgroundAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 126)
                    .clipped()
                    .overlay { LinearGradient(colors: [.clear, Palette.navy.opacity(0.82)], startPoint: .top, endPoint: .bottom) }
                    .overlay { if !unlocked { Color.black.opacity(0.42) } }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(world.title)
                            .font(.sdDisplay(22))
                            .foregroundStyle(.white)
                        Text(unlocked ? "\(pantry.count) ingredients · \(found)/\(recipes.count) recipes" : lockCopy(world))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.86))
                    }
                    .padding(14)
                }

                if unlocked {
                    VStack(spacing: 10) {
                        HStack(spacing: 4) {
                            ForEach(Array(pantry.prefix(8))) { snack in
                                SnackArt(snack: snack)
                                    .frame(width: 30, height: 30)
                            }
                            if pantry.count > 8 {
                                Text("+\(pantry.count - 8)")
                                    .font(.sdBody(11))
                                    .foregroundStyle(Palette.inkSoft)
                            }
                            Spacer(minLength: 0)
                        }
                        Label("Cook freely", systemImage: "play.fill")
                            .font(.sdBody(15))
                            .foregroundStyle(Palette.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(Palette.gold, in: Capsule())
                    }
                    .padding(12)
                }
            }
            .background(Color.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 9, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
        .accessibilityIdentifier("free-world-\(world.rawValue)")
        .accessibilityLabel(unlocked ? "Cook freely in \(world.title)" : "\(world.title), locked")
    }

    private func lockCopy(_ world: WorldID) -> String {
        switch world {
        case .tea: "Open."
        case .bento: "Clear 4 tea trays or earn 8 stars."
        case .thai: "Earn 14 stars to open the night market."
        case .israeli: "Earn 22 stars to open the shared table."
        case .italian: "Earn 30 stars to open the trattoria."
        case .garden: "Earn 38 stars to unlock the garden."
        case .kitchen: "Earn 50 stars to unlock the kitchen."
        case .mexican: "Earn 62 stars to open the mercado."
        case .indian: "Earn 74 stars to open the spice house."
        }
    }
}
