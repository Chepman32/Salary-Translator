import Foundation
import SwiftData
import SwiftUI

enum SalaryInputMode: String, Codable, CaseIterable, Identifiable {
    case annual
    case monthly
    case weekly
    case hourly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .annual: "Annual"
        case .monthly: "Monthly"
        case .weekly: "Weekly"
        case .hourly: "Hourly"
        }
    }
}

enum IncomeBasis: String, Codable, CaseIterable, Identifiable {
    case gross
    case takeHome

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gross: "Gross"
        case .takeHome: "Take-home"
        }
    }
}

enum CanvasSection: String, Codable, CaseIterable, Identifiable {
    case live
    case objects
    case work
    case cities
    case gap

    var id: String { rawValue }

    var title: String {
        switch self {
        case .live: "Live"
        case .objects: "Objects"
        case .work: "Work"
        case .cities: "Cities"
        case .gap: "Gap"
        }
    }

    var symbolName: String {
        switch self {
        case .live: "waveform.path.ecg"
        case .objects: "shippingbox"
        case .work: "timer"
        case .cities: "globe.europe.africa"
        case .gap: "arrow.left.and.right.righttriangle.left.righttriangle.right"
        }
    }
}

enum ObjectCategory: String, Codable, CaseIterable, Identifiable {
    case food
    case tech
    case housing
    case transport
    case travel
    case lifestyle
    case bills
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .food: "Food"
        case .tech: "Tech"
        case .housing: "Housing"
        case .transport: "Transport"
        case .travel: "Travel"
        case .lifestyle: "Lifestyle"
        case .bills: "Bills"
        case .custom: "Custom"
        }
    }
}

enum CitySortMode: String, Codable, CaseIterable, Identifiable {
    case bestStretch
    case bestHousingRatio
    case bestDailyPower
    case bestTechAffordability
    case closestToCurrent
    case highestPressure

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bestStretch: "Best Stretch"
        case .bestHousingRatio: "Housing Ratio"
        case .bestDailyPower: "Daily Power"
        case .bestTechAffordability: "Tech Affordability"
        case .closestToCurrent: "Closest Match"
        case .highestPressure: "Lifestyle Pressure"
        }
    }
}

enum ShareTemplate: String, Codable, CaseIterable, Identifiable {
    case boldNumber
    case comparisonSplit
    case cityRanking
    case objectStatement
    case workTime
    case multiSlide

    var id: String { rawValue }

    var title: String {
        switch self {
        case .boldNumber: "Bold Number"
        case .comparisonSplit: "Comparison Split"
        case .cityRanking: "City Ranking"
        case .objectStatement: "Object Statement"
        case .workTime: "Work Time"
        case .multiSlide: "Summary Set"
        }
    }
}

enum SharePrivacyMode: String, Codable, CaseIterable, Identifiable {
    case exact
    case blurred
    case hidden

    var id: String { rawValue }

    var title: String {
        switch self {
        case .exact: "Exact"
        case .blurred: "Blurred"
        case .hidden: "Hidden"
        }
    }
}

enum ThemeStyle: String, Codable, CaseIterable, Identifiable {
    case light
    case dark
    case solar
    case mono

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var colorScheme: ColorScheme {
        switch self {
        case .dark: .dark
        case .light, .solar, .mono: .light
        }
    }
}

struct CityDatasetEntry: Codable, Identifiable, Hashable {
    let id: String
    let cityName: String
    let countryName: String
    let region: String
    let rentIndex: Double
    let basketIndex: Double
    let burgerPrice: Double
    let coffeePrice: Double
    let techIndex: Double
    let stretchScore: Double
    let notes: String
    let datasetVersion: String
}

struct ObjectPreset: Codable, Identifiable, Hashable {
    let id: String
    let localizedName: String
    let category: ObjectCategory
    let iconName: String
    let defaultPrice: Double
    let currencyCode: String
    let editableByUser: Bool
    let sharePriority: Int
    let supportingLine: String
}

struct FXRates: Codable, Hashable {
    let base: String
    let rates: [String: Double]
}

struct PaceSummary: Hashable {
    let annual: Double
    let monthly: Double
    let weekly: Double
    let daily: Double
    let hourly: Double
    let minute: Double
    let second: Double
    let paycheck: Double
}

