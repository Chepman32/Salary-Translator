import XCTest

final class PayloUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingIntoMainWorkspace() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing-reset", "-skip-splash"]
        app.launch()

        if app.buttons["Continue"].waitForExistence(timeout: 2) {
            app.buttons["Continue"].tap()
            app.buttons["Continue"].tap()
            app.buttons["Continue"].tap()
            app.buttons["Translate My Salary"].tap()
        }

        XCTAssertTrue(app.textFields["salary_input_field"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["open_settings_button"].exists)
        XCTAssertTrue(app.buttons["open_library_button"].exists)
    }
}
