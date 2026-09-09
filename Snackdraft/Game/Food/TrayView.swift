import SwiftUI

struct SnackArt: View {
    var snack: SnackID
    var bounce: Bool = false

    var body: some View {
        Image(snack.assetName)
            .resizable()
            .scaledToFit()
            .scaleEffect(bounce ? 1.08 : 1)
            .shadow(color: .black.opacity(0.12), radius: bounce ? 8 : 2, y: bounce ? 4 : 1)
            .accessibilityLabel(snack.displayName)
    }
}

struct TrayGrid: View {
    var board: Board
    var selected: SnackID?
    var tipCell: Cell?
    var highlight: Set<Cell> = []
    var interactive: Bool = true
    var compact: Bool = false
    var previewBonus: ((Cell) -> Int?)? = nil
    var onPlace: ((Cell) -> Void)?

    var body: some View {
        GeometryReader { geo in
            let gap: CGFloat = compact ? 6 : 8
            let inset: CGFloat = compact ? 10 : 14
            let inner = geo.size.width - inset * 2
            let cell = max(8, (inner - gap * 3) / 4)

            ZStack {
                RoundedRectangle(cornerRadius: compact ? 18 : 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.72, green: 0.50, blue: 0.28),
                                Color(red: 0.50, green: 0.32, blue: 0.16),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: compact ? 18 : 26, style: .continuous)
                            .stroke(Color(red: 0.36, green: 0.22, blue: 0.10).opacity(0.7), lineWidth: 3)
                    }
                    .shadow(color: .black.opacity(0.28), radius: 16, y: 8)

                VStack(spacing: gap) {
                    ForEach(0..<Board.size, id: \.self) { row in
                        HStack(spacing: gap) {
                            ForEach(0..<Board.size, id: \.self) { col in
                                let cellPos = Cell(row: row, col: col)
                                trayCell(cellPos, size: cell)
                            }
                        }
                    }
                }
                .padding(inset)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func trayCell(_ cell: Cell, size: CGFloat) -> some View {
        let snack = board[cell]
        let bonus = previewBonus?(cell)
        let isTip = tipCell == cell
        let isHot = highlight.contains(cell)
        let canPlace = interactive && selected != nil && snack == nil

        Button {
            if canPlace {
                onPlace?(cell)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .fill(Color(red: 0.86, green: 0.70, blue: 0.48).opacity(snack == nil ? 0.55 : 0.92))
                    .overlay {
                        RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                            .stroke(
                                isHot ? Palette.gold :
                                    isTip ? Palette.moss :
                                    (canPlace ? Color.white.opacity(0.55) : Color.black.opacity(0.12)),
                                lineWidth: isHot || isTip ? 3 : 1
                            )
                    }

                if let snack {
                    SnackArt(snack: snack, bounce: isHot)
                        .padding(size * 0.04)
                } else if let selected, canPlace {
                    SnackArt(snack: selected)
                        .padding(size * 0.10)
                        .opacity(0.22)
                }

                if let bonus, bonus > 0, snack == nil {
                    Text("+\(bonus)")
                        .font(.sdBody(size * 0.22))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Palette.moss, in: Capsule())
                        .offset(y: size * 0.32)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .disabled(!canPlace)
        .accessibilityIdentifier("cell-\(cell.row)-\(cell.col)")
        .accessibilityLabel(snack?.displayName ?? "Empty cell \(cell.row + 1), \(cell.col + 1)")
    }
}
