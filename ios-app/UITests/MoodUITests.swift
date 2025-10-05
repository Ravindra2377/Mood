import XCTest

final class MoodUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testSaveMoodAndNavigateToHistory() throws {
        let saveButton = app.buttons["saveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))

        // Enter a note
        let note = app.textViews["moodNote"]
        if note.exists {
            note.tap()
            note.typeText("UI test note")
        }

        // Save
        saveButton.tap()

        // Wait a bit for save to complete
        sleep(1)

        // Go to History tab
        let historyTab = app.tabBars.buttons["History"]
        XCTAssertTrue(historyTab.exists)
        historyTab.tap()

        // Check that at least one history row exists
        let firstRow = app.otherElements.matching(identifier: "historyRow_").firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
    }
}
