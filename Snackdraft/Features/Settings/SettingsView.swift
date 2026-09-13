import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmReset = false

    var body: some View {
        @Bindable var model = model
        PageShell(title: "Settings", onBack: { model.screen = .home }) {
            List {
                Section("Feel") {
                    Toggle("Haptics", isOn: $model.progress.hapticsEnabled)
                    Toggle("Sound cues", isOn: $model.progress.soundEnabled)
                    Toggle("Ambient kitchen music", isOn: $model.progress.musicEnabled)
                    Text("Each kitchen has its own soft tonal atmosphere. Sound cues mark picks, placements, recipes, combos, and unlocks.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Section("Progress") {
                    LabeledContent("Stars", value: "\(model.progress.totalStars)")
                    LabeledContent("Snacks found", value: "\(model.progress.seenSnacks.count)/\(SnackID.allCases.count)")
                    LabeledContent("Recipes plated", value: "\(model.progress.discoveredRecipes.count)/\(RecipeBook.all.count)")
                    Button("Reset progress", role: .destructive) {
                        confirmReset = true
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    Text("Nine kitchens now share a growing pantry. Connect every ingredient in a dish by an edge, then serve immediately — or keep building the tray for extra combos and the feast bonus.")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onChange(of: model.progress.hapticsEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.soundEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.musicEnabled) { _, _ in model.saveProgress() }
        .confirmationDialog("Reset all stars, snacks, and recipes?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { model.resetProgress() }
            Button("Cancel", role: .cancel) {}
        }
    }
}
