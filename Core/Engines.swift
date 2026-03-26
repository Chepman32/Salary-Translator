import Foundation

struct DefaultSalaryTranslationEngine: SalaryTranslationEngine {
    func annualIncome(for scenario: Scenario, settings: AppSettings) -> Double {
        if settings.selectedIncomeBasis == .takeHome, scenario.manualTakeHomeAnnual > 0 {
            return scenario.manualTakeHomeAnnual
        }
        return scenario.salaryAmount
    }

    func paceSummary(for scenario: Scenario, settings: AppSettings) -> PaceSummary {
        let annual = annualIncome(for: scenario, settings: settings)
        let weekly = annual / max(scenario.workWeeksPerYear, 1)
        let monthly = annual / 12
        let daily = weekly / max((scenario.workHoursPerWeek / 8), 1)
        let hourly = annual / max(scenario.workHoursPerWeek * scenario.workWeeksPerYear, 1)
        let minute = hourly / 60
        let second = minute / 60
        let paycheck = annual / Double(max(scenario.paychecksPerYear, 1))
        return PaceSummary(
            annual: annual,
            monthly: monthly,
            weekly: weekly,
            daily: daily,
            hourly: hourly,
            minute: minute,
            second: second,
            paycheck: paycheck
        )
    }

    func accumulatedValue(for scenario: Scenario, settings: AppSettings, elapsed: TimeInterval) -> Double {
        let perSecond = paceSummary(for: scenario, settings: settings).second
        return max(0, perSecond * elapsed)
    }

    func objectInsights(
        for scenario: Scenario,
        settings: AppSettings,
        objects: [ObjectPreset],
        fxRates: FXRates
    ) -> [ObjectInsight] {
        let pace = paceSummary(for: scenario, settings: settings)
        let salaryCurrency = scenario.currencyCode

        return objects.map { object in
            let overridePrice = settings.objectPriceOverrides[object.id]
            let basePrice = overridePrice ?? object.defaultPrice
            let converted = convertedAmount(
                basePrice,
                from: object.currencyCode,
                to: salaryCurrency,
                fxRates: fxRates
            )

            let quantityPerHour = pace.hourly / max(converted, 0.01)
            let workHours = converted / max(pace.hourly, 0.01)
            return ObjectInsight(
                id: object.id,
                preset: object,
                priceInScenarioCurrency: converted,
                quantityPerHour: quantityPerHour,
                quantityPerDay: pace.daily / max(converted, 0.01),
                quantityPerMonth: pace.monthly / max(converted, 0.01),
                workHours: workHours,
                workDays: workHours / 8,
                ratio: min(max(pace.daily / max(converted, 0.01), 0), 1.4)
            )
        }
        .sorted { lhs, rhs in
            if lhs.preset.sharePriority == rhs.preset.sharePriority {
                return lhs.workHours < rhs.workHours
            }
            return lhs.preset.sharePriority < rhs.preset.sharePriority
        }
    }

    func comparatorInsight(for scenario: Scenario, settings: AppSettings) -> ComparatorInsight? {
        guard scenario.comparatorSalary > 0 else { return nil }
        let yourPace = paceSummary(for: scenario, settings: settings)
        let comparatorPerHour = scenario.comparatorSalary / max(scenario.workHoursPerWeek * scenario.workWeeksPerYear, 1)
        let comparatorPerMinute = comparatorPerHour / 60
        let ratio = comparatorPerMinute / max(yourPace.minute, 0.0001)
        let deltaPerHour = comparatorPerHour - yourPace.hourly
        let timeForYourHour = yourPace.hourly / max(comparatorPerMinute, 0.0001) * 60
        return ComparatorInsight(
            comparatorAnnual: scenario.comparatorSalary,
            comparatorPerMinute: comparatorPerMinute,
            ratio: ratio,
            deltaPerHour: deltaPerHour,
            timeForYourHour: timeForYourHour
        )
    }

    func displayAmount(for scenario: Scenario) -> Double {
        switch scenario.payPeriodMode {
        case .annual:
            scenario.salaryAmount
        case .monthly:
            scenario.salaryAmount / 12
        case .weekly:
            scenario.salaryAmount / max(scenario.workWeeksPerYear, 1)
        case .hourly:
            scenario.salaryAmount / max(scenario.workHoursPerWeek * scenario.workWeeksPerYear, 1)
        }
    }

