import XCTest
@testable import Paylo

final class PayloCityEngineTests: XCTestCase {
    private let engine = DefaultCityComparisonEngine()

    func testBestStretchSortReturnsHighestScoreFirst() {
        let scenario = Scenario(name: "Test", salaryAmount: 120_000, cityID: "new-york-us")
        let settings = AppSettings()
        let repository = BundledDatasetRepository(bundle: Bundle(for: Self.self))

        let insights = engine.insights(
            for: scenario,
            settings: settings,
            cities: repository.cities,
            fxRates: repository.fxRates,
            sortMode: .bestStretch
        )

        XCTAssertFalse(insights.isEmpty)
        XCTAssertGreaterThanOrEqual(insights.first?.rankScore ?? 0, insights.dropFirst().first?.rankScore ?? 0)
    }

    func testClosestToCurrentPrefersHomeLikeCities() {
        let scenario = Scenario(name: "Test", salaryAmount: 120_000, cityID: "berlin-de")
        let settings = AppSettings()
        let repository = BundledDatasetRepository(bundle: Bundle(for: Self.self))

        let insights = engine.insights(
            for: scenario,
            settings: settings,
            cities: repository.cities,
            fxRates: repository.fxRates,
            sortMode: .closestToCurrent
        )

        XCTAssertEqual(insights.first?.city.id, "berlin-de")
    }
}
