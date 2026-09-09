import SwiftUI

struct CollectionView: View {
    @Environment(AppModel.self) private var model
    @State private var tab: Tab = .recipes
    @State private var selected: SnackID?

    enum Tab: String, CaseIterable {
        case snacks = "Snacks"
        case recipes = "Recipes"
    }

    var body: some View {
        ZStack {
            Palette.cream.ignoresSafeArea()
            VStack(spacing: 0) {
                ScreenHeader(title: "Recipes") { model.screen = .home }

                Picker("Section", selection: $tab) {
                    ForEach(Tab.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    Group {
                        switch tab {
                        case .snacks: snackGrid
                        case .recipes: recipeList
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .sheet(item: $selected) { snack in
            snackDetail(snack)
                .presentationDetents([.medium])
        }
    }

    private var snackGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 12)], spacing: 12) {
            ForEach(SnackID.allCases) { snack in
                let seen = model.progress.hasSeen(snack)
                Button {
                    selected = snack
                } label: {
                    VStack(spacing: 6) {
                        SnackArt(snack: snack)
                            .frame(height: 72)
                            .opacity(seen ? 1 : 0.35)
                            .overlay {
                                if !seen {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(Palette.inkSoft)
                                }
                            }
                        Text(seen ? snack.displayName : "???")
                            .font(.sdBody(12))
                            .foregroundStyle(Palette.ink)
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("snack-\(snack.rawValue)")
            }
        }
    }

    private var recipeList: some View {
        VStack(spacing: 10) {
            ForEach(ComboKind.allCases) { kind in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: kind.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Palette.moss)
                        .frame(width: 28, height: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(kind.title)
                                .font(.sdBody(16))
                                .foregroundStyle(Palette.ink)
                            Spacer()
                            Text(kind.pointsLabel)
                                .font(.sdBody(13))
                                .foregroundStyle(Palette.wood)
                        }
                        Text(kind.rule)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Palette.inkSoft)
                    }
                }
                .padding(14)
                .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            Text("Bonuses light up on empty cells before you place. If a cell looks tasty, it is.")
                .font(.sdScript(16))
                .foregroundStyle(Palette.inkSoft)
                .padding(.top, 8)
        }
    }

    private func snackDetail(_ snack: SnackID) -> some View {
        let seen = model.progress.hasSeen(snack)
        return VStack(spacing: 14) {
            SnackArt(snack: snack)
                .frame(height: 140)
            Text(seen ? snack.displayName : "Still in the pantry")
                .font(.sdDisplay(26))
            Text(seen ? snack.comboHint : "Place this snack on a tray to learn its habit.")
                .font(.sdBody(16))
                .foregroundStyle(Palette.wood)
                .multilineTextAlignment(.center)
            if seen {
                Text(snack.blurb)
                    .font(.sdScript(18))
                    .foregroundStyle(Palette.inkSoft)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(24)
        .background(Palette.cream)
    }
}
