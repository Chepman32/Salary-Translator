import SwiftUI

struct GlassCard<Content: View>: View {
    let palette: ThemePalette
    let padding: CGFloat
    @ViewBuilder var content: Content

    init(palette: ThemePalette, padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.palette = palette
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(palette.cardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(palette.divider, lineWidth: 1)
                    )
                    .shadow(color: palette.shadow, radius: 18, x: 0, y: 12)
            )
    }
}

struct SectionTitle: View {
    let title: String
    let subtitle: String?
    let palette: ThemePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundStyle(palette.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MoneyCounterView: View {
    let value: Double
    let currencyCode: String
    let fontSize: CGFloat
    let weight: Font.Weight
    let palette: ThemePalette
    var useMonospaced: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(PayloFormatters.currency(value, code: currencyCode, maximumFractionDigits: value < 10 ? 2 : 0))
            .font(.system(size: fontSize, weight: weight, design: .default))
            .fontDesign(.rounded)
            .monospacedDigit()
            .kerning(-0.8)
            .foregroundStyle(palette.textPrimary)
            .contentTransition(reduceMotion ? .opacity : .numericText(value: value))
            .animation(.spring(response: 0.35, dampingFraction: 0.86), value: value)
            .accessibilityLabel("Value")
            .accessibilityValue(PayloFormatters.currency(value, code: currencyCode))
    }
}

struct AssumptionChip: View {
    let label: String
    let value: String
    let palette: ThemePalette
    let systemName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                Text(value)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(palette.cardFill)
                    .overlay(Capsule(style: .continuous).stroke(palette.divider, lineWidth: 1))
            )
            .foregroundStyle(palette.textPrimary)
        }
        .buttonStyle(.plain)
    }
}

struct RatioBar: View {
    let progress: Double
    let palette: ThemePalette

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(palette.divider.opacity(0.36))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [palette.accent, palette.accentSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(12, proxy.size.width * min(max(progress, 0), 1)))
            }
        }
        .frame(height: 10)
    }
}

struct TickerBand: View {
    let items: [String]
    let palette: ThemePalette
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { proxy in
            let content = HStack(spacing: 18) {
                ForEach(0..<2, id: \.self) { _ in
                    HStack(spacing: 18) {
                        ForEach(items, id: \.self) { item in
                            Text(item)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(palette.textPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(palette.cardFill)
                                        .overlay(Capsule(style: .continuous).stroke(palette.divider, lineWidth: 1))
                                )
                        }
                    }
                }
            }

            content
                .frame(width: proxy.size.width * 2.4, alignment: .leading)
                .offset(x: isAnimating ? -proxy.size.width * 1.2 : 0)
                .onAppear {
                    withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                        isAnimating = true
                    }
                }
        }
        .frame(height: 42)
        .clipped()
    }
}

struct InsightCard: View {
    let palette: ThemePalette
    let title: String
    let value: String
    let subtitle: String
    let symbolName: String
    var shareSnapshot: ShareSnapshot?
    var onShare: ((ShareSnapshot) -> Void)?

    var body: some View {
        GlassCard(palette: palette, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: symbolName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(palette.accent)
                    Spacer()
                    Circle()
                        .fill(palette.accent.opacity(0.22))
                        .frame(width: 10, height: 10)
                }

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)

                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(palette.textPrimary)
                    .minimumScaleFactor(0.75)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contextMenu {
            if let shareSnapshot, let onShare {
                Button("Share Card", systemImage: "square.and.arrow.up") {
                    onShare(shareSnapshot)
                }
            }
        }
    }
}

struct CityRankRow: View {
    let rank: Int
    let insight: CityInsight
    let currencyCode: String
    let palette: ThemePalette
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(insight.city.cityName)
                                .font(.system(size: 17, weight: .semibold))
                            Text(insight.city.countryName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(palette.textSecondary)
                        }
                        Spacer()
                        Text(PayloFormatters.currency(insight.dailyPower, code: currencyCode, maximumFractionDigits: 0))
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    }

                    RatioBar(progress: insight.affordabilityBar, palette: palette)
                        .frame(height: 10)

                    HStack {
                        Text(insight.comparisonBlurb)
                        Spacer()
                        Text("\(PayloFormatters.decimal(insight.bigMacsPerHour, fractionDigits: 1))/hr burgers")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(palette.cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(palette.divider, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct ComparatorPanel: View {
    let yourValue: Double
    let comparatorValue: Double
    let currencyCode: String
    let label: String
    let ratio: Double
    let palette: ThemePalette

    var body: some View {
        GlassCard(palette: palette) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Label("While you read this", systemImage: "text.viewfinder")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Text("\(PayloFormatters.decimal(ratio, fractionDigits: 1))x")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundStyle(palette.textPrimary)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("You")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(palette.textSecondary)
                        MoneyCounterView(value: yourValue, currencyCode: currencyCode, fontSize: 28, weight: .bold, palette: palette)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()
                        .overlay(palette.divider)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(palette.textSecondary)
                        MoneyCounterView(value: comparatorValue, currencyCode: currencyCode, fontSize: 28, weight: .bold, palette: palette)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                RatioBar(progress: min(ratio / 4, 1), palette: palette)
            }
        }
    }
}

struct BottomSheetEditor<Content: View>: View {
    let title: String
    let palette: ThemePalette
    @ViewBuilder var content: Content

    init(title: String, palette: ThemePalette, @ViewBuilder content: () -> Content) {
        self.title = title
        self.palette = palette
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    content
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .background(PayloBackground(palette: palette))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium, .large])
    }
}

