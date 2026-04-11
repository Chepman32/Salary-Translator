import SwiftData
import SwiftUI

enum RootSheet: Identifiable {
    case assumptions
    case settings
    case library
    case share(ShareSnapshot)

    var id: String {
        switch self {
        case .assumptions: "assumptions"
        case .settings: "settings"
        case .library: "library"
        case .share(let snapshot): "share-\(snapshot.id)"
        }
    }
}

struct EarnzaRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppLanguage.storageKey) private var selectedAppLanguageRaw = AppLanguage.system.rawValue

    @Query(sort: \Scenario.updatedAt, order: .reverse)
    private var scenarios: [Scenario]

    @Query
    private var settingsRecords: [AppSettings]

    @State private var selectedCanvas: CanvasSection = .live
    @State private var activeSheet: RootSheet?
    @State private var sessionStartDate = Date()
    @State private var splashFinished = false
    @State private var didBootstrap = false

    private let repository = BundledDatasetRepository()
    private let salaryEngine = DefaultSalaryTranslationEngine()
    private let cityEngine = DefaultCityComparisonEngine()

    var body: some View {
        Group {
            if let settings = settingsRecords.first {
                let activeScenario = resolvedScenario(using: settings)
                let palette = EarnzaTheme.palette(for: settings.selectedTheme)
                let appLocale = Locale(identifier: selectedAppLanguage.localeIdentifier ?? Locale.current.identifier)

                ZStack {
                    EarnzaBackground(palette: palette)

                    if splashFinished {
                        if let activeScenario {
                            if settings.hasCompletedOnboarding {
                                MainWorkspaceView(
                                    scenario: activeScenario,
                                    settings: settings,
                                    palette: palette,
                                    repository: repository,
                                    salaryEngine: salaryEngine,
                                    cityEngine: cityEngine,
                                    selectedCanvas: $selectedCanvas,
                                    sessionStartDate: $sessionStartDate,
                                    onOpenSheet: { activeSheet = $0 }
                                )
                            } else {
                                OnboardingFlowView(palette: palette) {
                                    settings.hasCompletedOnboarding = true
                                    activeScenario.touch()
                                }
                            }
                        } else {
                            ProgressView()
                                .tint(palette.accent)
                        }
                    } else {
                        SplashExperienceView(palette: palette)
                            .transition(.opacity.combined(with: .scale(scale: 1.02)))
                    }
                }
                .overlay(alignment: .top) {
                    LinearGradient(
                        stops: [
                            .init(color: palette.backgroundTop, location: 0),
                            .init(color: palette.backgroundTop, location: 0.6),
                            .init(color: palette.backgroundTop.opacity(0), location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 110)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
                }
                .environment(\.locale, appLocale)
                .preferredColorScheme(settings.selectedTheme.colorScheme)
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                    case .assumptions:
                        if let activeScenario {
                            AssumptionsEditorView(scenario: activeScenario, settings: settings, palette: palette)
                        }
                    case .settings:
                        SettingsView(settings: settings, repository: repository, palette: palette)
                            .presentationDetents([.large])
                    case .library:
                        LibraryView(
                            scenarios: scenarios,
                            settings: settings,
                            palette: palette,
                            onSelect: { selected in
                                settings.selectedScenarioID = selected.id
                                activeSheet = nil
                            }
                        )
                    case .share(let snapshot):
                        ShareStudioView(snapshot: snapshot, palette: palette)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task {
            bootstrapIfNeeded()
            triggerSplash()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                sessionStartDate = .now
            }
        }
    }

    private func bootstrapIfNeeded() {
        guard !didBootstrap else { return }
        didBootstrap = true

        let preferredCurrencyCode = CurrencyCatalog.preferredCode(for: appLocale)
        let settings: AppSettings

        if settingsRecords.isEmpty {
            let settingsRecord = AppSettings(defaultCurrencyCode: preferredCurrencyCode)
            modelContext.insert(settingsRecord)
            settings = settingsRecord
        } else {
            settings = settingsRecords[0]
        }

        if shouldAdoptDetectedCurrency(for: settings, preferredCurrencyCode: preferredCurrencyCode) {
            settings.defaultCurrencyCode = preferredCurrencyCode
        }

        if scenarios.isEmpty {
            let scenario = Scenario.starter(currencyCode: preferredCurrencyCode, fxRates: repository.fxRates)
            modelContext.insert(scenario)
            settings.selectedScenarioID = scenario.id
        } else {
            migrateSeededScenarioCurrencyIfNeeded(preferredCurrencyCode: preferredCurrencyCode)
            if settings.selectedScenarioID.isEmpty {
                settings.selectedScenarioID = scenarios.first?.id ?? ""
            }
        }
    }

    private func migrateSeededScenarioCurrencyIfNeeded(preferredCurrencyCode: String) {
        guard preferredCurrencyCode != "USD" else { return }
        guard let seededScenario = scenarios.first(where: isLegacyStarterScenario) else { return }

        let migrated = Scenario.starter(currencyCode: preferredCurrencyCode, fxRates: repository.fxRates)
        seededScenario.currencyCode = migrated.currencyCode
        seededScenario.salaryAmount = migrated.salaryAmount
        seededScenario.monthlyRent = migrated.monthlyRent
        seededScenario.comparatorSalary = migrated.comparatorSalary
        seededScenario.touch()
    }

    private func shouldAdoptDetectedCurrency(for settings: AppSettings, preferredCurrencyCode: String) -> Bool {
        guard preferredCurrencyCode != "USD", settings.defaultCurrencyCode == "USD" else { return false }
        return !settings.hasCompletedOnboarding || scenarios.contains(where: isLegacyStarterScenario)
    }

    private func isLegacyStarterScenario(_ scenario: Scenario) -> Bool {
        scenario.currencyCode == "USD"
            && scenario.cityID == "new-york-us"
            && scenario.payPeriodMode == .annual
            && scenario.workHoursPerWeek == 40
            && scenario.workWeeksPerYear == 48
            && scenario.paychecksPerYear == 24
            && scenario.monthlyRent == 2_400
            && scenario.salaryAmount == 98_000
            && scenario.comparatorSalary == 162_000
            && scenario.manualTakeHomeAnnual == 0
            && !scenario.isArchived
    }

    private var appLocale: Locale {
        Locale(identifier: selectedAppLanguage.localeIdentifier ?? Locale.current.identifier)
    }

    private var selectedAppLanguage: AppLanguage {
        AppLanguage(rawValue: selectedAppLanguageRaw) ?? .system
    }

    private func triggerSplash() {
        guard !splashFinished else { return }
        let arguments = ProcessInfo.processInfo.arguments
        let delay: Double
        if arguments.contains("-skip-splash") {
            delay = 0.01
        } else {
            delay = settingsRecords.first?.reduceMotionOverride == true ? 0.35 : 1.45
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(delay))
            withAnimation(.spring(response: 0.55, dampingFraction: 0.84)) {
                splashFinished = true
            }
        }
    }

    private func resolvedScenario(using settings: AppSettings) -> Scenario? {
        let visible = scenarios.filter { !$0.isArchived }
        if let match = visible.first(where: { $0.id == settings.selectedScenarioID }) {
            return match
        }
        return visible.first
    }

}

private struct SplashExperienceView: View {
    let palette: ThemePalette
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            EarnzaBackground(palette: palette)

            VStack(spacing: 20) {
                ZStack {
                    ForEach(Array(0..<36), id: \.self) { index in
                        fragment(index: index)
                    }

                    Text("Earnza")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundStyle(palette.textPrimary)
                        .tracking(-2)
                        .scaleEffect(1 + phase * 0.04)
                }

                Text(L10n.s("app.tagline", "Turn salary into something you can actually feel."))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }

    private func fragment(index: Int) -> some View {
        let angle = Double(index) / 36 * Double.pi * 2
        let x = CGFloat(cos(angle)) * (26 + phase * 62)
        let y = CGFloat(sin(angle)) * (18 + phase * 38)
        let rotation = Angle.degrees(Double(index) * 11)
        let fill = index.isMultiple(of: 2) ? palette.accent : palette.accentSecondary

        return RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(fill)
            .frame(width: 4, height: 22)
            .offset(x: x, y: y)
            .rotationEffect(rotation)
            .opacity(Double(1 - phase * 0.6))
    }
}
