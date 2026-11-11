import XCTest

/// A finished match shows up in Match History, opens its record, and can be deleted.
final class MatchHistoryUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFinishedMatchIsKeptInHistoryAndCanBeDeleted() throws {
        let app = launchCleanApp()

        // An empty history to start with (each UI test launch starts clean).
        tapElement(app.buttons["openHistory"])
        XCTAssertTrue(app.staticTexts["NO MATCHES YET"].waitForExistence(timeout: 5))
        tapElement(app.buttons["closeHistory"])

        kickOffPhoneMatch(app)
        tapElement(app.buttons["SCORE"])
        tapElement(app.buttons["scoreTRY"]) // a try for the home side
        playToFullTime(app)

        let backToSetup = app.buttons["returnToMatchSetup"]
        scrollTo(backToSetup, in: app)
        backToSetup.tap()
        tapElement(app.buttons["openHistory"])

        let row = app.buttons["history.row"]
        XCTAssertTrue(row.waitForExistence(timeout: 5), "The finished match should be in the history")
        XCTAssertTrue(row.label.hasPrefix("Rangers RFC 5, City Lions 0"), "Unexpected row: \(row.label)")
        attachScreenshot(app, named: "Match history")

        row.tap()
        XCTAssertTrue(recordBody(app).waitForExistence(timeout: 5), "The match record should open")
        tapElement(app.buttons["closeMatchRecord"])

        row.swipeLeft()
        tapElement(app.buttons["Delete"])
        XCTAssertTrue(app.staticTexts["NO MATCHES YET"].waitForExistence(timeout: 5))
    }
}
