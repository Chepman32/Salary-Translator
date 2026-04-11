import Foundation
import SwiftUI
import UIKit

enum CustomObjectImageStore {
    private static let directoryName = "CustomObjectImages"

    static func saveImageData(_ data: Data, id: String) throws -> String {
        guard let normalizedData = normalizedSquareImageData(from: data) else {
            throw CocoaError(.coderReadCorrupt)
        }

        let fileName = "\(id).png"
        let url = try directoryURL().appendingPathComponent(fileName, isDirectory: false)
        try normalizedData.write(to: url, options: .atomic)
        return fileName
    }

    static func image(named fileName: String?) -> UIImage? {
        guard let fileName, let url = try? directoryURL().appendingPathComponent(fileName, isDirectory: false) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }

    private static func directoryURL() throws -> URL {
        let fileManager = FileManager.default
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        let directoryURL = baseURL.appendingPathComponent(directoryName, isDirectory: true)

        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }

        return directoryURL
    }

    private static func normalizedSquareImageData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        let targetSize = CGSize(width: 512, height: 512)
        let scale = max(targetSize.width / image.size.width, targetSize.height / image.size.height)
        let drawSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let drawOrigin = CGPoint(
            x: (targetSize.width - drawSize.width) / 2,
            y: (targetSize.height - drawSize.height) / 2
        )

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.pngData { _ in
            image.draw(in: CGRect(origin: drawOrigin, size: drawSize))
        }
    }
}

struct ObjectIconView: View {
    let symbolName: String
    let customImageFileName: String?
    let palette: ThemePalette
    var size: CGFloat = 26

    var body: some View {
        ZStack {
            if let uiImage = CustomObjectImageStore.image(named: customImageFileName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                    .fill(palette.accent.opacity(0.14))

                Image(systemName: symbolName)
                    .font(.system(size: size * 0.58, weight: .semibold))
                    .foregroundStyle(palette.accent)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .stroke(palette.divider, lineWidth: 1)
        )
    }
}

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
        Text(EarnzaFormatters.currency(value, code: currencyCode, maximumFractionDigits: value < 10 ? 2 : 0))
            .font(.system(size: fontSize, weight: weight, design: .default))
            .fontDesign(.rounded)
            .monospacedDigit()
            .kerning(-0.8)
            .foregroundStyle(palette.textPrimary)
            .contentTransition(reduceMotion ? .opacity : .numericText(value: value))
            .animation(.spring(response: 0.35, dampingFraction: 0.86), value: value)
            .accessibilityLabel(L10n.s("common.value", "Value"))
            .accessibilityValue(EarnzaFormatters.currency(value, code: currencyCode))
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
                Button(L10n.s("common.share_card", "Share Card"), systemImage: "square.and.arrow.up") {
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
                        Text(EarnzaFormatters.currency(insight.dailyPower, code: currencyCode, maximumFractionDigits: 0))
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    }

                    RatioBar(progress: insight.affordabilityBar, palette: palette)
                        .frame(height: 10)

                    HStack {
                        Text(insight.comparisonBlurb)
                        Spacer()
                        Text(L10n.f("cities.burgers_per_hour", "%@/hr burgers", EarnzaFormatters.decimal(insight.bigMacsPerHour, fractionDigits: 1)))
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
                    Label(L10n.s("live.while_you_read_this", "While you read this"), systemImage: "text.viewfinder")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Text("\(EarnzaFormatters.decimal(ratio, fractionDigits: 1))x")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundStyle(palette.textPrimary)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(L10n.s("common.you", "You"))
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
    @State private var selectedDetent: PresentationDetent = .large

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
            .background(EarnzaBackground(palette: palette))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium, .large], selection: $selectedDetent)
    }
}

struct SalaryInputCard: View {
    @Environment(\.locale) private var locale
    @Bindable var scenario: Scenario
    let settings: AppSettings
    let palette: ThemePalette
    let engine: SalaryTranslationEngine
    let onEditAssumptions: () -> Void

