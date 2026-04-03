import SwiftUI

struct MainWorkspaceView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    let repository: BundledDatasetRepository
    let salaryEngine: SalaryTranslationEngine
    let cityEngine: CityComparisonEngine
    @Binding var selectedCanvas: CanvasSection
    @Binding var sessionStartDate: Date
    let onOpenSheet: (RootSheet) -> Void
    @State private var canvasHeights: [CanvasSection: CGFloat] = [:]
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var horizontalPadding: CGFloat { isRegularWidth ? 32 : 20 }
    private var canvasHeightFallback: CGFloat { isRegularWidth ? 900 : 720 }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                SalaryInputCard(
                    scenario: scenario,
                    settings: settings,
                    palette: palette,
                    engine: salaryEngine,
                    onEditAssumptions: { onOpenSheet(.assumptions) }
                )

                assumptionsRow
                previewStrip
                canvasSelector

                TabView(selection: $selectedCanvas) {
                    canvasPage(section: .live) {
                        LiveCanvasView(
                            scenario: scenario,
                            settings: settings,
                            palette: palette,
                            salaryEngine: salaryEngine,
                            sessionStartDate: $sessionStartDate,
                            onShare: { onOpenSheet(.share($0)) }
                        )
                    }
                    .tag(CanvasSection.live)

                    canvasPage(section: .objects) {
                        ObjectsCanvasView(
                            scenario: scenario,
                            settings: settings,
                            palette: palette,
                            repository: repository,
                            salaryEngine: salaryEngine,
                            onShare: { onOpenSheet(.share($0)) }
                        )
                    }
                    .tag(CanvasSection.objects)

                    canvasPage(section: .work) {
                        WorkCanvasView(
                            scenario: scenario,
                            settings: settings,
                            palette: palette,
                            repository: repository,
                            salaryEngine: salaryEngine,
                            onShare: { onOpenSheet(.share($0)) }
                        )
                    }
                    .tag(CanvasSection.work)

                    canvasPage(section: .cities) {
                        CitiesCanvasView(
                            scenario: scenario,
                            settings: settings,
                            palette: palette,
                            repository: repository,
                            cityEngine: cityEngine,
                            salaryEngine: salaryEngine,
                            onShare: { onOpenSheet(.share($0)) }
                        )
                    }
                    .tag(CanvasSection.cities)

                    canvasPage(section: .gap) {
                        GapCanvasView(
                            scenario: scenario,
                            settings: settings,
                            palette: palette,
                            salaryEngine: salaryEngine,
                            sessionStartDate: $sessionStartDate,
                            onShare: { onOpenSheet(.share($0)) }
                        )
                    }
                    .tag(CanvasSection.gap)
                }
                .frame(height: canvasHeights[selectedCanvas] ?? canvasHeightFallback)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .animation(.spring(response: 0.38, dampingFraction: 0.86), value: selectedCanvas)
                .animation(.spring(response: 0.34, dampingFraction: 0.84), value: canvasHeights[selectedCanvas] ?? canvasHeightFallback)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 14)
            .padding(.bottom, 8)
            .frame(maxWidth: isRegularWidth ? 680 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .onPreferenceChange(CanvasHeightPreferenceKey.self) { heights in
            canvasHeights.merge(heights) { _, new in new }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Earnza")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .tracking(-1.2)
                Text(scenario.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
            }

            Spacer()

            HeaderButton(title: L10n.s("header.scenario", "Scenario"), systemName: "square.stack.3d.up", palette: palette) {
                onOpenSheet(.library)
            }
            .accessibilityIdentifier("open_library_button")

            HeaderButton(title: L10n.s("header.share", "Share"), systemName: "square.and.arrow.up", palette: palette) {
                onOpenSheet(.share(defaultShareSnapshot))
            }
            .accessibilityIdentifier("open_share_button")

            HeaderButton(title: L10n.s("header.settings", "Settings"), systemName: "gearshape", palette: palette) {
                onOpenSheet(.settings)
            }
            .accessibilityIdentifier("open_settings_button")
        }
    }

    private var assumptionsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                AssumptionChip(label: L10n.s("assumption.hours", "Hours"), value: EarnzaFormatters.decimal(scenario.workHoursPerWeek, fractionDigits: 0), palette: palette, systemName: "briefcase") {
                    onOpenSheet(.assumptions)
                }
                AssumptionChip(label: L10n.s("assumption.weeks", "Weeks"), value: EarnzaFormatters.decimal(scenario.workWeeksPerYear, fractionDigits: 0), palette: palette, systemName: "calendar") {
                    onOpenSheet(.assumptions)
                }
                AssumptionChip(label: L10n.s("assumption.rent", "Rent"), value: EarnzaFormatters.currency(scenario.monthlyRent, code: scenario.currencyCode, maximumFractionDigits: 0), palette: palette, systemName: "house") {
                    onOpenSheet(.assumptions)
                }
                AssumptionChip(label: L10n.s("assumption.comparator", "Comparator"), value: scenario.comparatorSalary > 0 ? EarnzaFormatters.compactCurrency(scenario.comparatorSalary, code: scenario.currencyCode) : L10n.s("common.off", "Off"), palette: palette, systemName: "person.2") {
                    onOpenSheet(.assumptions)
                }
                AssumptionChip(label: L10n.s("assumption.city", "City"), value: cityName, palette: palette, systemName: "globe") {
                    onOpenSheet(.assumptions)
                }
                AssumptionChip(label: L10n.s("assumption.basis", "Basis"), value: settings.selectedIncomeBasis.title, palette: palette, systemName: "scalemass") {
                    onOpenSheet(.assumptions)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private var previewStrip: some View {
        let pace = salaryEngine.paceSummary(for: scenario, settings: settings)
        let columnCount = isRegularWidth ? 4 : 2

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columnCount), spacing: 10) {
            compactPaceCard(title: L10n.s("pace.per_month", "Per Month"), value: pace.monthly)
            compactPaceCard(title: L10n.s("pace.per_day", "Per Day"), value: pace.daily)
            compactPaceCard(title: L10n.s("pace.per_hour", "Per Hour"), value: pace.hourly)
            compactPaceCard(title: L10n.s("pace.per_minute", "Per Minute"), value: pace.minute)
        }
    }

    private var canvasSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CanvasSection.allCases) { section in
                    Button {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                            selectedCanvas = section
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: section.symbolName)
                            Text(section.title)
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(section == selectedCanvas ? palette.textPrimary : palette.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(section == selectedCanvas ? palette.cardFill.opacity(1.25) : .clear)
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(section == selectedCanvas ? palette.accent.opacity(0.5) : palette.divider, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func compactPaceCard(title: String, value: Double) -> some View {
        GlassCard(palette: palette, padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
                Text(EarnzaFormatters.currency(value, code: scenario.currencyCode, maximumFractionDigits: value < 10 ? 2 : 0))
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(palette.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var cityName: String {
        repository.cities.first(where: { $0.id == scenario.cityID })?.cityName ?? L10n.s("common.unset", "Unset")
    }

    private var defaultShareSnapshot: ShareSnapshot {
        let pace = salaryEngine.paceSummary(for: scenario, settings: settings)
        return ShareSnapshot(
            title: L10n.s("salary_input.title", "Your salary, translated."),
            value: EarnzaFormatters.currency(pace.minute, code: scenario.currencyCode),
            subtitle: L10n.s("share.default.subtitle", "You earn this much per minute."),
            details: [
                L10n.f("share.default.hourly_pace", "Hourly pace: %@", EarnzaFormatters.currency(pace.hourly, code: scenario.currencyCode)),
                L10n.f("share.default.monthly_pace", "Monthly pace: %@", EarnzaFormatters.currency(pace.monthly, code: scenario.currencyCode, maximumFractionDigits: 0)),
                L10n.f("share.default.assumptions", "Based on %@ hrs/week and %@ weeks/year", scenario.workHoursPerWeek.formatted(), scenario.workWeeksPerYear.formatted())
            ],
            symbolName: "waveform.path.ecg",
            theme: scenario.selectedTheme
        )
    }

    private func canvasPage<Content: View>(section: CanvasSection, @ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: CanvasHeightPreferenceKey.self,
                        value: [section: proxy.size.height]
                    )
                }
            )
    }
}

private struct HeaderButton: View {
    let title: String
    let systemName: String
    let palette: ThemePalette
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(palette.cardFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(palette.divider, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

private struct CanvasHeightPreferenceKey: PreferenceKey {
    static let defaultValue: [CanvasSection: CGFloat] = [:]

    static func reduce(value: inout [CanvasSection: CGFloat], nextValue: () -> [CanvasSection: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct AssumptionsEditorView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    private let repository = BundledDatasetRepository()

    var body: some View {
        BottomSheetEditor(title: L10n.s("assumptions.title", "Assumptions"), palette: palette) {
            GroupBox {
                VStack(alignment: .leading, spacing: 14) {
                    Picker(L10n.s("settings.income_basis", "Income basis"), selection: $settings.selectedIncomeBasis) {
                        ForEach(IncomeBasis.allCases) { basis in
                            Text(basis.title).tag(basis)
                        }
                    }
                    .pickerStyle(.segmented)

                    if settings.selectedIncomeBasis == .takeHome {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.s("assumptions.manual_take_home_annual", "Manual take-home annual"))
                                .font(.system(size: 13, weight: .semibold))
                            TextField("0", value: $scenario.manualTakeHomeAnnual, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    }
                }
            } label: {
                Text(L10n.s("assumptions.calculation_basis", "Calculation Basis"))
            }

            GroupBox {
                VStack(spacing: 14) {
                    labeledStepper(title: L10n.s("assumptions.hours_per_week", "Hours per week"), value: $scenario.workHoursPerWeek, in: 10...80, step: 1)
                    labeledStepper(title: L10n.s("assumptions.weeks_per_year", "Weeks per year"), value: $scenario.workWeeksPerYear, in: 20...52, step: 1)
                    Stepper(L10n.f("assumptions.paychecks_per_year", "Paychecks per year: %@", "\(scenario.paychecksPerYear)"), value: $scenario.paychecksPerYear, in: 1...52)
                }
            } label: {
                Text(L10n.s("assumptions.work_schedule", "Work Schedule"))
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    TextField(L10n.s("assumptions.monthly_rent", "Monthly rent"), value: $scenario.monthlyRent, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)

                    TextField(L10n.s("assumptions.comparator_salary", "Comparator annual salary"), value: $scenario.comparatorSalary, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)

                    TextField(L10n.s("assumptions.comparator_label", "Comparator label"), text: $scenario.comparatorLabel)
                        .textFieldStyle(.roundedBorder)

                    Picker(L10n.s("assumptions.home_city", "Home city"), selection: $scenario.cityID) {
                        ForEach(repository.cities) { city in
                            Text(city.cityName).tag(city.id)
                        }
                    }
                }
            } label: {
                Text(L10n.s("assumptions.lifestyle_inputs", "Lifestyle Inputs"))
            }
        }
    }

    private func labeledStepper(title: String, value: Binding<Double>, in range: ClosedRange<Double>, step: Double) -> some View {
        Stepper {
            Text("\(title): \(EarnzaFormatters.decimal(value.wrappedValue, fractionDigits: 0))")
        } onIncrement: {
            value.wrappedValue = min(range.upperBound, value.wrappedValue + step)
        } onDecrement: {
            value.wrappedValue = max(range.lowerBound, value.wrappedValue - step)
        }
    }
}
