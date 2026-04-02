import XCTest

final class ScreenshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCaptureAllScreens() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing-reset", "-skip-splash"]
        setupSnapshot(app)
        app.launch()

        // Handle onboarding if present
        if app.buttons["Continue"].waitForExistence(timeout: 3) {
            app.buttons["Continue"].tap()
            app.buttons["Continue"].tap()
            app.buttons["Continue"].tap()
            app.buttons["Translate My Salary"].tap()
        }

        // Wait for main workspace
        let salaryField = app.textFields["salary_input_field"]
        XCTAssertTrue(salaryField.waitForExistence(timeout: 5))

        // Enter a real salary so data is visible
        salaryField.tap()
        salaryField.clearAndType("75000")
        app.keyboards.buttons["Return"].tap()

        // Small pause for UI to settle
        _ = app.wait(for: .runningForeground, timeout: 1)

        // 1. Hero: main workspace showing salary input + pace strip
        snapshot("01_hero")

        // 2. Live Canvas
        let liveTab = app.buttons["Live"]
        if liveTab.waitForExistence(timeout: 2) { liveTab.tap() }
        _ = app.wait(for: .runningForeground, timeout: 1)
        snapshot("02_live")

        // 3. Objects Canvas
        let objectsTab = app.buttons["Objects"]
        if objectsTab.waitForExistence(timeout: 2) { objectsTab.tap() }
        _ = app.wait(for: .runningForeground, timeout: 1)
        snapshot("03_objects")

        // 4. Work Canvas
        let workTab = app.buttons["Work"]
        if workTab.waitForExistence(timeout: 2) { workTab.tap() }
        _ = app.wait(for: .runningForeground, timeout: 1)
        snapshot("04_work")

        // 5. Cities Canvas
        let citiesTab = app.buttons["Cities"]
        if citiesTab.waitForExistence(timeout: 2) { citiesTab.tap() }
        _ = app.wait(for: .runningForeground, timeout: 1)
        snapshot("05_cities")

        // 6. Gap Canvas
        let gapTab = app.buttons["Gap"]
        if gapTab.waitForExistence(timeout: 2) { gapTab.tap() }
        _ = app.wait(for: .runningForeground, timeout: 1)
        snapshot("06_gap")
    }
}

private extension XCUIElement {
    func clearAndType(_ text: String) {
        guard let currentValue = value as? String, !currentValue.isEmpty else {
            typeText(text)
            return
        }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        typeText(deleteString)
        typeText(text)
    }
}
