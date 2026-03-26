import SwiftUI

struct CitiesCanvasView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    let repository: BundledDatasetRepository
    let cityEngine: CityComparisonEngine
    let salaryEngine: SalaryTranslationEngine
    let onShare: (ShareSnapshot) -> Void

    @State private var searchText = ""
    @State private var sortMode: CitySortMode = .bestStretch
    @State private var selectedInsight: CityInsight?

    private var insights: [CityInsight] {
        cityEngine.insights(
            for: scenario,
            settings: settings,
            cities: repository.cities.filter {
                searchText.isEmpty
                || $0.cityName.localizedCaseInsensitiveContains(searchText)
                || $0.countryName.localizedCaseInsensitiveContains(searchText)
            },
            fxRates: repository.fxRates,
            sortMode: sortMode
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(
                title: "See where the same salary bends differently.",
                subtitle: "Local editorial indices, not tax promises.",
                palette: palette
            )

            if let best = insights.first {
                GlassCard(palette: palette) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your salary stretches furthest in")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(palette.textSecondary)
                                Text(best.city.cityName)
                                    .font(.system(size: 30, weight: .black, design: .rounded))
                                    .foregroundStyle(palette.textPrimary)
                            }
                            Spacer()
                            Button("Share") {
                                onShare(snapshot(for: best))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(palette.accent)
                        }

                        Text(best.comparisonBlurb)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(palette.textSecondary)

                        RatioBar(progress: best.affordabilityBar, palette: palette)
                    }
                }
            }

            TextField("Search city or country", text: $searchText)
                .textFieldStyle(.roundedBorder)

            Picker("Sort", selection: $sortMode) {
                ForEach(CitySortMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.menu)

            if !settings.pinnedCityIDs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(settings.pinnedCityIDs, id: \.self) { cityID in
                            if let city = repository.cities.first(where: { $0.id == cityID }) {
                                Text(city.cityName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 9)
                                    .background(Capsule(style: .continuous).fill(palette.cardFill))
                            }
                        }
                    }
                }
            }

            LazyVStack(spacing: 10) {
                ForEach(Array(insights.enumerated()), id: \.element.id) { index, insight in
                    CityRankRow(rank: index + 1, insight: insight, currencyCode: scenario.currencyCode, palette: palette) {
                        selectedInsight = insight
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            togglePin(insight.id)
                        } label: {
                            Label("Pin", systemImage: settings.pinnedCityIDs.contains(insight.id) ? "pin.slash" : "pin")
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            onShare(snapshot(for: insight))
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .tint(Color(palette.accent))
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.bottom, 30)
        .sheet(item: $selectedInsight) { insight in
            CityDetailSheet(insight: insight, scenario: scenario, palette: palette, onShare: { onShare(snapshot(for: insight)) })
        }
    }

    private func togglePin(_ id: String) {
        var pinned = settings.pinnedCityIDs
        if let index = pinned.firstIndex(of: id) {
            pinned.remove(at: index)
        } else {
            pinned.append(id)
        }
        settings.pinnedCityIDs = pinned
    }

    private func snapshot(for insight: CityInsight) -> ShareSnapshot {
        ShareSnapshot(
            title: insight.city.cityName,
            value: "Stretch score \(PayloFormatters.decimal(insight.rankScore, fractionDigits: 0))",
            subtitle: insight.comparisonBlurb,
            details: [
                "Daily purchasing power: \(PayloFormatters.currency(insight.dailyPower, code: scenario.currencyCode))",
                "Burger pace: \(PayloFormatters.decimal(insight.bigMacsPerHour, fractionDigits: 1)) per hour",
                "Pressure index: \(PayloFormatters.decimal(insight.pressure, fractionDigits: 2))"
            ],
            symbolName: "building.2",
            theme: scenario.selectedTheme
        )
    }
}

private struct CityDetailSheet: View {
    let insight: CityInsight
    let scenario: Scenario
    let palette: ThemePalette
    let onShare: () -> Void

    var body: some View {
        BottomSheetEditor(title: insight.city.cityName, palette: palette) {
            Text(insight.comparisonBlurb)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(palette.textSecondary)

            GroupBox("Affordability") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily power: \(PayloFormatters.currency(insight.dailyPower, code: scenario.currencyCode))")
                    Text("Housing pressure: \(PayloFormatters.decimal(insight.rentBurden, fractionDigits: 2))")
                    Text("Tech affordability score: \(PayloFormatters.decimal(insight.techAffordability, fractionDigits: 1))")
                    Text("Big Mac pace: \(PayloFormatters.decimal(insight.bigMacsPerHour, fractionDigits: 1)) per hour")
                }
                .font(.system(size: 14, weight: .medium))
            }

            GroupBox("Method") {
                Text("Static local dataset. Editorial indices are applied to your saved scenario without pretending tax precision.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
            }

            Button("Share City Card", action: onShare)
                .buttonStyle(.borderedProminent)
                .tint(palette.accent)
        }
    }
}
