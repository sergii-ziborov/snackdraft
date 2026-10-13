import SwiftUI

@main
struct SnackdraftApp: App {
    @State private var model = AppModel()
    @State private var purchases = PurchaseStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .environment(purchases)
                .preferredColorScheme(model.screen == .play || model.screen == .result ? .dark : .light)
                .task { await purchases.start() }
        }
    }
}

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            switch model.screen {
            case .home:
                HomeView()
            case .play:
                PlayView()
            case .result:
                ResultView()
            case .worlds:
                WorldsView()
            case .collection:
                CollectionView()
            case .settings:
                SettingsView()
            }
        }
        .id(screenKey)
        .transition(.opacity.combined(with: .scale(scale: 0.985)))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(screenBackground.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.22), value: screenKey)
        .tint(Palette.moss)
    }

    private var screenBackground: Color {
        switch model.screen {
        case .play, .result: Palette.navy
        default: Palette.cream
        }
    }

    private var screenKey: String {
        switch model.screen {
        case .home: "home"
        case .play: "play"
        case .result: "result"
        case .worlds: "worlds"
        case .collection: "collection"
        case .settings: "settings"
        }
    }
}
