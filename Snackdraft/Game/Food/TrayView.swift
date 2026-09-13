import SwiftUI

struct CellFramesKey: PreferenceKey {
    static let defaultValue: [Cell: CGRect] = [:]
    static func reduce(value: inout [Cell: CGRect], nextValue: () -> [Cell: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct SnackArt: View {
    var snack: SnackID
    var bounce: Bool = false
    var popping: Bool = false

    var body: some View {
        Image(snack.assetName)
            .resizable()
            .scaledToFill()
            .scaleEffect(1.58)
            .clipShape(Circle())
            .overlay {
                Circle().strokeBorder(Color.white.opacity(0.22), lineWidth: 0.8)
            }
            .scaleEffect((bounce ? 1.10 : 1) * (popping ? 1.16 : 1))
            .shadow(color: snack.accent.opacity(bounce ? 0.55 : 0.22), radius: bounce ? 10 : 4, y: bounce ? 4 : 2)
            .accessibilityLabel(snack.displayName)
    }
}

struct DishArt: View {
    var recipe: DishRecipe

    var body: some View {
        Group {
            if let assetName = recipe.assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                GeometryReader { geo in
                    let side = min(geo.size.width, geo.size.height)
                    ZStack {
                        LinearGradient(
                            colors: [recipe.world.tint.opacity(0.28), Palette.cream, Color.white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .frame(width: side * 0.76, height: side * 0.76)
                            .shadow(color: .black.opacity(0.10), radius: side * 0.05, y: side * 0.025)
                        HStack(spacing: -side * 0.09) {
                            ForEach(Array(recipe.ingredients.prefix(3).enumerated()), id: \.offset) { index, snack in
                                SnackArt(snack: snack)
                                    .frame(width: side * 0.37, height: side * 0.37)
                                    .rotationEffect(.degrees(Double(index - 1) * 7))
                                    .zIndex(Double(index))
                            }
                        }
                    }
                }
            }
        }
        .clipped()
        .accessibilityLabel(recipe.name)
    }
}

extension WorldID {
    var tint: Color {
        switch self {
        case .tea: Palette.moss
        case .bento: Palette.coral
        case .thai: Color(red: 0.42, green: 0.78, blue: 0.22)
        case .israeli: Color(red: 0.18, green: 0.58, blue: 0.86)
        case .italian: Color(red: 0.84, green: 0.22, blue: 0.20)
        case .garden: Color(red: 0.68, green: 0.38, blue: 0.82)
        case .kitchen: Palette.gold
        case .mexican: Color(red: 0.08, green: 0.68, blue: 0.62)
        case .indian: Color(red: 0.92, green: 0.48, blue: 0.12)
        }
    }
}

struct SparkleBurst: View {
    var color: Color
    @State private var flown = false

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: flown ? 3 : 7, height: flown ? 3 : 7)
                    .offset(y: flown ? -26 : 0)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .opacity(flown ? 0 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) { flown = true }
        }
        .allowsHitTesting(false)
    }
}

struct TrayGrid: View {
    var board: Board
    var selected: SnackID?
    var tipCell: Cell?
    var hoverCell: Cell? = nil
    var lastPlaced: Cell? = nil
    var highlight: Set<Cell> = []
    var highlightColor: Color = Palette.gold
    var interactive: Bool = true
    var compact: Bool = false
    var previewBonus: ((Cell) -> Int?)? = nil
    var onPlace: ((Cell) -> Void)?

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                GeometryReader { geo in
                    trayBody(side: geo.size.width)
                }
            }
    }

    private func trayBody(side: CGFloat) -> some View {
        let gap: CGFloat = compact ? 5 : 8
        let inset: CGFloat = compact ? 10 : 14
        let inner = side - inset * 2
        let cell = max(8, (inner - gap * 3) / 4)

        return ZStack {
            RoundedRectangle(cornerRadius: compact ? 18 : 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.78, green: 0.52, blue: 0.28),
                            Color(red: 0.46, green: 0.26, blue: 0.12),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: compact ? 18 : 26, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.95, green: 0.78, blue: 0.48),
                                    Color(red: 0.32, green: 0.16, blue: 0.06),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                }
                .shadow(color: .black.opacity(0.35), radius: 16, y: 8)

            VStack(spacing: gap) {
                ForEach(0..<Board.size, id: \.self) { row in
                    HStack(spacing: gap) {
                        ForEach(0..<Board.size, id: \.self) { col in
                            trayCell(Cell(row: row, col: col), size: cell)
                        }
                    }
                }
            }
            .padding(inset)
        }
        .frame(width: side, height: side)
    }

    @ViewBuilder
    private func trayCell(_ cell: Cell, size: CGFloat) -> some View {
        let snack = board[cell]
        let bonus = previewBonus?(cell)
        let isTip = tipCell == cell
        let isHover = hoverCell == cell
        let isHot = highlight.contains(cell)
        let popping = lastPlaced == cell
        let canPlace = interactive && selected != nil && snack == nil
        let glow = isHot ? highlightColor : (isHover || isTip ? Palette.moss : (bonus ?? 0) > 0 ? Palette.gold : Color.clear)

        Button {
            if canPlace { onPlace?(cell) }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.42, green: 0.24, blue: 0.12).opacity(0.92),
                                Color(red: 0.28, green: 0.15, blue: 0.07).opacity(0.95),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                            .stroke(glow.opacity(isHot || isHover || isTip ? 1 : ((bonus ?? 0) > 0 ? 0.7 : 0.18)), lineWidth: isHot || isHover ? 3 : 1.2)
                    }
                    .shadow(color: glow.opacity(isHot || isHover ? 0.7 : 0), radius: 8)

                if let snack {
                    SnackArt(snack: snack, bounce: isHot, popping: popping)
                        .padding(size * 0.08)
                        .transition(.scale(scale: 0.35).combined(with: .opacity))
                        .phaseAnimator([false, true]) { view, up in
                            view.offset(y: isHot ? 0 : (up ? -1.5 : 1.5))
                        } animation: { _ in
                            .easeInOut(duration: 1.6 + Double(cell.index) * 0.04)
                        }
                    if popping {
                        SparkleBurst(color: snack.accent)
                    }
                } else if let selected, canPlace {
                    Circle()
                        .fill(selected.accent.opacity(isHover ? 0.35 : 0.12))
                        .padding(size * 0.18)
                    SnackArt(snack: selected)
                        .padding(size * 0.22)
                        .opacity(isHover ? 0.85 : 0.28)
                }

                if let bonus, bonus > 0, snack == nil {
                    Text("+\(bonus)")
                        .font(.sdBody(max(11, size * 0.20)))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(selected?.accent ?? Palette.moss, in: Capsule())
                        .shadow(color: .black.opacity(0.35), radius: 3, y: 1)
                        .offset(y: size * 0.34)
                }
            }
            .frame(width: size, height: size)
            .animation(.spring(duration: 0.42, bounce: 0.28), value: snack)
            .scaleEffect(isHover ? 1.05 : 1)
            .animation(.spring(duration: 0.22, bounce: 0.28), value: isHover)
            .animation(.spring(duration: 0.28, bounce: 0.35), value: popping)
        }
        .buttonStyle(.plain)
        .disabled(!canPlace)
        .background {
            GeometryReader { geo in
                Color.clear.preference(
                    key: CellFramesKey.self,
                    value: [cell: geo.frame(in: .named("play"))]
                )
            }
        }
        .accessibilityIdentifier("cell-\(cell.row)-\(cell.col)")
        .accessibilityLabel(snack?.displayName ?? "Empty cell \(cell.row + 1), \(cell.col + 1)")
    }
}