struct ObjectInsight: Identifiable, Hashable {
    let id: String
    let preset: ObjectPreset
    let priceInScenarioCurrency: Double
    let quantityPerHour: Double
    let quantityPerDay: Double
    let quantityPerMonth: Double
    let workHours: Double
    let workDays: Double
    let ratio: Double
}

struct ComparatorInsight: Hashable {
    let comparatorAnnual: Double
    let comparatorPerMinute: Double
    let ratio: Double
    let deltaPerHour: Double
    let timeForYourHour: TimeInterval
}

struct CityInsight: Identifiable, Hashable {
    let id: String
    let city: CityDatasetEntry
    let rankScore: Double
    let rentBurden: Double
    let dailyPower: Double
    let techAffordability: Double
    let pressure: Double
    let bigMacsPerHour: Double
    let affordabilityBar: Double
    let comparisonBlurb: String
}

struct ShareSnapshot: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
    let details: [String]
    let symbolName: String
    let theme: ThemeStyle
}

@Model
final class Scenario {
    @Attribute(.unique) var id: String
    var name: String
    var salaryAmount: Double
    var currencyCode: String
    var payPeriodModeRaw: String
    var workHoursPerWeek: Double
    var workWeeksPerYear: Double
    var paychecksPerYear: Int
    var monthlyRent: Double
    var cityID: String
    var comparatorSalary: Double
    var comparatorLabel: String
    var selectedThemeRaw: String
    var favoriteObjectIDsJSON: String
    var hiddenObjectIDsJSON: String
    var manualTakeHomeAnnual: Double
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        salaryAmount: Double,
        currencyCode: String = "USD",
        payPeriodMode: SalaryInputMode = .annual,
        workHoursPerWeek: Double = 40,
        workWeeksPerYear: Double = 48,
        paychecksPerYear: Int = 24,
        monthlyRent: Double = 2400,
        cityID: String = "new-york-us",
        comparatorSalary: Double = 0,
        comparatorLabel: String = "Comparator",
        selectedTheme: ThemeStyle = .dark,
        favoriteObjectIDsJSON: String = "[]",
        hiddenObjectIDsJSON: String = "[]",
        manualTakeHomeAnnual: Double = 0,
        isArchived: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.salaryAmount = salaryAmount
        self.currencyCode = currencyCode
        self.payPeriodModeRaw = payPeriodMode.rawValue
        self.workHoursPerWeek = workHoursPerWeek
        self.workWeeksPerYear = workWeeksPerYear
        self.paychecksPerYear = paychecksPerYear
        self.monthlyRent = monthlyRent
        self.cityID = cityID
        self.comparatorSalary = comparatorSalary
        self.comparatorLabel = comparatorLabel
        self.selectedThemeRaw = selectedTheme.rawValue
        self.favoriteObjectIDsJSON = favoriteObjectIDsJSON
        self.hiddenObjectIDsJSON = hiddenObjectIDsJSON
        self.manualTakeHomeAnnual = manualTakeHomeAnnual
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var payPeriodMode: SalaryInputMode {
        get { SalaryInputMode(rawValue: payPeriodModeRaw) ?? .annual }
        set { payPeriodModeRaw = newValue.rawValue }
    }

    var selectedTheme: ThemeStyle {
        get { ThemeStyle(rawValue: selectedThemeRaw) ?? .dark }
        set { selectedThemeRaw = newValue.rawValue }
    }

    var favoriteObjectIDs: [String] {
        get { Self.decodeArray(from: favoriteObjectIDsJSON) }
        set { favoriteObjectIDsJSON = Self.encodeArray(newValue) }
    }

    var hiddenObjectIDs: [String] {
        get { Self.decodeArray(from: hiddenObjectIDsJSON) }
        set { hiddenObjectIDsJSON = Self.encodeArray(newValue) }
    }

    func touch() {
        updatedAt = .now
    }

    static func starter() -> Scenario {
        Scenario(
            name: "Current Role",
            salaryAmount: 98000,
            currencyCode: "USD",
            payPeriodMode: .annual,
            workHoursPerWeek: 40,
            workWeeksPerYear: 48,
            paychecksPerYear: 24,
            monthlyRent: 2400,
            cityID: "new-york-us",
            comparatorSalary: 162000,
            comparatorLabel: "Manager",
            selectedTheme: .dark
        )
    }

    private static func decodeArray(from raw: String) -> [String] {
        guard let data = raw.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return array
    }

