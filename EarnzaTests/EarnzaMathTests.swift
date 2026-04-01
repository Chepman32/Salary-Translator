import XCTest
@testable import Earnza

final class EarnzaMathTests: XCTestCase {
    private let engine = DefaultSalaryTranslationEngine()

    func testPaceSummaryUsesWorkAssumptions() {
        let scenario = Scenario(
            name: "Test",
            salaryAmount: 104_000,
            workHoursPerWeek: 40,
            workWeeksPerYear: 52,
            paychecksPerYear: 26
        )
        let settings = AppSettings()

        let pace = engine.paceSummary(for: scenario, settings: settings)

        XCTAssertEqual(pace.monthly, 8666.6667, accuracy: 0.01)
        XCTAssertEqual(pace.hourly, 50.0, accuracy: 0.01)
        XCTAssertEqual(pace.paycheck, 4000, accuracy: 0.01)
    }

    func testTakeHomeOverrideBecomesCanonicalBasis() {
        let scenario = Scenario(name: "Test", salaryAmount: 120_000, manualTakeHomeAnnual: 84_000)
        let settings = AppSettings(selectedIncomeBasis: .takeHome)

        let annual = engine.annualIncome(for: scenario, settings: settings)

        XCTAssertEqual(annual, 84_000, accuracy: 0.01)
    }

    func testComparatorInsightProducesRatio() {
        let scenario = Scenario(
            name: "Gap",
            salaryAmount: 100_000,
            workHoursPerWeek: 40,
            workWeeksPerYear: 50,
            comparatorSalary: 200_000,
            comparatorLabel: "Boss"
        )
        let settings = AppSettings()

        let insight = engine.comparatorInsight(for: scenario, settings: settings)

        XCTAssertNotNil(insight)
        XCTAssertEqual(insight?.ratio ?? 0, 2.0, accuracy: 0.01)
        XCTAssertEqual(insight?.deltaPerHour ?? 0, 50.0, accuracy: 0.01)
    }
}
