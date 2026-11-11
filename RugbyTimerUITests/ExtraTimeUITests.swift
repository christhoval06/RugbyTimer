import XCTest

/// iPhone-only mode: a match level at full time goes to extra time when it's turned on.
final class ExtraTimeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLevelMatchPlaysExtraTimeThenEndsAsADraw() throws {
        let app = launchCleanApp()

        // Match Setup: Extra time → Fifteens (2 × 10 min, then sudden death).
        let picker = app.buttons["setup.extraTime.picker"]
        scrollTo(picker, in: app)
        picker.tap()
        tapElement(app.buttons["Fifteens"])
        XCTAssertTrue(app.staticTexts["2 × 10 min, then sudden death"].waitForExistence(timeout: 5))

        kickOffPhoneMatch(app)
        playToFullTime(app)

        // 0–0 at full time: extra time, not full time.
        tapElement(app.buttons["kickOffExtraTime"])
        XCTAssertTrue(periodLabel("EXTRA TIME · ET1", in: app).waitForExistence(timeout: 5))
        tapElement(app.buttons["END ET1"])
        tapElement(app.buttons["Blow for half-time"])

        tapElement(app.buttons["kickOffExtraTime"])
        XCTAssertTrue(periodLabel("EXTRA TIME · ET2", in: app).waitForExistence(timeout: 5))
        tapElement(app.buttons["END EXTRA TIME"])
        tapElement(app.buttons["Blow the whistle"])

        // Still level after extra time: sudden death is next, or end it as a draw.
        XCTAssertTrue(app.buttons["kickOffExtraTime"].waitForExistence(timeout: 5))
        attachScreenshot(app, named: "Extra-time break before sudden death")
        tapElement(app.buttons["END AS A DRAW"])
        tapElement(app.buttons["End the match"])

        XCTAssertTrue(app.buttons["shareMatchRecord"].waitForExistence(timeout: 5), "The match should be at full time")
        XCTAssertFalse(app.buttons["kickOffExtraTime"].exists)
    }

    /// The clock ring reads its period label as part of one accessibility label.
    @MainActor
    private func periodLabel(_ text: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }
}