    private static func encodeArray(_ values: [String]) -> String {
        let data = (try? JSONEncoder().encode(values)) ?? Data("[]".utf8)
        return String(decoding: data, as: UTF8.self)
    }
}

@Model
final class AppSettings {
    @Attribute(.unique) var id: String
    var hasCompletedOnboarding: Bool
    var defaultCurrencyCode: String
    var selectedThemeRaw: String
    var selectedIncomeBasisRaw: String
    var selectedScenarioID: String
    var hapticsEnabled: Bool
    var soundEnabled: Bool
    var reduceMotionOverride: Bool
    var highContrastEnabled: Bool
    var roundingStyle: String
    var counterSessionBehavior: String
    var objectPriceOverridesJSON: String
    var customObjectsJSON: String
    var pinnedCityIDsJSON: String
    var datasetVersion: String
    var appIconVariant: String

    init(
        id: String = "app-settings",
        hasCompletedOnboarding: Bool = false,
        defaultCurrencyCode: String = "USD",
        selectedTheme: ThemeStyle = .dark,
        selectedIncomeBasis: IncomeBasis = .gross,
        selectedScenarioID: String = "",
        hapticsEnabled: Bool = true,
        soundEnabled: Bool = false,
        reduceMotionOverride: Bool = false,
        highContrastEnabled: Bool = false,
        roundingStyle: String = "balanced",
        counterSessionBehavior: String = "screen-session",
        objectPriceOverridesJSON: String = "{}",
        customObjectsJSON: String = "[]",
        pinnedCityIDsJSON: String = "[]",
        datasetVersion: String = "2026.03",
        appIconVariant: String = "default"
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.defaultCurrencyCode = defaultCurrencyCode
        self.selectedThemeRaw = selectedTheme.rawValue
        self.selectedIncomeBasisRaw = selectedIncomeBasis.rawValue
        self.selectedScenarioID = selectedScenarioID
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
        self.reduceMotionOverride = reduceMotionOverride
        self.highContrastEnabled = highContrastEnabled
        self.roundingStyle = roundingStyle
        self.counterSessionBehavior = counterSessionBehavior
        self.objectPriceOverridesJSON = objectPriceOverridesJSON
        self.customObjectsJSON = customObjectsJSON
        self.pinnedCityIDsJSON = pinnedCityIDsJSON
        self.datasetVersion = datasetVersion
        self.appIconVariant = appIconVariant
    }

    var selectedTheme: ThemeStyle {
        get { ThemeStyle(rawValue: selectedThemeRaw) ?? .dark }
        set { selectedThemeRaw = newValue.rawValue }
    }

    var selectedIncomeBasis: IncomeBasis {
        get { IncomeBasis(rawValue: selectedIncomeBasisRaw) ?? .gross }
        set { selectedIncomeBasisRaw = newValue.rawValue }
    }

    var objectPriceOverrides: [String: Double] {
        get { Self.decodeDictionary(from: objectPriceOverridesJSON) }
        set { objectPriceOverridesJSON = Self.encodeDictionary(newValue) }
    }

    var customObjects: [ObjectPreset] {
        get {
            guard let data = customObjectsJSON.data(using: .utf8),
                  let objects = try? JSONDecoder().decode([ObjectPreset].self, from: data)
            else { return [] }
            return objects
        }
        set {
            let data = (try? JSONEncoder().encode(newValue)) ?? Data("[]".utf8)
            customObjectsJSON = String(decoding: data, as: UTF8.self)
        }
    }

    var pinnedCityIDs: [String] {
        get { Self.decodeArray(from: pinnedCityIDsJSON) }
        set { pinnedCityIDsJSON = Self.encodeArray(newValue) }
    }

    private static func decodeArray(from raw: String) -> [String] {
        guard let data = raw.data(using: .utf8),
              let values = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return values
    }

    private static func encodeArray(_ values: [String]) -> String {
        let data = (try? JSONEncoder().encode(values)) ?? Data("[]".utf8)
        return String(decoding: data, as: UTF8.self)
    }

    private static func decodeDictionary(from raw: String) -> [String: Double] {
        guard let data = raw.data(using: .utf8),
              let values = try? JSONDecoder().decode([String: Double].self, from: data)
        else { return [:] }
        return values
    }

    private static func encodeDictionary(_ values: [String: Double]) -> String {
        let data = (try? JSONEncoder().encode(values)) ?? Data("{}".utf8)
        return String(decoding: data, as: UTF8.self)
    }
}
