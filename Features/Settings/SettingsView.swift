import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let repository: BundledDatasetRepository
    let palette: ThemePalette

    var body: some View {
        BottomSheetEditor(title: "Settings", palette: palette) {
            settingsSection("Appearance") {
                settingsRow {
                    Text("Theme")
                    Spacer()
                    Picker("Theme", selection: $settings.selectedTheme) {
                        ForEach(ThemeStyle.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                    .labelsHidden()
                    .tint(palette.accent)
                }
                rowDivider
                settingsToggle("Reduce motion", isOn: $settings.reduceMotionOverride)
                rowDivider
                settingsToggle("Haptics", isOn: $settings.hapticsEnabled)
                rowDivider
                settingsToggle("High contrast", isOn: $settings.highContrastEnabled)
            }

            settingsSection("Defaults") {
                settingsRow {
                    Text("Default currency")
                    Spacer()
                    Picker("Default currency", selection: $settings.defaultCurrencyCode) {
                        ForEach(["USD", "EUR", "GBP", "JPY", "PLN", "AED", "SGD", "AUD", "CAD", "THB", "RUB"], id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                    .labelsHidden()
                    .tint(palette.accent)
                }
                rowDivider
                settingsRow {
                    Text("Income basis")
                    Spacer()
                    Picker("Income basis", selection: $settings.selectedIncomeBasis) {
                        ForEach(IncomeBasis.allCases) { basis in
                            Text(basis.title).tag(basis)
                        }
                    }
                    .labelsHidden()
                    .tint(palette.accent)
                }
            }

            settingsSection("Dataset Info") {
                infoRow(label: "Version", value: settings.datasetVersion)
                rowDivider
                infoRow(label: "Cities bundled", value: "\(repository.cities.count)")
                rowDivider
                infoRow(label: "Objects bundled", value: "\(repository.objectCatalog.count + settings.customObjects.count)")
                rowDivider
                Text("City stretch and item prices are local static references. They clarify assumptions instead of pretending absolute economic truth.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.top, 4)
            }

            settingsSection("Privacy") {
                Text("Earnza works fully offline. No account, no tracking, no remote dependency for the core product.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
            }
        }
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(palette.divider)
            .frame(height: 1)
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(palette.textSecondary)
                .tracking(0.5)
            GlassCard(palette: palette, padding: 0) {
                VStack(spacing: 0) {
                    content()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 4)
            }
        }
    }

    private func settingsRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            content()
        }
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(palette.textPrimary)
        .padding(.vertical, 12)
    }

    private func settingsToggle(_ label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(palette.accent)
        }
        .padding(.vertical, 12)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(palette.textSecondary)
        }
        .padding(.vertical, 12)
    }
}
