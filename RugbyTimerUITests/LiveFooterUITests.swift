import XCTest

final class LiveFooterUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLiveControlsHideOnSwipeUpAndReturnOnSwipeDown() {
        let app = launchCleanApp()
        kickOffPhoneMatch(app)
        defer { XCUIDevice.shared.orientation = .portrait }

        verifySwipeBehavior(in: app)

        XCUIDevice.shared.orientation = .landscapeLeft
        verifySwipeBehavior(in: app)
    }

    @MainActor
    private func verifySwipeBehavior(in app: XCUIApplication) {
        let controls = app.buttons["END FIRST HALF"]
        let details = app.scrollViews.firstMatch
        let title = app.staticTexts["LIVE MATCH"]
        let initialTitleY = title.exists ? title.frame.minY : nil
        XCTAssertTrue(controls.waitForExistence(timeout: 5))
        XCTAssertTrue(controls.isHittable)

        details.swipeUp()
        XCTAssertTrue(controls.waitForNonExistence(timeout: 3))
        if let initialTitleY {
            XCTAssertLessThan(title.frame.minY, initialTitleY, "The swipe should also scroll the match details")
        }

        details.swipeDown()
        XCTAssertTrue(controls.waitForExistence(timeout: 3))
        XCTAssertTrue(controls.isHittable)
    }
}
