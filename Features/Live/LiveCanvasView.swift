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
                title: L10n.s("live.title", "Watch income turn visible."),
                subtitle: L10n.s("live.subtitle", "Continuous pace, reading-session accumulation, and shareable milestone moments."),
                palette: palette
            )

            TimelineView(.animation(minimumInterval: 0.1)) { timeline in
                let elapsed = timeline.date.timeIntervalSince(sessionStartDate)
                let accumulated = salaryEngine.accumulatedValue(for: scenario, settings: settings, elapsed: elapsed)
                let pace = salaryEngine.paceSummary(for: scenario, settings: settings)

                GlassCard(palette: palette, padding: 22) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(L10n.s("live.earning_now", "You are earning now"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(palette.textSecondary)

                        MoneyCounterView(
                            value: accumulated,
                            currencyCode: scenario.currencyCode,
                            fontSize: 46,
                            weight: .black,
                            palette: palette
                        )

                        Text(L10n.s("live.real_time_note", "While you read this, the number keeps resolving in real time."))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(palette.textSecondary)

                        RatioBar(progress: min(accumulated / max(pace.hourly, 1), 1), palette: palette)

                        HStack {
                            Text(L10n.s("live.minute_pace", "Minute pace"))
                            Spacer()
                            Text(EarnzaFormatters.currency(pace.minute, code: scenario.currencyCode))
                                .monospacedDigit()
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)
                    }
                }
                .onLongPressGesture {
                    onShare(
                        ShareSnapshot(
                            title: L10n.s("live.while_you_read_this", "While you read this"),
                            value: EarnzaFormatters.currency(accumulated, code: scenario.currencyCode),
                            subtitle: L10n.s("live.screen_session", "Screen-session accumulation"),
                            details: [
                                L10n.f("live.per_minute_value", "Per minute: %@", EarnzaFormatters.currency(pace.minute, code: scenario.currencyCode)),
                                L10n.f("live.per_hour_value", "Per hour: %@", EarnzaFormatters.currency(pace.hourly, code: scenario.currencyCode)),
                                L10n.f("common.scenario_value", "Scenario: %@", scenario.name)
                            ],
                            symbolName: "timer",
                            theme: scenario.selectedTheme
                        )
                    )
                }
            }

            let pace = salaryEngine.paceSummary(for: scenario, settings: settings)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                insightCard(title: L10n.s("pace.per_second", "Per Second"), value: EarnzaFormatters.currency(pace.second, code: scenario.currencyCode), subtitle: L10n.s("live.per_second_subtitle", "Continuous rate for live accumulation"), symbol: "hare", paceValue: pace.second)
                insightCard(title: L10n.s("pace.per_minute", "Per Minute"), value: EarnzaFormatters.currency(pace.minute, code: scenario.currencyCode), subtitle: L10n.s("live.per_minute_subtitle", "The clearest real-time heartbeat"), symbol: "clock", paceValue: pace.minute)
                insightCard(title: L10n.s("pace.per_workday", "Per Workday"), value: EarnzaFormatters.currency(pace.daily, code: scenario.currencyCode), subtitle: L10n.s("live.per_workday_subtitle", "Saved work assumption applied"), symbol: "briefcase", paceValue: pace.daily)
                insightCard(title: L10n.s("pace.per_paycheck", "Per Paycheck"), value: EarnzaFormatters.currency(pace.paycheck, code: scenario.currencyCode), subtitle: L10n.s("live.per_paycheck_subtitle", "Based on paychecks per year"), symbol: "creditcard", paceValue: pace.paycheck)
                insightCard(title: L10n.s("pace.per_month", "Per Month"), value: EarnzaFormatters.currency(pace.monthly, code: scenario.currencyCode, maximumFractionDigits: 0), subtitle: L10n.s("live.per_month_subtitle", "Salary spread over 12 months"), symbol: "calendar", paceValue: pace.monthly)
                insightCard(title: L10n.s("live.reading_session", "Reading Session"), value: sessionInsightValue, subtitle: L10n.s("live.reading_session_subtitle", "Resets when the app becomes active again"), symbol: "book.pages", paceValue: pace.minute)
            }

            GlassCard(palette: palette) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.s("live.milestones", "Milestones"))
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
                    L10n.f("common.scenario_value", "Scenario: %@", scenario.name),
                    L10n.f("common.currency_value", "Currency: %@", scenario.currencyCode),
                    L10n.f("common.exact_value", "Exact value: %@", EarnzaFormatters.currency(paceValue, code: scenario.currencyCode))
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
        return EarnzaFormatters.currency(readingValue, code: scenario.currencyCode)
    }

    private var milestones: [String] {
        let pace = salaryEngine.paceSummary(for: scenario, settings: settings)
        let checks = [0.5, 1, 5, 10, pace.minute, pace.hourly / 2]
            .filter { $0 > 0 }
            .sorted()
        return checks.map { L10n.f("live.cross_milestone", "Cross %@ in the live session.", EarnzaFormatters.currency($0, code: scenario.currencyCode)) }
    }
}
