import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmReset = false
    @State private var document: AppDocument?

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

                PurchaseSettingsSection()

                Section("About") {
                    LabeledContent("Version", value: AppInfo.version)
                    ForEach(AppDocument.allCases) { item in
                        Button {
                            document = item
                        } label: {
                            HStack {
                                Text(item.title).foregroundStyle(Palette.ink)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Palette.inkSoft)
                            }
                        }
                        .accessibilityIdentifier("document-\(item.rawValue.lowercased())")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onChange(of: model.progress.hapticsEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.soundEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.musicEnabled) { _, _ in model.saveProgress() }
        .sheet(item: $document) { item in
            AppDocumentView(document: item)
                .preferredColorScheme(.light)
        }
        .confirmationDialog("Reset all stars, snacks, and recipes?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { model.resetProgress() }
            Button("Cancel", role: .cancel) {}
        }
    }
}
