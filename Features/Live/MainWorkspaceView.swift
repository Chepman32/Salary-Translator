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

    var body: some View {
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
                LiveCanvasView(
                    scenario: scenario,
                    settings: settings,
                    palette: palette,
                    salaryEngine: salaryEngine,
                    sessionStartDate: $sessionStartDate,
                    onShare: { onOpenSheet(.share($0)) }
                )
                .tag(CanvasSection.live)

                ObjectsCanvasView(
                    scenario: scenario,
                    settings: settings,
                    palette: palette,
                    repository: repository,
                    salaryEngine: salaryEngine,
                    onShare: { onOpenSheet(.share($0)) }
                )
                .tag(CanvasSection.objects)

                WorkCanvasView(
                    scenario: scenario,
                    settings: settings,
                    palette: palette,
                    repository: repository,
                    salaryEngine: salaryEngine,
                    onShare: { onOpenSheet(.share($0)) }
                )
                .tag(CanvasSection.work)

                CitiesCanvasView(
                    scenario: scenario,
                    settings: settings,
                    palette: palette,
                    repository: repository,
                    cityEngine: cityEngine,
                    salaryEngine: salaryEngine,
                    onShare: { onOpenSheet(.share($0)) }
                )
                .tag(CanvasSection.cities)

                GapCanvasView(
                    scenario: scenario,
                    settings: settings,
                    palette: palette,
                    salaryEngine: salaryEngine,
                    sessionStartDate: $sessionStartDate,
                    onShare: { onOpenSheet(.share($0)) }
                )
                .tag(CanvasSection.gap)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            .animation(.spring(response: 0.38, dampingFraction: 0.86), value: selectedCanvas)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Paylo")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .tracking(-1.2)
                Text(scenario.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
            }

            Spacer()

            HeaderButton(title: "Scenario", systemName: "square.stack.3d.up", palette: palette) {
                onOpenSheet(.library)
            }
            .accessibilityIdentifier("open_library_button")

            HeaderButton(title: "Share", systemName: "square.and.arrow.up", palette: palette) {
                onOpenSheet(.share(defaultShareSnapshot))
            }
            .accessibilityIdentifier("open_share_button")

            HeaderButton(title: "Settings", systemName: "gearshape", palette: palette) {
                onOpenSheet(.settings)
            }
            .accessibilityIdentifier("open_settings_button")
        }
    }

    private var assumptionsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                AssumptionChip(label: "Hours", value: PayloFormatters.decimal(scenario.workHoursPerWeek, fractionDigits: 0), palette: palette, systemName: "briefcase") {
                    onOpenSheet(.assumptions)
                }
                AssumptionChip(label: "Weeks", value: PayloFormatters.decimal(scenario.workWeeksPerYear, fractionDigits: 0), palette: palette, systemName: "calendar") {
                    onOpenSheet(.assumptions)
                }
                AssumptionChip(label: "Rent", value: PayloFormatters.currency(scenario.monthlyRent, code: scenario.currencyCode, maximumFractionDigits: 0), palette: palette, systemName: "house") {
                    onOpenSheet(.assumptions)
                }
                AssumptionChip(label: "Comparator", value: scenario.comparatorSalary > 0 ? PayloFormatters.compactCurrency(scenario.comparatorSalary, code: scenario.currencyCode) : "Off", palette: palette, systemName: "person.2") {
                    onOpenSheet(.assumptions)
                }
                AssumptionChip(label: "City", value: cityName, palette: palette, systemName: "globe") {
                    onOpenSheet(.assumptions)
                }
                AssumptionChip(label: "Basis", value: settings.selectedIncomeBasis.title, palette: palette, systemName: "scalemass") {
                    onOpenSheet(.assumptions)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private var previewStrip: some View {
        let pace = salaryEngine.paceSummary(for: scenario, settings: settings)

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
            compactPaceCard(title: "Per Month", value: pace.monthly)
            compactPaceCard(title: "Per Day", value: pace.daily)
            compactPaceCard(title: "Per Hour", value: pace.hourly)
            compactPaceCard(title: "Per Minute", value: pace.minute)
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
                Text(PayloFormatters.currency(value, code: scenario.currencyCode, maximumFractionDigits: value < 10 ? 2 : 0))
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(palette.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var cityName: String {
        repository.cities.first(where: { $0.id == scenario.cityID })?.cityName ?? "Unset"
    }

    private var defaultShareSnapshot: ShareSnapshot {
        let pace = salaryEngine.paceSummary(for: scenario, settings: settings)
        return ShareSnapshot(
            title: "Your salary, translated.",
            value: PayloFormatters.currency(pace.minute, code: scenario.currencyCode),
            subtitle: "You earn this much per minute.",
            details: [
                "Hourly pace: \(PayloFormatters.currency(pace.hourly, code: scenario.currencyCode))",
                "Monthly pace: \(PayloFormatters.currency(pace.monthly, code: scenario.currencyCode, maximumFractionDigits: 0))",
                "Based on \(scenario.workHoursPerWeek.formatted()) hrs/week and \(scenario.workWeeksPerYear.formatted()) weeks/year"
            ],
            symbolName: "waveform.path.ecg",
            theme: scenario.selectedTheme
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

struct AssumptionsEditorView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    private let repository = BundledDatasetRepository()

    var body: some View {
        BottomSheetEditor(title: "Assumptions", palette: palette) {
            GroupBox("Calculation Basis") {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("Income basis", selection: $settings.selectedIncomeBasis) {
                        ForEach(IncomeBasis.allCases) { basis in
                            Text(basis.title).tag(basis)
                        }
                    }
                    .pickerStyle(.segmented)

                    if settings.selectedIncomeBasis == .takeHome {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Manual take-home annual")
                                .font(.system(size: 13, weight: .semibold))
                            TextField("0", value: $scenario.manualTakeHomeAnnual, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    }
                }
            }

            GroupBox("Work Schedule") {
                VStack(spacing: 14) {
                    labeledStepper(title: "Hours per week", value: $scenario.workHoursPerWeek, in: 10...80, step: 1)
                    labeledStepper(title: "Weeks per year", value: $scenario.workWeeksPerYear, in: 20...52, step: 1)
                    Stepper("Paychecks per year: \(scenario.paychecksPerYear)", value: $scenario.paychecksPerYear, in: 1...52)
                }
            }

            GroupBox("Lifestyle Inputs") {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Monthly rent", value: $scenario.monthlyRent, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)

                    TextField("Comparator annual salary", value: $scenario.comparatorSalary, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)

                    TextField("Comparator label", text: $scenario.comparatorLabel)
                        .textFieldStyle(.roundedBorder)

                    Picker("Home city", selection: $scenario.cityID) {
                        ForEach(repository.cities) { city in
                            Text(city.cityName).tag(city.id)
                        }
                    }
                }
            }
        }
    }

    private func labeledStepper(title: String, value: Binding<Double>, in range: ClosedRange<Double>, step: Double) -> some View {
        Stepper {
            Text("\(title): \(PayloFormatters.decimal(value.wrappedValue, fractionDigits: 0))")
        } onIncrement: {
            value.wrappedValue = min(range.upperBound, value.wrappedValue + step)
        } onDecrement: {
            value.wrappedValue = max(range.lowerBound, value.wrappedValue - step)
        }
    }
}
