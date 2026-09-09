import SwiftUI

@main
struct SnackdraftApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
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
        .animation(.easeInOut(duration: 0.22), value: screenKey)
        .tint(Palette.moss)
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
