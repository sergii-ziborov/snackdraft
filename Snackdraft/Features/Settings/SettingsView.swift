import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmReset = false

    var body: some View {
        @Bindable var model = model
        ZStack {
            Palette.cream.ignoresSafeArea()
            VStack(spacing: 0) {
                ScreenHeader(title: "Settings") { model.screen = .home }

                List {
                    Section("Feel") {
                        Toggle("Haptics", isOn: $model.progress.hapticsEnabled)
                        Toggle("Sound cues", isOn: $model.progress.soundEnabled)
                    }

                    Section("Progress") {
                        LabeledContent("Stars", value: "\(model.progress.totalStars)")
                        LabeledContent("Snacks found", value: "\(model.progress.seenSnacks.count)/\(SnackID.allCases.count)")
                        Button("Reset progress", role: .destructive) {
                            confirmReset = true
                        }
                    }

                    Section("About") {
                        LabeledContent("Version", value: "1.0.0")
                        Text("Snackdraft is a cozy placement game. Each turn you pick one of three snacks and set it on a 4×4 tray. Combos are shown before you place. Sixteen placements, then the tray scores.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .onChange(of: model.progress.hapticsEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.soundEnabled) { _, _ in model.saveProgress() }
        .confirmationDialog("Reset all stars and collection?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { model.resetProgress() }
            Button("Cancel", role: .cancel) {}
        }
    }
}
