import XCTest

final class PayloUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingIntoMainWorkspace() {
        let app = launchApp()

        XCTAssertTrue(app.textFields["salary_input_field"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["open_settings_button"].exists)
        XCTAssertTrue(app.buttons["open_library_button"].exists)
    }

    @MainActor
    func testSwitchingInputModesKeepsCanonicalSalaryStable() {
        let app = launchApp()
        let salaryField = app.textFields["salary_input_field"]

        XCTAssertTrue(salaryField.waitForExistence(timeout: 2))

        let annualValue = salaryField.value as? String ?? ""
        XCTAssertFalse(annualValue.isEmpty)

        app.buttons["Hourly"].tap()

        let hourlyValue = salaryField.value as? String ?? ""
        XCTAssertNotEqual(hourlyValue, annualValue)

        app.buttons["Annual"].tap()

        let finalAnnualValue = salaryField.value as? String ?? ""
        XCTAssertEqual(finalAnnualValue, annualValue)
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing-reset", "-skip-splash"]
        app.launch()

        if app.buttons["Continue"].waitForExistence(timeout: 2) {
            app.buttons["Continue"].tap()
            app.buttons["Continue"].tap()
            app.buttons["Continue"].tap()
            app.buttons["Translate My Salary"].tap()
        }

        return app
    }
}