    func annualAmount(from displayedAmount: Double, mode: SalaryInputMode, workHoursPerWeek: Double, workWeeksPerYear: Double) -> Double {
        switch mode {
        case .annual:
            displayedAmount
        case .monthly:
            displayedAmount * 12
        case .weekly:
            displayedAmount * workWeeksPerYear
        case .hourly:
            displayedAmount * workHoursPerWeek * workWeeksPerYear
        }
    }

    func humanWorkDescription(hours: Double) -> String {
        switch hours {
        case ..<0.25:
            return "Less than a coffee break"
        case ..<1:
            return "About a lunch stretch"
        case ..<4:
            return "Part of a focused work block"
        case ..<8:
            return "Roughly half a workday"
        case ..<16:
            return "More than one full day"
        case ..<40:
            return "Close to a working week"
        default:
            return "A serious chunk of labor time"
        }
    }

    private func convertedAmount(_ amount: Double, from: String, to: String, fxRates: FXRates) -> Double {
        guard from != to else { return amount }
        let fromRate = fxRates.rates[from] ?? 1
        let toRate = fxRates.rates[to] ?? 1
        let usdValue = amount / fromRate
        return usdValue * toRate
    }
}

struct DefaultCityComparisonEngine: CityComparisonEngine {
    private let translationEngine = DefaultSalaryTranslationEngine()

    func insights(
        for scenario: Scenario,
        settings: AppSettings,
        cities: [CityDatasetEntry],
        fxRates: FXRates,
        sortMode: CitySortMode
    ) -> [CityInsight] {
        let annual = translationEngine.annualIncome(for: scenario, settings: settings)
        let usdAnnual = annual / (fxRates.rates[scenario.currencyCode] ?? 1)
        let homeCity = cities.first(where: { $0.id == scenario.cityID })

        let computed = cities.map { city in
            let normalizedMonthly = (usdAnnual / 12) / max(city.rentIndex * 0.6 + city.basketIndex * 0.4, 0.2)
            let rentBurden = city.rentIndex * 0.42
            let dailyPower = normalizedMonthly / 30
            let techAffordability = usdAnnual / max(city.techIndex * 900, 1)
            let pressure = city.rentIndex * 0.55 + city.basketIndex * 0.45
            let bigMacsPerHour = (usdAnnual / 2080) / max(city.burgerPrice, 1)
            let rankScore = normalizedMonthly * (city.stretchScore / 100)
            let comparisonBlurb: String

            if let homeCity {
                let delta = (homeCity.rentIndex + homeCity.basketIndex) - (city.rentIndex + city.basketIndex)
                comparisonBlurb = delta > 0 ? "This salary stretches further." : "This city feels tighter."
            } else {
                comparisonBlurb = "Based on the saved assumptions."
            }

            return CityInsight(
                id: city.id,
                city: city,
                rankScore: rankScore,
                rentBurden: rentBurden,
                dailyPower: dailyPower,
                techAffordability: techAffordability,
                pressure: pressure,
                bigMacsPerHour: bigMacsPerHour,
                affordabilityBar: min(max(rankScore / 500, 0.08), 1),
                comparisonBlurb: comparisonBlurb
            )
        }

        switch sortMode {
        case .bestStretch:
            return computed.sorted { $0.rankScore > $1.rankScore }
        case .bestHousingRatio:
            return computed.sorted { $0.rentBurden < $1.rentBurden }
        case .bestDailyPower:
            return computed.sorted { $0.dailyPower > $1.dailyPower }
        case .bestTechAffordability:
            return computed.sorted { $0.techAffordability > $1.techAffordability }
        case .closestToCurrent:
            guard let homeCity else { return computed.sorted { $0.rankScore > $1.rankScore } }
            return computed.sorted {
                let lhsDelta = abs($0.city.rentIndex - homeCity.rentIndex) + abs($0.city.basketIndex - homeCity.basketIndex)
                let rhsDelta = abs($1.city.rentIndex - homeCity.rentIndex) + abs($1.city.basketIndex - homeCity.basketIndex)
                return lhsDelta < rhsDelta
            }
        case .highestPressure:
            return computed.sorted { $0.pressure > $1.pressure }
        }
    }
}
