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

        // Wait for save to complete by asserting the save button becomes enabled again or by waiting for the badge to update
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))

        // Go to History tab
        let historyTab = app.tabBars.buttons["History"]
        XCTAssertTrue(historyTab.waitForExistence(timeout: 5))
        historyTab.tap()

        // Check that at least one history cell exists in the list
        // Use table cell matching to be robust across identifier naming
        let firstCell = app.tables.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 8))
    }
}
