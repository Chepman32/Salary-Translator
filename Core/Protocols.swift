import CoreGraphics
import Foundation

protocol DatasetRepository {
    var cities: [CityDatasetEntry] { get }
    var objectCatalog: [ObjectPreset] { get }
    var fxRates: FXRates { get }
}

protocol SalaryTranslationEngine {
    func annualIncome(for scenario: Scenario, settings: AppSettings) -> Double
    func paceSummary(for scenario: Scenario, settings: AppSettings) -> PaceSummary
    func accumulatedValue(for scenario: Scenario, settings: AppSettings, elapsed: TimeInterval) -> Double
    func objectInsights(
        for scenario: Scenario,
        settings: AppSettings,
        objects: [ObjectPreset],
        fxRates: FXRates
    ) -> [ObjectInsight]
    func comparatorInsight(for scenario: Scenario, settings: AppSettings) -> ComparatorInsight?
    func displayAmount(for scenario: Scenario) -> Double
    func annualAmount(from displayedAmount: Double, mode: SalaryInputMode, workHoursPerWeek: Double, workWeeksPerYear: Double) -> Double
    func humanWorkDescription(hours: Double) -> String
}

protocol CityComparisonEngine {
    func insights(
        for scenario: Scenario,
        settings: AppSettings,
        cities: [CityDatasetEntry],
        fxRates: FXRates,
        sortMode: CitySortMode
    ) -> [CityInsight]
}

protocol ShareRenderService {
    @MainActor
    func fileURL(for snapshot: ShareSnapshot, template: ShareTemplate, privacy: SharePrivacyMode, width: CGFloat) async throws -> URL
}
