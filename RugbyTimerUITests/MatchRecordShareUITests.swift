import XCTest

/// The full-time record sheet must always open with the record text, never blank.
final class MatchRecordShareUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMatchRecordSheetIsNeverEmpty() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-skipOnboarding", "-uiTesting"]
        app.launch()
        playPhoneMatchToFullTime(app)

        let share = app.buttons["shareMatchRecord"]
        XCTAssertTrue(share.waitForExistence(timeout: 5))
        for attempt in 1...5 {
            share.tap()
            // The sheet's own Done button proves the sheet is open (the live screen also says "RUGBY TIMER").
            let close = app.buttons["closeMatchRecord"]
            XCTAssertTrue(close.waitForExistence(timeout: 5), "Sheet did not open on attempt \(attempt)")
            XCTAssertTrue(recordBody(app).waitForExistence(timeout: 2), "Record text was empty on attempt \(attempt)")
            close.tap()
            XCTAssertTrue(close.waitForNonExistence(timeout: 5), "Sheet did not close on attempt \(attempt)")
            XCTAssertTrue(share.waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testMatchRecordSheetSurvivesRotation() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-skipOnboarding", "-uiTesting"]
        app.launch()
        playPhoneMatchToFullTime(app)
        defer { XCUIDevice.shared.orientation = .portrait }

        tap(app.buttons["shareMatchRecord"])
        let record = recordBody(app)
        XCTAssertTrue(record.waitForExistence(timeout: 5))
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(record.waitForExistence(timeout: 5), "Record text was lost after rotating to landscape")
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(record.waitForExistence(timeout: 5), "Record text was lost after rotating back")
    }

    @MainActor
    func testLandscapeFullTimeShowsResultAndShareOnLeft() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-skipOnboarding", "-uiTesting"]
        app.launch()
        playPhoneMatchToFullTime(app)
        defer { XCUIDevice.shared.orientation = .portrait }

        XCUIDevice.shared.orientation = .landscapeLeft
        let result = app.otherElements.matching(NSPredicate(format: "label BEGINSWITH 'Full time:'")).firstMatch
        let share = app.buttons["shareMatchRecord"]
        XCTAssertTrue(result.waitForExistence(timeout: 5), "Final result is missing in landscape")
        XCTAssertTrue(share.waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons.matching(identifier: "shareMatchRecord").count, 1, "Share should appear once")
        let midX = app.windows.firstMatch.frame.midX
        XCTAssertLessThan(share.frame.maxX, midX, "Share button should be in the left column")
        XCTAssertLessThan(share.frame.minY, result.frame.maxY + 40, "Share button should sit under the result")

        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "Landscape full time"
        shot.lifetime = .keepAlways
        add(shot)

        share.tap()
        XCTAssertTrue(recordBody(app).waitForExistence(timeout: 5))
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
        tap(app.buttons["Blow the whistle"])
    }

    @MainActor
    private func tap(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing \(element)")
        element.tap()
    }
}
