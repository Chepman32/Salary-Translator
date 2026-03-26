import SwiftUI

struct LiveCanvasView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    let salaryEngine: SalaryTranslationEngine
    @Binding var sessionStartDate: Date
    let onShare: (ShareSnapshot) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(
                title: "Watch income turn visible.",
                subtitle: "Continuous pace, reading-session accumulation, and shareable milestone moments.",
                palette: palette
            )

            TimelineView(.animation(minimumInterval: 0.1)) { timeline in
                let elapsed = timeline.date.timeIntervalSince(sessionStartDate)
                let accumulated = salaryEngine.accumulatedValue(for: scenario, settings: settings, elapsed: elapsed)
                let pace = salaryEngine.paceSummary(for: scenario, settings: settings)

                GlassCard(palette: palette, padding: 22) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("You are earning now")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(palette.textSecondary)

                        MoneyCounterView(
                            value: accumulated,
                            currencyCode: scenario.currencyCode,
                            fontSize: 46,
                            weight: .black,
                            palette: palette
                        )

                        Text("While you read this, the number keeps resolving in real time.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(palette.textSecondary)

                        RatioBar(progress: min(accumulated / max(pace.hourly, 1), 1), palette: palette)

                        HStack {
                            Text("Minute pace")
                            Spacer()
                            Text(PayloFormatters.currency(pace.minute, code: scenario.currencyCode))
                                .monospacedDigit()
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)
                    }
                }
                .onLongPressGesture {
                    onShare(
                        ShareSnapshot(
                            title: "While you read this",
                            value: PayloFormatters.currency(accumulated, code: scenario.currencyCode),
                            subtitle: "Screen-session accumulation",
                            details: [
                                "Per minute: \(PayloFormatters.currency(pace.minute, code: scenario.currencyCode))",
                                "Per hour: \(PayloFormatters.currency(pace.hourly, code: scenario.currencyCode))",
                                "Scenario: \(scenario.name)"
                            ],
                            symbolName: "timer",
                            theme: scenario.selectedTheme
                        )
                    )
                }
            }

            TickerBand(items: tickerItems, palette: palette)

            let pace = salaryEngine.paceSummary(for: scenario, settings: settings)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                insightCard(title: "Per Second", value: PayloFormatters.currency(pace.second, code: scenario.currencyCode), subtitle: "Continuous rate for live accumulation", symbol: "hare", paceValue: pace.second)
                insightCard(title: "Per Minute", value: PayloFormatters.currency(pace.minute, code: scenario.currencyCode), subtitle: "The clearest real-time heartbeat", symbol: "clock", paceValue: pace.minute)
                insightCard(title: "Per Workday", value: PayloFormatters.currency(pace.daily, code: scenario.currencyCode), subtitle: "Saved work assumption applied", symbol: "briefcase", paceValue: pace.daily)
                insightCard(title: "Per Paycheck", value: PayloFormatters.currency(pace.paycheck, code: scenario.currencyCode), subtitle: "Based on paychecks per year", symbol: "creditcard", paceValue: pace.paycheck)
                insightCard(title: "Per Month", value: PayloFormatters.currency(pace.monthly, code: scenario.currencyCode, maximumFractionDigits: 0), subtitle: "Salary spread over 12 months", symbol: "calendar", paceValue: pace.monthly)
                insightCard(title: "Reading Session", value: sessionInsightValue, subtitle: "Resets when the app becomes active again", symbol: "book.pages", paceValue: pace.minute)
            }

            GlassCard(palette: palette) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Milestones")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)

                    ForEach(milestones, id: \.self) { milestone in
                        HStack {
                            Text(milestone)
                            Spacer()
                            Image(systemName: "bolt")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 30)
    }

    private var tickerItems: [String] {
        let pace = salaryEngine.paceSummary(for: scenario, settings: settings)
        return [
            "Minute pace \(PayloFormatters.currency(pace.minute, code: scenario.currencyCode))",
            "Coffee in \(PayloFormatters.decimal(4.8 / max(pace.hourly, 0.01) * 60, fractionDigits: 1)) min",
            "Paycheck \(PayloFormatters.currency(pace.paycheck, code: scenario.currencyCode, maximumFractionDigits: 0))",
            "Hourly \(PayloFormatters.currency(pace.hourly, code: scenario.currencyCode))",
            "Rent day every \(PayloFormatters.decimal(max(scenario.monthlyRent / 30, 1) / max(pace.hourly, 0.01), fractionDigits: 1)) hrs"
        ]
    }

    private func insightCard(title: String, value: String, subtitle: String, symbol: String, paceValue: Double) -> some View {
        InsightCard(
            palette: palette,
            title: title,
            value: value,
            subtitle: subtitle,
            symbolName: symbol,
            shareSnapshot: ShareSnapshot(
                title: title,
                value: value,
                subtitle: subtitle,
                details: [
                    "Scenario: \(scenario.name)",
                    "Currency: \(scenario.currencyCode)",
                    "Exact value: \(PayloFormatters.currency(paceValue, code: scenario.currencyCode))"
                ],
                symbolName: symbol,
                theme: scenario.selectedTheme
            ),
            onShare: onShare
        )
    }

    private var sessionInsightValue: String {
        let readingValue = salaryEngine.accumulatedValue(
            for: scenario,
            settings: settings,
            elapsed: Date().timeIntervalSince(sessionStartDate)
        )
        return PayloFormatters.currency(readingValue, code: scenario.currencyCode)
    }

    private var milestones: [String] {
        let pace = salaryEngine.paceSummary(for: scenario, settings: settings)
        let checks = [0.5, 1, 5, 10, pace.minute, pace.hourly / 2]
            .filter { $0 > 0 }
            .sorted()
        return checks.map { "Cross \(PayloFormatters.currency($0, code: scenario.currencyCode)) in the live session." }
    }
}
