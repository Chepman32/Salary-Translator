import SwiftUI

struct GapCanvasView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    let salaryEngine: SalaryTranslationEngine
    @Binding var sessionStartDate: Date
    let onShare: (ShareSnapshot) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(
                title: L10n.s("gap.title", "Compare the pace, not the drama."),
                subtitle: L10n.s("gap.subtitle", "Sharp, factual, and calibrated for social share without turning tacky."),
                palette: palette
            )

            if let insight = salaryEngine.comparatorInsight(for: scenario, settings: settings) {
                TimelineView(.animation(minimumInterval: 0.1)) { timeline in
                    let elapsed = timeline.date.timeIntervalSince(sessionStartDate)
                    let yourValue = salaryEngine.accumulatedValue(for: scenario, settings: settings, elapsed: elapsed)
                    let comparatorValue = insight.comparatorPerMinute / 60 * elapsed

                    ComparatorPanel(
                        yourValue: yourValue,
                        comparatorValue: comparatorValue,
                        currencyCode: scenario.currencyCode,
                        label: scenario.comparatorLabel.isEmpty ? Scenario.localizedComparatorFallback : scenario.comparatorLabel,
                        ratio: insight.ratio,
                        palette: palette
                    )
                    .onLongPressGesture {
                        onShare(snapshot(for: insight))
                    }
                }

                let pace = salaryEngine.paceSummary(for: scenario, settings: settings)
                LazyVStack(spacing: 12) {
                    InsightCard(
                        palette: palette,
                        title: L10n.s("gap.comparator_pace", "Comparator Pace"),
                        value: "\(EarnzaFormatters.decimal(insight.ratio, fractionDigits: 1))x",
                        subtitle: L10n.s("gap.comparator_pace_subtitle", "Relative minute-by-minute speed"),
                        symbolName: "speedometer",
                        shareSnapshot: snapshot(for: insight),
                        onShare: onShare
                    )

                    InsightCard(
                        palette: palette,
                        title: L10n.s("gap.they_earn_your_hour_in", "They earn your hour in"),
                        value: "\(EarnzaFormatters.decimal(insight.timeForYourHour, fractionDigits: 1)) min",
                        subtitle: L10n.s("gap.they_earn_your_hour_in_subtitle", "Compressed time translation of the gap"),
                        symbolName: "timer.square",
                        shareSnapshot: snapshot(for: insight),
                        onShare: onShare
                    )

                    InsightCard(
                        palette: palette,
                        title: L10n.s("gap.delta_per_hour", "Delta Per Hour"),
                        value: EarnzaFormatters.currency(insight.deltaPerHour, code: scenario.currencyCode),
                        subtitle: L10n.s("gap.delta_per_hour_subtitle", "Gap at equal work assumptions"),
                        symbolName: "chart.bar.xaxis",
                        shareSnapshot: snapshot(for: insight),
                        onShare: onShare
                    )

                    GlassCard(palette: palette) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L10n.s("gap.ladder", "Gap ladder"))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(palette.textPrimary)

                            Text(L10n.f("gap.ladder_body", "%@ earns the equivalent of %@ PS5 hours saved per hour of work.", scenario.comparatorLabel, EarnzaFormatters.decimal(max(insight.deltaPerHour, 0) / max(499 / max(pace.hourly, 0.01), 1), fractionDigits: 1)))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(palette.textSecondary)

                            RatioBar(progress: min(insight.ratio / 5, 1), palette: palette)
                        }
                    }
                }
            } else {
                GlassCard(palette: palette) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.s("gap.empty_title", "Add a comparator salary in assumptions to unlock this canvas."))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(palette.textPrimary)
                        Text(L10n.s("gap.empty_body", "Use it for a boss, another offer, a target salary, or any benchmark you want to hold against your current pace."))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(palette.textSecondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.bottom, 30)
    }

    private func snapshot(for insight: ComparatorInsight) -> ShareSnapshot {
        ShareSnapshot(
            title: L10n.s("gap.share.title", "Comparator pace"),
            value: "\(EarnzaFormatters.decimal(insight.ratio, fractionDigits: 1))x",
            subtitle: L10n.f("gap.share.subtitle", "%@ against your current scenario", scenario.comparatorLabel),
            details: [
                L10n.f("gap.share.annual", "Comparator annual: %@", EarnzaFormatters.currency(insight.comparatorAnnual, code: scenario.currencyCode, maximumFractionDigits: 0)),
                L10n.f("gap.share.delta", "Delta per hour: %@", EarnzaFormatters.currency(insight.deltaPerHour, code: scenario.currencyCode)),
                L10n.f("gap.share.minutes", "They earn your hour in %@ minutes", EarnzaFormatters.decimal(insight.timeForYourHour, fractionDigits: 1))
            ],
            symbolName: "person.2",
            theme: scenario.selectedTheme
        )
    }
}
