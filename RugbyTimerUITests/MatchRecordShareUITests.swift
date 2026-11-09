import XCTest

/// The full-time record sheet must always open with the record text, never blank.
final class MatchRecordShareUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMatchRecordSheetIsNeverEmpty() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-skipOnboarding")
        app.launch()
        playPhoneMatchToFullTime(app)

        let share = app.buttons["shareMatchRecord"]
        XCTAssertTrue(share.waitForExistence(timeout: 5))
        for attempt in 1...5 {
            share.tap()
            let record = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'MATCH RECORD'")).element(boundBy: 0)
            let recordBody = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'RUGBY TIMER'")).firstMatch
            XCTAssertTrue(record.waitForExistence(timeout: 5), "Sheet did not open on attempt \(attempt)")
            XCTAssertTrue(recordBody.waitForExistence(timeout: 2), "Record text was empty on attempt \(attempt)")
            app.buttons["Done"].tap()
            XCTAssertTrue(share.waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testMatchRecordSheetSurvivesRotation() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-skipOnboarding")
        app.launch()
        playPhoneMatchToFullTime(app)
        defer { XCUIDevice.shared.orientation = .portrait }

        tap(app.buttons["shareMatchRecord"])
        let recordBody = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'RUGBY TIMER'")).firstMatch
        XCTAssertTrue(recordBody.waitForExistence(timeout: 5))
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(recordBody.waitForExistence(timeout: 5), "Record text was lost after rotating to landscape")
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(recordBody.waitForExistence(timeout: 5), "Record text was lost after rotating back")
    }

    @MainActor
    private func playPhoneMatchToFullTime(_ app: XCUIApplication) {
        let runOnPhone = app.buttons["runMatchOnPhone"]
        XCTAssertTrue(runOnPhone.waitForExistence(timeout: 5))
        for _ in 0..<4 where !runOnPhone.isHittable { app.swipeUp() }
        runOnPhone.tap()

        tap(app.buttons["kickOffFirstHalf"])
        tap(app.buttons["END FIRST HALF"])
        tap(app.buttons["Blow for half-time"])
        tap(app.buttons["kickOffSecondHalf"])
        tap(app.buttons["END MATCH"])
        tap(app.buttons["Blow for full time"])
    }

    @MainActor
    private func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing \(element)")
        element.tap()
    }
}