struct SalaryInputCard: View {
    @Bindable var scenario: Scenario
    let settings: AppSettings
    let palette: ThemePalette
    let engine: SalaryTranslationEngine
    let onEditAssumptions: () -> Void

    @State private var draftValue = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        GlassCard(palette: palette) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Your salary, translated.")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    Menu {
                        Picker("Currency", selection: $scenario.currencyCode) {
                            ForEach(["USD", "EUR", "GBP", "JPY", "PLN", "AED", "SGD", "AUD", "CAD", "THB"], id: \.self) { code in
                                Text(code).tag(code)
                            }
                        }
                    } label: {
                        Label(scenario.currencyCode, systemImage: "banknote")
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Capsule(style: .continuous).fill(palette.cardFill))
                    }
                }

                Picker("Input mode", selection: $scenario.payPeriodMode) {
                    ForEach(SalaryInputMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 10) {
                    TextField("0", text: $draftValue)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(palette.textPrimary)
                        .onAppear { syncDraft() }
                        .onChange(of: scenario.payPeriodModeRaw) { _, _ in syncDraft() }
                        .onChange(of: scenario.salaryAmount) { _, _ in
                            if !isFocused { syncDraft() }
                        }
                        .onChange(of: draftValue) { _, newValue in
                            guard let parsed = Self.parseAmount(newValue) else { return }
                            scenario.salaryAmount = max(
                                0,
                                engine.annualAmount(
                                    from: parsed,
                                    mode: scenario.payPeriodMode,
                                    workHoursPerWeek: scenario.workHoursPerWeek,
                                    workWeeksPerYear: scenario.workWeeksPerYear
                                )
                            )
                            scenario.touch()
                        }
                        .accessibilityIdentifier("salary_input_field")

                    Text("Based on \(scenario.payPeriodMode.title.lowercased()) input and saved work assumptions.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }

                Slider(
                    value: Binding(
                        get: { engine.displayAmount(for: scenario) },
                        set: { newValue in
                            scenario.salaryAmount = engine.annualAmount(
                                from: newValue,
                                mode: scenario.payPeriodMode,
                                workHoursPerWeek: scenario.workHoursPerWeek,
                                workWeeksPerYear: scenario.workWeeksPerYear
                            )
                            scenario.touch()
                            syncDraft()
                        }
                    ),
                    in: sliderRange
                )
                .tint(palette.accent)

                HStack(spacing: 10) {
                    ForEach(quickPresets, id: \.self) { preset in
                        Button {
                            scenario.salaryAmount = preset
                            scenario.payPeriodMode = .annual
                            scenario.touch()
                            syncDraft()
                        } label: {
                            Text(PayloFormatters.compactCurrency(preset, code: scenario.currencyCode))
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(palette.cardFill)
                                        .overlay(Capsule(style: .continuous).stroke(palette.divider, lineWidth: 1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button(action: onEditAssumptions) {
                    HStack {
                        Text("Edit assumptions")
                        Spacer()
                        Image(systemName: "slider.horizontal.3")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                    .padding(.top, 2)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var sliderRange: ClosedRange<Double> {
        switch scenario.payPeriodMode {
        case .annual: 20_000...500_000
        case .monthly: 1_500...40_000
        case .weekly: 500...12_000
        case .hourly: 10...300
        }
    }

    private var quickPresets: [Double] {
        [30_000, 50_000, 75_000, 100_000, 150_000]
    }

    private func syncDraft() {
        draftValue = PayloFormatters.decimal(engine.displayAmount(for: scenario), fractionDigits: scenario.payPeriodMode == .hourly ? 2 : 0)
    }

    private static func parseAmount(_ value: String) -> Double? {
        let sanitized = value
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
        return Double(sanitized)
    }
}
