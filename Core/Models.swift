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
        case .annual: L10n.s("salary_input.annual", "Annual")
        case .monthly: L10n.s("salary_input.monthly", "Monthly")
        case .weekly: L10n.s("salary_input.weekly", "Weekly")
        case .hourly: L10n.s("salary_input.hourly", "Hourly")
        }
    }
}

enum IncomeBasis: String, Codable, CaseIterable, Identifiable {
    case gross
    case takeHome

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gross: L10n.s("income_basis.gross", "Gross")
        case .takeHome: L10n.s("income_basis.take_home", "Take-home")
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
        case .live: L10n.s("canvas.live", "Live")
        case .objects: L10n.s("canvas.objects", "Objects")
        case .work: L10n.s("canvas.work", "Work")
        case .cities: L10n.s("canvas.cities", "Cities")
        case .gap: L10n.s("canvas.gap", "Gap")
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
        case .food: L10n.s("object_category.food", "Food")
        case .tech: L10n.s("object_category.tech", "Tech")
        case .housing: L10n.s("object_category.housing", "Housing")
        case .transport: L10n.s("object_category.transport", "Transport")
        case .travel: L10n.s("object_category.travel", "Travel")
        case .lifestyle: L10n.s("object_category.lifestyle", "Lifestyle")
        case .bills: L10n.s("object_category.bills", "Bills")
        case .custom: L10n.s("object_category.custom", "Custom")
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
        case .bestStretch: L10n.s("city_sort.best_stretch", "Best Stretch")
        case .bestHousingRatio: L10n.s("city_sort.housing_ratio", "Housing Ratio")
        case .bestDailyPower: L10n.s("city_sort.daily_power", "Daily Power")
        case .bestTechAffordability: L10n.s("city_sort.tech_affordability", "Tech Affordability")
        case .closestToCurrent: L10n.s("city_sort.closest_match", "Closest Match")
        case .highestPressure: L10n.s("city_sort.lifestyle_pressure", "Lifestyle Pressure")
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
        case .boldNumber: L10n.s("share_template.bold_number", "Bold Number")
        case .comparisonSplit: L10n.s("share_template.comparison_split", "Comparison Split")
        case .cityRanking: L10n.s("share_template.city_ranking", "City Ranking")
        case .objectStatement: L10n.s("share_template.object_statement", "Object Statement")
        case .workTime: L10n.s("share_template.work_time", "Work Time")
        case .multiSlide: L10n.s("share_template.summary_set", "Summary Set")
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
        case .exact: L10n.s("share_privacy.exact", "Exact")
        case .blurred: L10n.s("share_privacy.blurred", "Blurred")
        case .hidden: L10n.s("share_privacy.hidden", "Hidden")
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
        switch self {
        case .light: L10n.s("theme.light", "Light")
        case .dark: L10n.s("theme.dark", "Dark")
        case .solar: L10n.s("theme.solar", "Solar")
        case .mono: L10n.s("theme.mono", "Mono")
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .dark: .dark
        case .light, .solar, .mono: .light
        }
    }
}

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case system
    case en
    case zhHans = "zh-Hans"
    case ja
    case ko
    case de
    case fr
    case esMX = "es-MX"
    case ptBR = "pt-BR"
    case ar
    case ru
    case it
    case nl
    case tr
    case th
    case vi
    case id
    case pl
    case uk
    case hi
    case he
    case sv
    case no
    case da
    case fi
    case cs
    case hu
    case ro
    case el
    case ms
    case fil

    static let storageKey = "selected_app_language"

    var id: String { rawValue }

    static var pickerOptions: [AppLanguage] {
        let sortedLanguages = allCases
            .filter { $0 != .system }
            .sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        return [.system] + sortedLanguages
    }

    static func bootstrapDefaultSelectionIfNeeded(userDefaults: UserDefaults = .standard) {
        guard userDefaults.string(forKey: storageKey) == nil else { return }
        let detectedLanguage = Locale.preferredLanguages.lazy.compactMap(resolvePreferredLanguage).first ?? .en
        userDefaults.set(detectedLanguage.rawValue, forKey: storageKey)
    }

    var title: String {
        switch self {
        case .system: L10n.s("settings.language.system", "System")
        case .en: "English"
        case .zhHans: "简体中文"
        case .ja: "日本語"
        case .ko: "한국어"
        case .de: "Deutsch"
        case .fr: "Français"
        case .esMX: "Español (México)"
        case .ptBR: "Português (Brasil)"
        case .ar: "العربية"
        case .ru: "Русский"
        case .it: "Italiano"
        case .nl: "Nederlands"
        case .tr: "Türkçe"
        case .th: "ไทย"
        case .vi: "Tiếng Việt"
        case .id: "Bahasa Indonesia"
        case .pl: "Polski"
        case .uk: "Українська"
        case .hi: "हिन्दी"
        case .he: "עברית"
        case .sv: "Svenska"
        case .no: "Norsk"
        case .da: "Dansk"
        case .fi: "Suomi"
        case .cs: "Čeština"
        case .hu: "Magyar"
        case .ro: "Română"
        case .el: "Ελληνικά"
        case .ms: "Bahasa Melayu"
        case .fil: "Filipino"
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system: nil
        case .no: "nb"
        default: rawValue
        }
    }

    private static func resolvePreferredLanguage(from identifier: String) -> AppLanguage? {
        if let directMatch = AppLanguage(rawValue: identifier) {
            return directMatch
        }

        let normalized = identifier.replacingOccurrences(of: "_", with: "-")
        if normalized.hasPrefix("zh-Hans") { return .zhHans }
        if normalized.hasPrefix("es-MX") { return .esMX }
        if normalized.hasPrefix("pt-BR") { return .ptBR }
        if normalized.hasPrefix("nb") || normalized.hasPrefix("no") { return .no }

        let languageCode = Locale(identifier: normalized).language.languageCode?.identifier
            ?? normalized.split(separator: "-").first.map(String.init)

        return switch languageCode {
        case "en": .en
        case "ja": .ja
        case "ko": .ko
        case "de": .de
        case "fr": .fr
        case "ar": .ar
        case "ru": .ru
        case "it": .it
        case "nl": .nl
        case "tr": .tr
        case "th": .th
        case "vi": .vi
        case "id": .id
        case "pl": .pl
        case "uk": .uk
        case "hi": .hi
        case "he": .he
        case "sv": .sv
        case "da": .da
        case "fi": .fi
        case "cs": .cs
        case "hu": .hu
        case "ro": .ro
        case "el": .el
        case "ms": .ms
        case "fil": .fil
        default: nil
        }
    }
}

