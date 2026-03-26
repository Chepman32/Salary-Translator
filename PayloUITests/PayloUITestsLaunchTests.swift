import XCTest

final class PayloUITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing-reset", "-skip-splash"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2))
    }
}