    @State private var draftValue = ""
    @State private var sliderValue = 0.0
    @State private var suppressedDraftValue: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        GlassCard(palette: palette) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text(L10n.s("salary_input.title", "Your salary, translated."))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)
                    Spacer()
                    Menu {
                        Picker(L10n.s("salary_input.currency", "Currency"), selection: $scenario.currencyCode) {
                            ForEach(CurrencyCatalog.orderedCodes(for: locale), id: \.self) { code in
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

                Picker(L10n.s("salary_input.input_mode", "Input mode"), selection: inputModeBinding) {
                    ForEach(SalaryInputMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("salary_input_mode_picker")

                VStack(alignment: .leading, spacing: 10) {
                    TextField("0", text: $draftValue)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(palette.textPrimary)
                        .onAppear { syncDisplayState() }
                        .onChange(of: scenario.payPeriodModeRaw) { _, _ in syncDisplayState() }
                        .onChange(of: scenario.salaryAmount) { _, _ in
                            if !isFocused { syncDisplayState() }
                        }
                        .onChange(of: scenario.workHoursPerWeek) { _, _ in syncIfNeeded() }
                        .onChange(of: scenario.workWeeksPerYear) { _, _ in syncIfNeeded() }
                        .onChange(of: draftValue) { _, newValue in
                            if suppressedDraftValue == newValue {
                                suppressedDraftValue = nil
                                return
                            }
                            guard let parsed = Self.parseAmount(newValue) else { return }
                            applyDisplayedAmount(parsed, updateDraft: false)
                        }
                        .accessibilityIdentifier("salary_input_field")

                    Text(L10n.f("salary_input.based_on", "Based on %@ input and saved work assumptions.", scenario.payPeriodMode.title.lowercased()))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }

                Slider(
                    value: Binding(
                        get: { sliderValue },
                        set: { newValue in
                            applyDisplayedAmount(newValue, updateDraft: true)
                        }
                    ),
                    in: sliderRange
                )
                .tint(palette.accent)

                Button(action: onEditAssumptions) {
                    HStack {
                        Text(L10n.s("salary_input.edit_assumptions", "Edit assumptions"))
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
        switch scenario.payPeriodMode {
        case .hourly:
            [10, 15, 20, 25, 30]
        default:
            annualQuickPresetSeeds.map(displayAmount(forAnnualPreset:))
        }
    }

    private var inputModeBinding: Binding<SalaryInputMode> {
        Binding(
            get: { scenario.payPeriodMode },
            set: { newMode in
                guard scenario.payPeriodMode != newMode else { return }
                isFocused = false
                scenario.payPeriodMode = newMode
                scenario.touch()
                syncDisplayState()
            }
        )
    }

    private func syncIfNeeded() {
        if !isFocused {
            syncDisplayState()
        }
    }

    private func syncDisplayState() {
        let displayedAmount = max(0, engine.displayAmount(for: scenario))
        sliderValue = clampedSliderValue(for: displayedAmount)
        updateDraftValue(displayedAmount)
    }

    private func displayAmount(forAnnualPreset annualAmount: Double) -> Double {
        switch scenario.payPeriodMode {
        case .annual:
            annualAmount
        case .monthly:
            annualAmount / 12
        case .weekly:
            annualAmount / max(scenario.workWeeksPerYear, 1)
        case .hourly:
            annualAmount / max(scenario.workHoursPerWeek * scenario.workWeeksPerYear, 1)
        }
    }

    private func applyDisplayedAmount(_ displayedAmount: Double, updateDraft: Bool) {
        let normalizedAmount = max(0, displayedAmount)
        sliderValue = clampedSliderValue(for: normalizedAmount)
        scenario.salaryAmount = max(
            0,
            engine.annualAmount(
                from: normalizedAmount,
                mode: scenario.payPeriodMode,
                workHoursPerWeek: scenario.workHoursPerWeek,
                workWeeksPerYear: scenario.workWeeksPerYear
            )
        )
        scenario.touch()
        if updateDraft {
            updateDraftValue(normalizedAmount)
        }
    }

    private func updateDraftValue(_ amount: Double) {
        let formatted = EarnzaFormatters.decimal(
            amount,
            fractionDigits: scenario.payPeriodMode == .hourly ? 2 : 0
        )
        suppressedDraftValue = formatted
        draftValue = formatted
    }

    private func clampedSliderValue(for amount: Double) -> Double {
        min(max(amount, sliderRange.lowerBound), sliderRange.upperBound)
    }

    private func quickPresetLabel(for displayedAmount: Double) -> String {
        EarnzaFormatters.compactCurrency(displayedAmount, code: scenario.currencyCode)
    }

    private var annualQuickPresetSeeds: [Double] {
        [30_000, 50_000, 75_000, 100_000, 150_000]
    }

    private static func parseAmount(_ value: String) -> Double? {
        let sanitized = value
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
        return Double(sanitized)
    }
}
