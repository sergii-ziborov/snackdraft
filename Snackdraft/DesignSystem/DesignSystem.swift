import SwiftUI

struct ScreenBackground: View {
    var image: String
    var dim: Double = 0.35
    var opacity: Double = 1

    var body: some View {
        GeometryReader { geo in
            Image(image)
                .resizable()
                .scaledToFill()
                .opacity(opacity)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .overlay(Color.black.opacity(dim))
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

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

extension SnackID {
    var accent: Color {
        switch self {
        case .strawberry: Color(red: 0.91, green: 0.22, blue: 0.32)
        case .cookie: Color(red: 0.72, green: 0.42, blue: 0.18)
        case .pancake: Color(red: 0.95, green: 0.68, blue: 0.18)
        case .tea: Color(red: 0.18, green: 0.64, blue: 0.34)
        case .onigiri: Color(red: 0.95, green: 0.93, blue: 0.90)
        case .salmon: Color(red: 0.96, green: 0.42, blue: 0.24)
        case .cheese: Color(red: 0.98, green: 0.78, blue: 0.16)
        case .leaf: Color(red: 0.32, green: 0.72, blue: 0.26)
        case .blueberry: Color(red: 0.28, green: 0.32, blue: 0.78)
        case .mochi: Color(red: 0.96, green: 0.62, blue: 0.78)
        case .tamago: Color(red: 0.96, green: 0.78, blue: 0.28)
        case .shrimp: Color(red: 0.96, green: 0.48, blue: 0.32)
        case .tomato: Color(red: 0.90, green: 0.22, blue: 0.22)
        case .avocado: Color(red: 0.42, green: 0.72, blue: 0.22)
        case .bacon: Color(red: 0.72, green: 0.28, blue: 0.22)
        case .soySauce: Color(red: 0.38, green: 0.20, blue: 0.10)
        case .lime: Color(red: 0.48, green: 0.78, blue: 0.16)
        case .coconut: Color(red: 0.75, green: 0.58, blue: 0.38)
        case .hummus: Color(red: 0.86, green: 0.68, blue: 0.34)
        case .pita: Color(red: 0.82, green: 0.56, blue: 0.28)
        case .pasta: Color(red: 0.94, green: 0.66, blue: 0.20)
        case .tortilla: Color(red: 0.92, green: 0.68, blue: 0.28)
        case .beans: Color(red: 0.34, green: 0.16, blue: 0.15)
        case .chili: Color(red: 0.94, green: 0.18, blue: 0.16)
        case .mango: Color(red: 0.98, green: 0.62, blue: 0.12)
        case .curry: Color(red: 0.90, green: 0.52, blue: 0.12)
        case .naan: Color(red: 0.84, green: 0.58, blue: 0.30)
        case .garlic: Color(red: 0.90, green: 0.84, blue: 0.64)
        case .mushroom: Color(red: 0.62, green: 0.38, blue: 0.25)
        case .corn: Color(red: 0.98, green: 0.76, blue: 0.12)
        case .yogurt: Color(red: 0.82, green: 0.88, blue: 0.96)
        case .olive: Color(red: 0.42, green: 0.44, blue: 0.16)
        case .ginger: Color(red: 0.90, green: 0.58, blue: 0.22)
        }
    }
}

extension ComboKind {
    var tint: Color {
        switch self {
        case .berryBoost: Color(red: 0.93, green: 0.25, blue: 0.40)
        case .teaPairing: Color(red: 0.20, green: 0.70, blue: 0.42)
        case .bentoPair: Color(red: 0.96, green: 0.45, blue: 0.18)
        case .garnish: Color(red: 0.40, green: 0.78, blue: 0.28)
        case .umamiDrizzle: Color(red: 0.72, green: 0.42, blue: 0.20)
        case .limeLift: Color(red: 0.62, green: 0.88, blue: 0.18)
        case .mezzePair: Color(red: 0.94, green: 0.66, blue: 0.28)
        case .pastaPair: Color(red: 0.94, green: 0.36, blue: 0.24)
        case .tacoBase: Color(red: 0.12, green: 0.66, blue: 0.60)
        case .chiliSpark: Color(red: 0.96, green: 0.18, blue: 0.14)
        case .spicePair: Color(red: 0.94, green: 0.56, blue: 0.12)
        case .mangoCooler: Color(red: 0.98, green: 0.68, blue: 0.12)
        case .garlicAroma: Color(red: 0.92, green: 0.78, blue: 0.42)
        case .cornCrunch: Color(red: 0.98, green: 0.72, blue: 0.10)
        case .creamyCool: Color(red: 0.52, green: 0.78, blue: 0.96)
        case .oliveGarden: Color(red: 0.55, green: 0.64, blue: 0.20)
        case .gingerZing: Color(red: 0.96, green: 0.48, blue: 0.16)
        case .sweetLine: Color(red: 0.90, green: 0.42, blue: 0.78)
        case .colorVariety: Color(red: 0.38, green: 0.52, blue: 0.98)
        case .fullTray: Palette.gold
        }
    }
}

struct SDButton: View {
    enum Kind { case play, success, quiet, gold }

    var title: String
    var kind: Kind = .play
    var icon: String? = nil
    var compact: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.sdBody(compact ? 16 : 18))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, compact ? 12 : 16)
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
            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

struct PageShell<Content: View>: View {
    var title: String
    var onBack: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ScreenHeader(title: title, back: onBack)
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .background(Palette.cream)
        }
        .background(Palette.cream.ignoresSafeArea())
    }
}
