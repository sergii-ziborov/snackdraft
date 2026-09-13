import SwiftUI

struct ResultView: View {
    @Environment(AppModel.self) private var model
    @State private var shareImage: UIImage?
    @State private var recipeReveal = RecipeRevealSequence(dishes: [])

    var body: some View {
        if let outcome = model.lastOutcome {
            GeometryReader { geo in
                let short = geo.size.height < 760
                let traySide = min(short ? 168 : 240, geo.size.width - 56)
                ZStack {
                    Palette.navy.ignoresSafeArea()
                    ScreenBackground(image: outcome.world.backgroundAsset, dim: 0.38)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: short ? 10 : 16) {
                            VStack(spacing: 6) {
                                Text(title(for: outcome.stars))
                                    .font(.sdDisplay(short ? 28 : 36))
                                    .foregroundStyle(.white)
                                    .accessibilityIdentifier("result-title")
                                StarRow(stars: outcome.stars, size: short ? 20 : 28)
                                Text("Score \(outcome.totalScore.formatted())")
                                    .font(.sdBody(18))
                                    .foregroundStyle(Palette.gold)
                                if outcome.isFree {
                                    Text("Free Play · recipes saved, campaign stars unchanged")
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.74))
                                }
                            }
                            .padding(.top, 8)

                            TrayGrid(board: outcome.board, compact: true)
                                .frame(width: traySide, height: traySide)
                                .allowsHitTesting(false)

                            if !outcome.dishes.isEmpty {
                                platedRecipes(outcome)
                            }
                            comboList(outcome.breakdown)
                            if !outcome.newAchievements.isEmpty {
                                achievementList(outcome.newAchievements)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .frame(width: geo.size.width)
                    }
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        VStack(spacing: 8) {
                            SDButton(title: outcome.isFree ? "Choose kitchen" : "Next tray", kind: .success, icon: "arrow.right", compact: true) {
                                model.nextLevel()
                            }
                            .accessibilityIdentifier("next-tray-button")

                            HStack(spacing: 8) {
                                quiet("Replay", icon: "arrow.counterclockwise") { model.retry() }
                                quiet("Share", icon: "square.and.arrow.up") { share(outcome) }
                                quiet("Home", icon: "house.fill") { model.goHome() }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity)
                        .background(Palette.navy.ignoresSafeArea(edges: .bottom))
                    }

                    if let dish = recipeReveal.current {
                        dishReveal(
                            dish,
                            position: recipeReveal.currentIndex + 1,
                            total: recipeReveal.dishes.count,
                            isNew: outcome.newDishIDs.contains(dish.id),
                            advance: {
                                withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                                    recipeReveal.advance()
                                }
                            },
                            dismiss: {
                                withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                                    recipeReveal.dismiss()
                                }
                            }
                        )
                        .id(dish.id)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
            .onAppear {
                withAnimation(.spring(duration: 0.55, bounce: 0.32)) {
                    recipeReveal = RecipeRevealSequence(dishes: outcome.dishes)
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

    private func platedRecipes(_ outcome: TrayOutcome) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Label("Recipes made", systemImage: "book.closed.fill")
                    .font(.sdBody(15))
                    .foregroundStyle(Palette.gold)
                Spacer()
                Text("\(outcome.dishes.count)")
                    .font(.sdBody(13))
                    .foregroundStyle(.white)
            }
            ForEach(outcome.dishes) { dish in
                HStack(spacing: 10) {
                    DishArt(recipe: dish)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dish.name)
                            .font(.sdBody(14))
                            .foregroundStyle(.white)
                        if outcome.newDishIDs.contains(dish.id) {
                            Text("New discovery")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Palette.gold)
                        }
                    }
                    Spacer()
                    Text("+\(dish.bonus.formatted())")
                        .font(.sdBody(13))
                        .foregroundStyle(Palette.gold)
                }
                .accessibilityIdentifier("result-recipe-\(dish.id)")
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func comboList(_ breakdown: ScoreBreakdown) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            row("Tray", points: breakdown.base, symbol: "square.grid.3x3", tint: Palette.gold)
            ForEach(breakdown.combos) { hit in
                row(hit.title, points: hit.points, symbol: hit.kind.symbol, tint: hit.kind.tint)
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func achievementList(_ achievements: [Achievement]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Achievement unlocked")
                .font(.sdBody(13))
                .foregroundStyle(Palette.gold)
            ForEach(achievements) { achievement in
                HStack(spacing: 10) {
                    Image(systemName: achievement.symbol)
                        .foregroundStyle(Palette.gold)
                        .frame(width: 28, height: 28)
                        .background(Palette.gold.opacity(0.15), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(achievement.title)
                            .font(.sdBody(14))
                            .foregroundStyle(.white)
                        Text(achievement.detail)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    Spacer()
                }
            }
        }
        .padding(14)
        .background(Palette.gold.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Palette.gold.opacity(0.45), lineWidth: 1)
        }
    }