enum CurrencyCatalog {
    static let supportedCodes = ["USD", "EUR", "GBP", "JPY", "PLN", "AED", "SGD", "AUD", "CAD", "THB", "RUB"]

    static func orderedCodes(for locale: Locale) -> [String] {
        let preferredCode = preferredCode(for: locale)
        return supportedCodes.sorted { lhs, rhs in
            if lhs == preferredCode { return true }
            if rhs == preferredCode { return false }
            return supportedCodes.firstIndex(of: lhs)! < supportedCodes.firstIndex(of: rhs)!
        }
    }

    private static func preferredCode(for locale: Locale) -> String? {
        if let regionIdentifier = locale.region?.identifier {
            switch regionIdentifier {
            case "RU": return "RUB"
            case "JP": return "JPY"
            case "PL": return "PLN"
            case "AE": return "AED"
            case "SG": return "SGD"
            case "AU": return "AUD"
            case "CA": return "CAD"
            case "TH": return "THB"
            case "GB": return "GBP"
            case "US": return "USD"
            default: break
            }
        }

        let languageCode = locale.language.languageCode?.identifier
            ?? locale.identifier.split(separator: "-").first.map(String.init)

        switch languageCode {
        case "ru": return "RUB"
        case "ja": return "JPY"
        case "pl": return "PLN"
        case "ar": return "AED"
        case "th": return "THB"
        case "en": return "USD"
        case "de", "fr", "it", "nl", "fi", "el", "pt", "es": return "EUR"
        case "uk": return "PLN"
        default: return nil
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
    var customImageFileName: String? = nil
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
    var customImageFileName: String? = nil
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
            name: Self.localizedStarterName,
            salaryAmount: 98000,
            currencyCode: "USD",
            payPeriodMode: .annual,
            workHoursPerWeek: 40,
            workWeeksPerYear: 48,
            paychecksPerYear: 24,
            monthlyRent: 2400,
            cityID: "new-york-us",
            comparatorSalary: 162000,
            comparatorLabel: Self.localizedStarterComparator,
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
