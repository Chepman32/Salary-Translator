import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let repository: BundledDatasetRepository
    let palette: ThemePalette

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $settings.selectedTheme) {
                        ForEach(ThemeStyle.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }

                    Toggle("Reduce motion", isOn: $settings.reduceMotionOverride)
                    Toggle("Haptics", isOn: $settings.hapticsEnabled)
                    Toggle("High contrast", isOn: $settings.highContrastEnabled)
                }

                Section("Defaults") {
                    Picker("Default currency", selection: $settings.defaultCurrencyCode) {
                        ForEach(["USD", "EUR", "GBP", "JPY", "PLN", "AED", "SGD", "AUD", "CAD", "THB"], id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }

                    Picker("Income basis", selection: $settings.selectedIncomeBasis) {
                        ForEach(IncomeBasis.allCases) { basis in
                            Text(basis.title).tag(basis)
                        }
                    }
                }

                Section("Dataset Info") {
                    LabeledContent("Version", value: settings.datasetVersion)
                    LabeledContent("Cities bundled", value: "\(repository.cities.count)")
                    LabeledContent("Objects bundled", value: "\(repository.objectCatalog.count + settings.customObjects.count)")

                    Text("City stretch and item prices are local static references. They clarify assumptions instead of pretending absolute economic truth.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Section("Privacy") {
                    Text("Earnza works fully offline. No account, no tracking, no remote dependency for the core product.")
                        .font(.system(size: 13, weight: .medium))
                }
            }
            .scrollContentBackground(.hidden)
            .background(EarnzaBackground(palette: palette))
            .navigationTitle("Settings")
        }
        .presentationDetents([.medium, .large])
    }
}
