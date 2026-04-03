import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    @AppStorage(AppLanguage.storageKey) private var selectedAppLanguageRaw = AppLanguage.system.rawValue
    let repository: BundledDatasetRepository
    let palette: ThemePalette

    var body: some View {
        BottomSheetEditor(title: L10n.s("settings.title", "Settings"), palette: palette) {
            settingsSection(L10n.s("settings.appearance", "Appearance")) {
                settingsRow {
                    Text(L10n.s("settings.theme", "Theme"))
                    Spacer()
                    Picker(L10n.s("settings.theme", "Theme"), selection: $settings.selectedTheme) {
                        ForEach(ThemeStyle.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                    .labelsHidden()
                    .tint(palette.accent)
                }
                rowDivider
                settingsToggle(L10n.s("settings.reduce_motion", "Reduce motion"), isOn: $settings.reduceMotionOverride)
                rowDivider
                settingsToggle(L10n.s("settings.haptics", "Haptics"), isOn: $settings.hapticsEnabled)
                rowDivider
                settingsToggle(L10n.s("settings.high_contrast", "High contrast"), isOn: $settings.highContrastEnabled)
            }

            settingsSection(L10n.s("settings.defaults", "Defaults")) {
                settingsRow {
                    Text(L10n.s("settings.language", "Language"))
                    Spacer()
                    Picker(L10n.s("settings.language", "Language"), selection: selectedAppLanguageBinding) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.title).tag(language)
                        }
                    }
                    .labelsHidden()
                    .tint(palette.accent)
                }
                rowDivider
                settingsRow {
                    Text(L10n.s("settings.default_currency", "Default currency"))
                    Spacer()
                    Picker(L10n.s("settings.default_currency", "Default currency"), selection: $settings.defaultCurrencyCode) {
                        ForEach(["USD", "EUR", "GBP", "JPY", "PLN", "AED", "SGD", "AUD", "CAD", "THB", "RUB"], id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                    .labelsHidden()
                    .tint(palette.accent)
                }
                rowDivider
                settingsRow {
                    Text(L10n.s("settings.income_basis", "Income basis"))
                    Spacer()
                    Picker(L10n.s("settings.income_basis", "Income basis"), selection: $settings.selectedIncomeBasis) {
                        ForEach(IncomeBasis.allCases) { basis in
                            Text(basis.title).tag(basis)
                        }
                    }
                    .labelsHidden()
                    .tint(palette.accent)
                }
            }

            settingsSection(L10n.s("settings.dataset_info", "Dataset Info")) {
                infoRow(label: L10n.s("settings.version", "Version"), value: settings.datasetVersion)
                rowDivider
                infoRow(label: L10n.s("settings.cities_bundled", "Cities bundled"), value: "\(repository.cities.count)")
                rowDivider
                infoRow(label: L10n.s("settings.objects_bundled", "Objects bundled"), value: "\(repository.objectCatalog.count + settings.customObjects.count)")
                rowDivider
                Text(L10n.s("settings.dataset_note", "City stretch and item prices are local static references. They clarify assumptions instead of pretending absolute economic truth."))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.top, 4)
            }

            settingsSection(L10n.s("settings.privacy", "Privacy")) {
                Text(L10n.s("settings.privacy_note", "Earnza works fully offline. No account, no tracking, no remote dependency for the core product."))
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

    private var selectedAppLanguageBinding: Binding<AppLanguage> {
        Binding(
            get: { AppLanguage(rawValue: selectedAppLanguageRaw) ?? .system },
            set: { selectedAppLanguageRaw = $0.rawValue }
        )
    }
}
