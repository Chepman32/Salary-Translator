import XCTest
@testable import Paylo

final class PayloDataTests: XCTestCase {
    func testBundledDatasetsDecode() {
        let repository = BundledDatasetRepository(bundle: Bundle(for: Self.self))

        XCTAssertGreaterThanOrEqual(repository.cities.count, 50)
        XCTAssertGreaterThanOrEqual(repository.objectCatalog.count, 14)
        XCTAssertEqual(repository.fxRates.base, "USD")
        XCTAssertNotNil(repository.fxRates.rates["EUR"])
    }
}
