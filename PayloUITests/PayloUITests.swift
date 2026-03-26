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
    func testQuickPresetLabelsFollowSelectedInputMode() {
        let app = launchApp()
        let firstPreset = app.buttons["quick_preset_0"]

        XCTAssertTrue(firstPreset.waitForExistence(timeout: 2))

        let annualLabel = firstPreset.label
        XCTAssertTrue(annualLabel.contains("30"))

        app.buttons["Hourly"].tap()

        let hourlyLabel = firstPreset.label
        XCTAssertNotEqual(hourlyLabel, annualLabel)
        XCTAssertTrue(hourlyLabel.contains("10"))
        XCTAssertTrue(app.buttons["quick_preset_1"].label.contains("15"))
        XCTAssertTrue(app.buttons["quick_preset_2"].label.contains("20"))
        XCTAssertTrue(app.buttons["quick_preset_3"].label.contains("25"))
        XCTAssertTrue(app.buttons["quick_preset_4"].label.contains("30"))
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
