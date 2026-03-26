import SwiftUI

struct GapCanvasView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    let salaryEngine: SalaryTranslationEngine
    @Binding var sessionStartDate: Date
    let onShare: (ShareSnapshot) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle(
                    title: "Compare the pace, not the drama.",
                    subtitle: "Sharp, factual, and calibrated for social share without turning tacky.",
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
                            label: scenario.comparatorLabel.isEmpty ? "Comparator" : scenario.comparatorLabel,
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
                            title: "Comparator Pace",
                            value: "\(PayloFormatters.decimal(insight.ratio, fractionDigits: 1))x",
                            subtitle: "Relative minute-by-minute speed",
                            symbolName: "speedometer",
                            shareSnapshot: snapshot(for: insight),
                            onShare: onShare
                        )

                        InsightCard(
                            palette: palette,
                            title: "They earn your hour in",
                            value: "\(PayloFormatters.decimal(insight.timeForYourHour, fractionDigits: 1)) min",
                            subtitle: "Compressed time translation of the gap",
                            symbolName: "timer.square",
                            shareSnapshot: snapshot(for: insight),
                            onShare: onShare
                        )

                        InsightCard(
                            palette: palette,
                            title: "Delta Per Hour",
                            value: PayloFormatters.currency(insight.deltaPerHour, code: scenario.currencyCode),
                            subtitle: "Gap at equal work assumptions",
                            symbolName: "chart.bar.xaxis",
                            shareSnapshot: snapshot(for: insight),
                            onShare: onShare
                        )

                        GlassCard(palette: palette) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Gap ladder")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(palette.textPrimary)

                                Text("\(scenario.comparatorLabel) earns the equivalent of \(PayloFormatters.decimal(max(insight.deltaPerHour, 0) / max(499 / max(pace.hourly, 0.01), 1), fractionDigits: 1)) PS5 hours saved per hour of work.")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(palette.textSecondary)

                                RatioBar(progress: min(insight.ratio / 5, 1), palette: palette)
                            }
                        }
                    }
                } else {
                    GlassCard(palette: palette) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add a comparator salary in assumptions to unlock this canvas.")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(palette.textPrimary)
                            Text("Use it for a boss, another offer, a target salary, or any benchmark you want to hold against your current pace.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(palette.textSecondary)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
    }

    private func snapshot(for insight: ComparatorInsight) -> ShareSnapshot {
        ShareSnapshot(
            title: "Comparator pace",
            value: "\(PayloFormatters.decimal(insight.ratio, fractionDigits: 1))x",
            subtitle: "\(scenario.comparatorLabel) against your current scenario",
            details: [
                "Comparator annual: \(PayloFormatters.currency(insight.comparatorAnnual, code: scenario.currencyCode, maximumFractionDigits: 0))",
                "Delta per hour: \(PayloFormatters.currency(insight.deltaPerHour, code: scenario.currencyCode))",
                "They earn your hour in \(PayloFormatters.decimal(insight.timeForYourHour, fractionDigits: 1)) minutes"
            ],
            symbolName: "person.2",
            theme: scenario.selectedTheme
        )
    }
}
