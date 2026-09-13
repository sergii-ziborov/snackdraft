import SwiftUI

struct CollectionView: View {
    @Environment(AppModel.self) private var model
    @State private var tab: Tab = .recipes
    @State private var selectedWorld: WorldID?
    @State private var showMadeOnly = false
    @State private var selectedSnack: SnackID?
    @State private var selectedRecipe: DishRecipe?

    enum Tab: String, CaseIterable {
        case recipes = "Recipes"
        case snacks = "Pantry"
        case achievements = "Awards"
    }

    var body: some View {
        PageShell(title: "Cookbook", onBack: { model.screen = .home }) {
            VStack(spacing: 0) {
                Picker("Section", selection: $tab) {
                    ForEach(Tab.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        Color.clear.frame(height: 1).id("collection-top")
                        Group {
                            switch tab {
                            case .recipes: recipeList
                            case .snacks: snackGrid
                            case .achievements: achievementList
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)
                        .frame(maxWidth: 680)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .onAppear { scrollToTop(proxy) }
                    .onChange(of: tab) { _, _ in scrollToTop(proxy) }
                    .onChange(of: selectedWorld) { _, _ in scrollToTop(proxy) }
                    .onChange(of: showMadeOnly) { _, _ in scrollToTop(proxy) }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .sheet(item: $selectedSnack) { snack in
            snackDetail(snack)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedRecipe) { recipe in
            recipeDetail(recipe)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private func scrollToTop(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.async { proxy.scrollTo("collection-top", anchor: .top) }
    }

    private var recipeList: some View {
        VStack(alignment: .leading, spacing: 16) {
            cookbookIntro
            cuisineFilter
            if showMadeOnly && worldsToShow.isEmpty {
                Text("No recipes plated yet. Connect ingredients on a tray and serve your first dish!")
                    .font(.sdBody(14))
                    .foregroundStyle(Palette.inkSoft)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            ForEach(worldsToShow) { world in
                cuisineSection(world)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.24), value: selectedWorld)
        .animation(.easeInOut(duration: 0.24), value: showMadeOnly)
    }

    private var cookbookIntro: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Palette.coral)
                .frame(width: 42, height: 42)
                .background(Palette.coral.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text("Connect ingredients. Serve when ready.")
                    .font(.sdBody(16))
                    .foregroundStyle(Palette.ink)
                Text("\(model.progress.discoveredRecipes.count) of \(RecipeBook.all.count) recipes made")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.moss)
                    .accessibilityIdentifier("recipes-made-count")
                Text("Recipe ingredients connect side-to-side in any shape — diagonals alone do not count. One tray can make several recipes, even with shared ingredients. Serve as soon as one is ready; filling all 16 cells is optional (+500). A straight line is only needed for the separate Sweet Line bonus.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.top, 2)
    }

    private var cuisineFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "All", world: nil)
                filterChip(title: "Made", world: nil, madeOnly: true)
                ForEach(WorldID.allCases) { world in
                    filterChip(title: world.shortTitle, world: world)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func filterChip(title: String, world: WorldID?, madeOnly: Bool = false) -> some View {
        let selected = showMadeOnly == madeOnly && selectedWorld == world
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedWorld = world
                showMadeOnly = madeOnly
            }
        } label: {
            HStack(spacing: 5) {
                if let world, !model.progress.isUnlocked(world) {
                    Image(systemName: "lock.fill").font(.system(size: 9, weight: .bold))
                }
                Text(title)
            }
            .font(.sdBody(12))
            .foregroundStyle(selected ? Color.white : Palette.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selected ? (world?.tint ?? Palette.ink) : Color.white.opacity(0.78), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var worldsToShow: [WorldID] {
        if showMadeOnly {
            return WorldID.allCases.filter { world in
                RecipeBook.recipes(for: world).contains(where: model.progress.hasDiscovered)
            }
        }
        return selectedWorld.map { [$0] } ?? WorldID.allCases
    }

    private func cuisineSection(_ world: WorldID) -> some View {
        let allRecipes = RecipeBook.recipes(for: world)
        let recipes = showMadeOnly ? allRecipes.filter(model.progress.hasDiscovered) : allRecipes
        let unlocked = model.progress.isUnlocked(world)
        let found = allRecipes.filter(model.progress.hasDiscovered).count
        return VStack(alignment: .leading, spacing: 9) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(world.title)
                        .font(.sdDisplay(19))
                        .foregroundStyle(Palette.ink)
                    Text(unlocked ? RecipeBook.hook(for: world) : unlockCopy(world))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Palette.inkSoft)
                        .lineLimit(2)
                }
                Spacer()
                Text(unlocked ? "\(found)/\(allRecipes.count)" : "Locked")
                    .font(.sdBody(11))
                    .foregroundStyle(unlocked ? world.tint : Palette.inkSoft)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background((unlocked ? world.tint : Palette.inkSoft).opacity(0.12), in: Capsule())
            }
            ForEach(recipes) { recipe in
                recipeRow(recipe, worldUnlocked: unlocked)
            }
        }
    }

    private func recipeRow(_ recipe: DishRecipe, worldUnlocked: Bool) -> some View {
        let plated = model.progress.hasDiscovered(recipe)
        let available = worldUnlocked && recipe.ingredients.allSatisfy(model.progress.isAvailable)
        return Button {
            guard available else { return }
            selectedRecipe = recipe
        } label: {
            HStack(alignment: .center, spacing: 12) {
                DishArt(recipe: recipe)
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .saturation(available ? 1 : 0)
                    .opacity(available ? 1 : 0.32)
                    .overlay {
                        if !available {
                            ZStack {
                                Color.black.opacity(0.16)
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.4), radius: 4)
                            }
                        }
                    }
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(available ? recipe.name : "Mystery recipe")
                            .font(.sdBody(15))
                            .foregroundStyle(Palette.ink)
                            .lineLimit(1)
                        Spacer()
                        if plated {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(Palette.moss)
                                .transition(.scale.combined(with: .opacity))
                            }
                    }
                    Text(available ? recipe.subtitle : recipeRevealLabel(recipe, worldUnlocked: worldUnlocked))
                        .font(.sdScript(13))
                        .foregroundStyle(Palette.wood)
                        .lineLimit(1)
                    if available {
                        ingredientStrip(recipe)
                        HStack {
                            Text(plated ? "Plated" : "Ready to discover")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(plated ? Palette.moss : Palette.inkSoft)
                            Spacer()
                            Text("+\(recipe.bonus.formatted())")
                                .font(.sdBody(12))
                                .foregroundStyle(Palette.wood)
                        }
                    }
                }
            }
            .padding(11)
            .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(plated ? Palette.moss.opacity(0.35) : Color.black.opacity(0.04), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(!available)
        .accessibilityIdentifier("recipe-\(recipe.id)")
    }

    private func recipeRevealLabel(_ recipe: DishRecipe, worldUnlocked: Bool) -> String {
        guard worldUnlocked else { return "Unlock \(recipe.world.shortTitle) to reveal" }
        let missing = recipe.ingredients.compactMap { snack -> LevelDef? in
            model.progress.isAvailable(snack) ? nil : LevelCatalog.introduction(for: snack)
        }
        guard let latest = missing.max(by: { $0.index < $1.index }) else { return "Keep cooking to reveal" }
        return "Reach \(latest.world.shortTitle) level \(latest.number) to reveal"
    }

    private func ingredientStrip(_ recipe: DishRecipe) -> some View {
        HStack(spacing: 3) {
            ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, snack in
                if index > 0 {
                    Image(systemName: "plus").font(.system(size: 8, weight: .bold)).foregroundStyle(Palette.inkSoft)
                }
                SnackArt(snack: snack).frame(width: 25, height: 25)
            }
            Spacer(minLength: 0)
        }
    }

    private var snackGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Ingredients arrive a few at a time as you clear kitchen levels. Place one on a tray to catalogue it fully.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.inkSoft)
                .padding(.top, 4)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 12)], spacing: 12) {
                ForEach(SnackID.allCases) { snack in
                    let available = model.progress.isAvailable(snack)
                    let seen = model.progress.hasSeen(snack)
                    Button { selectedSnack = snack } label: {
                        VStack(spacing: 6) {
                            SnackArt(snack: snack)
                                .frame(width: 70, height: 70)
                                .saturation(available ? 1 : 0)
                                .opacity(available ? (seen ? 1 : 0.72) : 0.32)
                                .overlay {
                                    if !available {
                                        Image(systemName: "lock.fill")
                                            .foregroundStyle(.white)
                                            .shadow(color: .black.opacity(0.5), radius: 3)
                                    }
                                }
                            Text(available ? snack.displayName : "???")
                                .font(.sdBody(11))
                                .foregroundStyle(Palette.ink)
                                .lineLimit(1)
                            Text(available ? (seen ? "Used" : "New") : ingredientUnlockLabel(snack))
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(available ? (seen ? Palette.moss : Palette.coral) : Palette.inkSoft)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("snack-\(snack.rawValue)")
                }
            }
        }
    }

    private var achievementList: some View {
        VStack(alignment: .leading, spacing: 12) {
            let unlocked = AchievementBook.unlocked(in: model.progress).count
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chef’s shelf").font(.sdDisplay(22))
                    Text("\(unlocked) of \(AchievementBook.all.count) awards unlocked")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Palette.inkSoft)
                }
                Spacer()
                Image(systemName: "trophy.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Palette.gold)
            }
            .padding(.vertical, 6)
            ForEach(AchievementBook.all) { achievement in
                achievementRow(achievement)
            }
        }
    }

    private func achievementRow(_ achievement: Achievement) -> some View {
        let value = min(achievement.progress(model.progress), achievement.target)
        let unlocked = value >= achievement.target
        return HStack(spacing: 13) {
            Image(systemName: achievement.symbol)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(unlocked ? Palette.gold : Palette.inkSoft.opacity(0.45))
                .frame(width: 48, height: 48)
                .background((unlocked ? Palette.gold : Palette.inkSoft).opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(achievement.title).font(.sdBody(15))
                    Spacer()
                    Text(unlocked ? "Unlocked" : "\(value)/\(achievement.target)")
                        .font(.sdBody(11))
                        .foregroundStyle(unlocked ? Palette.moss : Palette.wood)
                }
                Text(achievement.detail)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Palette.inkSoft)
                ProgressView(value: Double(value), total: Double(achievement.target))
                    .tint(unlocked ? Palette.moss : Palette.gold)
            }
        }
        .padding(13)
        .background(Color.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func snackDetail(_ snack: SnackID) -> some View {
        let available = model.progress.isAvailable(snack)
        return VStack(spacing: 14) {
            SnackArt(snack: snack)
                .frame(width: 140, height: 140)
                .saturation(available ? 1 : 0)
                .opacity(available ? 1 : 0.38)
            Text(available ? snack.displayName : "Locked ingredient").font(.sdDisplay(26))
            if available {
                Text(snack.comboHint)
                    .font(.sdBody(16))
                    .foregroundStyle(Palette.wood)
                    .multilineTextAlignment(.center)
                Text(snack.blurb)
                    .font(.sdScript(18))
                    .foregroundStyle(Palette.inkSoft)
                    .multilineTextAlignment(.center)
            } else {
                Label("\(ingredientUnlockLabel(snack)) reveals this ingredient.", systemImage: "lock.fill")
                    .font(.sdBody(15))
                    .foregroundStyle(Palette.wood)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(24)
        .background(Palette.cream)
    }

    private func ingredientUnlockLabel(_ snack: SnackID) -> String {
        guard let level = LevelCatalog.introduction(for: snack) else { return "Coming later" }
        return "\(level.world.shortTitle) · Level \(level.number)"
    }

    private func recipeDetail(_ recipe: DishRecipe) -> some View {
        let plated = model.progress.hasDiscovered(recipe)
        return ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                DishArt(recipe: recipe)
                    .aspectRatio(1.25, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(recipe.name).font(.sdDisplay(28))
                        Text(recipe.subtitle).font(.sdScript(19)).foregroundStyle(Palette.wood)
                    }
                    Spacer()
                    Label(plated ? "Plated" : "Not yet", systemImage: plated ? "checkmark.seal.fill" : "sparkles")
                        .font(.sdBody(11))
                        .foregroundStyle(plated ? Palette.moss : Palette.coral)
                }
                Text(recipe.blurb)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Palette.inkSoft)
                VStack(alignment: .leading, spacing: 10) {
                    Label("Plate it on the board", systemImage: "square.grid.3x3.fill").font(.sdBody(15))
                    recipeBlueprint(recipe)
                    Text("Only edge-to-edge contact counts; diagonal pieces do not connect. Extra ingredients may surround the recipe.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Palette.inkSoft)
                }
                .padding(14)
                .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                Text("Ingredients").font(.sdBody(15))
                ForEach(recipe.ingredients) { snack in
                    HStack(spacing: 10) {
                        SnackArt(snack: snack).frame(width: 44, height: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(snack.displayName).font(.sdBody(15))
                            Text(snack.comboHint)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Palette.inkSoft)
                        }
                    }
                }
                HStack {
                    Label("Serve as soon as connected", systemImage: "bell.fill")
                    Spacer()
                    Text("+\(recipe.bonus.formatted())")
                }
                .font(.sdBody(14))
                .foregroundStyle(Palette.wood)
                .padding(14)
                .background(Palette.gold.opacity(0.16), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(24)
        }
        .background(Palette.cream)
    }

    private func recipeBlueprint(_ recipe: DishRecipe) -> some View {
        HStack(spacing: -3) {
            ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, snack in
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(Palette.woodDark.opacity(0.86))
                        .frame(width: 58, height: 58)
                    SnackArt(snack: snack).frame(width: 50, height: 50).padding(.trailing, 4)
                }
                .zIndex(Double(recipe.ingredients.count - index))
            }
            Spacer()
        }
        .accessibilityLabel(recipe.ingredients.map(\.displayName).joined(separator: ", connected to "))
    }

    private func unlockCopy(_ world: WorldID) -> String {
        switch world {
        case .tea: "Open now."
        case .bento: "Clear 4 tea trays or earn 8 stars."
        case .thai: "Earn 14 stars to unlock."
        case .israeli: "Earn 22 stars to unlock."
        case .italian: "Earn 30 stars to unlock."
        case .garden: "Earn 38 stars to unlock."
        case .kitchen: "Earn 50 stars to unlock."
        case .mexican: "Earn 62 stars to unlock."
        case .indian: "Earn 74 stars to unlock."
        }
    }
}

extension WorldID {
    var shortTitle: String {
        switch self {
        case .tea: "Tea"
        case .bento: "Bento"
        case .thai: "Thai"
        case .israeli: "Israeli"
        case .italian: "Italian"
        case .garden: "Garden"
        case .kitchen: "Kitchen"
        case .mexican: "Mexican"
        case .indian: "Indian"
        }
    }
}
