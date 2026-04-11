import SwiftUI

struct WorkCanvasView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    let repository: BundledDatasetRepository
    let salaryEngine: SalaryTranslationEngine
    let onShare: (ShareSnapshot) -> Void

    @State private var selectedObjectID: String?

    private var insights: [ObjectInsight] {
        salaryEngine.objectInsights(
            for: scenario,
            settings: settings,
            objects: repository.objectCatalog,
            fxRates: repository.fxRates
        )
        .sorted { $0.workHours < $1.workHours }
    }

    private var selectedInsight: ObjectInsight? {
        insights.first(where: { $0.id == selectedObjectID }) ?? insights.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(
                title: L10n.s("work.title", "Feel the labor cost."),
                subtitle: L10n.s("work.subtitle", "Spatial time lanes turn price into real effort."),
                palette: palette
            )

            if let selectedInsight {
                GlassCard(palette: palette, padding: 22) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            HStack(spacing: 10) {
                                ObjectIconView(
                                    symbolName: selectedInsight.preset.iconName,
                                    customImageFileName: selectedInsight.preset.customImageFileName,
                                    palette: palette
                                )

                                Text(selectedInsight.preset.localizedName)
                            }
                            Spacer()
                            Button(L10n.s("common.share", "Share")) {
                                onShare(snapshot(for: selectedInsight))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(palette.accent)
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(palette.textPrimary)

                        Text(L10n.f("objects.hours", "%@ hours", EarnzaFormatters.decimal(selectedInsight.workHours, fractionDigits: 1)))
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(palette.textPrimary)

                        Text(salaryEngine.humanWorkDescription(hours: selectedInsight.workHours))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(palette.textSecondary)

                        GeometryReader { proxy in
                            HStack(spacing: 8) {
                                ForEach(0..<max(1, Int(ceil(selectedInsight.workHours / 2))), id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(index * 2 < Int(ceil(selectedInsight.workHours)) ? palette.accent : palette.divider.opacity(0.3))
                                        .frame(width: (proxy.size.width - 24) / CGFloat(max(1, Int(ceil(selectedInsight.workHours / 2)))), height: 24)
                                }
                            }
                        }
                        .frame(height: 24)
                    }
                }
            }

            VStack(spacing: 10) {
                ForEach(insights) { insight in
                    Button {
                        selectedObjectID = insight.id
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(insight.preset.localizedName)
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer()
                                Text(EarnzaFormatters.duration(hours: insight.workHours))
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                            }
                            .foregroundStyle(palette.textPrimary)

                            GeometryReader { proxy in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(palette.divider.opacity(0.3))
                                    Capsule()
                                        .fill(palette.accent)
                                        .frame(width: max(18, min(proxy.size.width, proxy.size.width * CGFloat(min(insight.workHours / 20, 1)))))
                                }
                            }
                            .frame(height: 10)

                            Text(salaryEngine.humanWorkDescription(hours: insight.workHours))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(palette.textSecondary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(selectedObjectID == insight.id ? palette.cardFill.opacity(1.15) : palette.cardFill)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(selectedObjectID == insight.id ? palette.accent.opacity(0.4) : palette.divider, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.bottom, 30)
    }

    private func snapshot(for insight: ObjectInsight) -> ShareSnapshot {
        ShareSnapshot(
            title: L10n.s("work.share.title", "You work this long for"),
            value: insight.preset.localizedName,
            subtitle: L10n.f("work.share.subtitle", "%@ hours of work", EarnzaFormatters.decimal(insight.workHours, fractionDigits: 1)),
            details: [
                EarnzaFormatters.duration(hours: insight.workHours),
                salaryEngine.humanWorkDescription(hours: insight.workHours),
                L10n.f("common.price_value", "Price: %@", EarnzaFormatters.currency(insight.priceInScenarioCurrency, code: scenario.currencyCode))
            ],
            symbolName: insight.preset.iconName,
            theme: scenario.selectedTheme,
            customImageFileName: insight.preset.customImageFileName
        )
    }
}