    private func dishReveal(
        _ dish: DishRecipe,
        position: Int,
        total: Int,
        isNew: Bool,
        advance: @escaping () -> Void,
        dismiss: @escaping () -> Void
    ) -> some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.62).ignoresSafeArea()
                VStack(spacing: 12) {
                    HStack {
                        Text("Recipe \(position) of \(total)")
                            .font(.sdBody(13))
                            .foregroundStyle(Palette.gold)
                        Spacer()
                        Button(action: dismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                                .background(Color.white.opacity(0.14), in: Circle())
                        }
                        .accessibilityLabel("Close recipe reveal")
                    }
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            Text(isNew ? "You plated a new recipe" : "You made")
                                .font(.sdScript(20))
                                .foregroundStyle(Palette.gold)
                            DishArt(recipe: dish)
                                .frame(maxHeight: 200)
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: .black.opacity(0.4), radius: 18, y: 8)
                            Text(dish.name)
                                .font(.sdDisplay(32))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            Text(dish.subtitle)
                                .font(.sdScript(20))
                                .foregroundStyle(Palette.gold)
                            Text(dish.blurb)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                            Text(dish.method)
                                .font(.sdScript(16))
                                .foregroundStyle(Palette.gold.opacity(0.9))
                                .multilineTextAlignment(.center)
                            HStack(spacing: 8) {
                                ForEach(dish.ingredients) { snack in
                                    SnackArt(snack: snack)
                                        .frame(width: 36, height: 36)
                                }
                            }
                            Text("+\(dish.bonus.formatted())")
                                .font(.sdBody(18))
                                .foregroundStyle(Palette.moss)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    Button(action: advance) {
                        Text(position < total ? "Next recipe" : "See results")
                            .font(.sdBody(17))
                            .foregroundStyle(Palette.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Palette.gold, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("next-recipe-button")
                }
                .padding(20)
                .frame(maxWidth: 440)
                .frame(maxHeight: min(geometry.size.height - 20, 720))
                .background(Palette.navy.opacity(0.92), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal, 22)
            }
        }
    }

    private func row(_ title: String, points: Int, symbol: String, tint: Color) -> some View {
        HStack {
            Image(systemName: symbol)
                .foregroundStyle(tint)
                .frame(width: 22)
            Text(title)
                .font(.sdBody(15))
                .foregroundStyle(.white)
            Spacer()
            Text("+\(points.formatted())")
                .font(.sdBody(15))
                .foregroundStyle(tint)
        }
    }

    private func quiet(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.sdBody(13))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.16), in: Capsule())
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
            Text("Score \(outcome.totalScore.formatted())")
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

struct RecipeRevealSequence: Equatable {
    let dishes: [DishRecipe]
    private(set) var currentIndex = 0

    var current: DishRecipe? {
        dishes.indices.contains(currentIndex) ? dishes[currentIndex] : nil
    }

    mutating func advance() {
        currentIndex = min(currentIndex + 1, dishes.count)
    }

    mutating func dismiss() {
        currentIndex = dishes.count
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
