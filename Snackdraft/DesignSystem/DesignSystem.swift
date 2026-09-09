import SwiftUI

enum Palette {
    static let cream = Color(red: 0.980, green: 0.925, blue: 0.870)
    static let creamDark = Color(red: 0.94, green: 0.88, blue: 0.80)
    static let ink = Color(red: 0.145, green: 0.106, blue: 0.086)
    static let inkSoft = Color(red: 0.32, green: 0.24, blue: 0.18)
    static let wood = Color(red: 0.62, green: 0.40, blue: 0.22)
    static let woodDark = Color(red: 0.42, green: 0.26, blue: 0.14)
    static let moss = Color(red: 0.22, green: 0.72, blue: 0.48)
    static let mossPressed = Color(red: 0.16, green: 0.58, blue: 0.38)
    static let gold = Color(red: 0.95, green: 0.76, blue: 0.28)
    static let navy = Color(red: 0.07, green: 0.12, blue: 0.18)
    static let navyCard = Color(red: 0.10, green: 0.16, blue: 0.24)
    static let coral = Color(red: 0.91, green: 0.45, blue: 0.38)
}

extension Font {
    static func sdDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func sdBody(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func sdScript(_ size: CGFloat) -> Font {
        .system(size: size, design: .serif).italic()
    }
}

struct SDButton: View {
    enum Kind { case play, success, quiet, gold }

    var title: String
    var kind: Kind = .play
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.sdBody(18))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(background, in: Capsule())
            .shadow(color: .black.opacity(0.14), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var background: Color {
        switch kind {
        case .play: Palette.moss
        case .success: Palette.moss
        case .quiet: Color.white.opacity(0.92)
        case .gold: Palette.gold
        }
    }

    private var foreground: Color {
        switch kind {
        case .quiet: Palette.ink
        case .gold: Palette.ink
        default: .white
        }
    }
}

struct FeaturePill: View {
    var icon: String
    var title: String
    var subtitle: String
    var tint: Color
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 4 : 6) {
            ZStack {
                Circle().fill(tint.opacity(0.18)).frame(width: compact ? 42 : 52, height: compact ? 42 : 52)
                Image(systemName: icon)
                    .font(.system(size: compact ? 16 : 20, weight: .semibold))
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(.sdBody(12))
                .foregroundStyle(Palette.ink)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StarRow: View {
    var stars: Int
    var size: CGFloat = 22

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(index < stars ? Palette.gold : Palette.ink.opacity(0.18))
            }
        }
        .accessibilityLabel("\(stars) of 3 stars")
    }
}

struct ScreenHeader: View {
    var title: String
    var light: Bool = false
    var back: () -> Void

    var body: some View {
        HStack {
            Button(action: back) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(light ? Color.white : Palette.ink)
            }
            .accessibilityIdentifier("back-button")
            Spacer()
            Text(title)
                .font(.sdDisplay(22))
                .foregroundStyle(light ? Color.white : Palette.ink)
            Spacer()
            Color.clear.frame(width: 18)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
