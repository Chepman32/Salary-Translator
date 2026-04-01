import SwiftUI

struct LibraryView: View {
    let scenarios: [Scenario]
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    let onSelect: (Scenario) -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var selectedForCompare: Set<String> = []

    private var activeScenarios: [Scenario] {
        scenarios.filter { !$0.isArchived }
    }

    var body: some View {
        NavigationStack {
            List {
                if selectedForCompare.count == 2 {
                    compareSection
                }

                ForEach(activeScenarios) { scenario in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(scenario.name)
                                    .font(.system(size: 16, weight: .semibold))
                                Text(EarnzaFormatters.currency(scenario.salaryAmount, code: scenario.currencyCode, maximumFractionDigits: 0))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if settings.selectedScenarioID == scenario.id {
                                Text("Current")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.primary.opacity(0.08)))
                            }
                        }

                        Text("City: \(scenario.cityID)  Rent: \(EarnzaFormatters.currency(scenario.monthlyRent, code: scenario.currencyCode, maximumFractionDigits: 0))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(scenario)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            scenario.isArchived = true
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }

                        Button {
                            duplicate(scenario)
                        } label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            toggleCompare(scenario.id)
                        } label: {
                            Label("Compare", systemImage: selectedForCompare.contains(scenario.id) ? "checkmark.circle.fill" : "circle")
                        }
                        .tint(.orange)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(EarnzaBackground(palette: palette))
            .navigationTitle("Scenario Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createScenario()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var compareSection: some View {
        Section("Compare") {
            let selected = activeScenarios.filter { selectedForCompare.contains($0.id) }
            if selected.count == 2 {
                let first = selected[0]
                let second = selected[1]
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(first.name) vs \(second.name)")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Delta: \(EarnzaFormatters.currency(second.salaryAmount - first.salaryAmount, code: first.currencyCode, maximumFractionDigits: 0)) annually")
                        .font(.system(size: 13, weight: .medium))
                    Text("Rent difference: \(EarnzaFormatters.currency(second.monthlyRent - first.monthlyRent, code: first.currencyCode, maximumFractionDigits: 0)) per month")
                        .font(.system(size: 13, weight: .medium))
                }
            }
        }
    }

    private func toggleCompare(_ id: String) {
        if selectedForCompare.contains(id) {
            selectedForCompare.remove(id)
        } else {
            if selectedForCompare.count == 2 {
                _ = selectedForCompare.popFirst()
            }
            selectedForCompare.insert(id)
        }
    }

    private func duplicate(_ scenario: Scenario) {
        let copy = Scenario(
            name: "\(scenario.name) Copy",
            salaryAmount: scenario.salaryAmount,
            currencyCode: scenario.currencyCode,
            payPeriodMode: scenario.payPeriodMode,
            workHoursPerWeek: scenario.workHoursPerWeek,
            workWeeksPerYear: scenario.workWeeksPerYear,
            paychecksPerYear: scenario.paychecksPerYear,
            monthlyRent: scenario.monthlyRent,
            cityID: scenario.cityID,
            comparatorSalary: scenario.comparatorSalary,
            comparatorLabel: scenario.comparatorLabel,
            selectedTheme: scenario.selectedTheme,
            favoriteObjectIDsJSON: scenario.favoriteObjectIDsJSON,
            hiddenObjectIDsJSON: "[]",
            manualTakeHomeAnnual: scenario.manualTakeHomeAnnual
        )
        modelContext.insert(copy)
    }

    private func createScenario() {
        let scenario = Scenario(
            name: "New Scenario",
            salaryAmount: 120_000,
            currencyCode: settings.defaultCurrencyCode,
            cityID: "berlin-de",
            selectedTheme: settings.selectedTheme
        )
        modelContext.insert(scenario)
        settings.selectedScenarioID = scenario.id
    }
}
