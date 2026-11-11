import XCTest

/// Shared steps for the iPhone-only match UI tests. Every launch starts clean (`-uiTesting`).
extension XCTestCase {
    @MainActor
    func launchCleanApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-skipOnboarding", "-uiTesting"]
        app.launch()
        return app
    }

    /// From Match Setup: runs the match on this iPhone and kicks off the first half.
    @MainActor
    func kickOffPhoneMatch(_ app: XCUIApplication) {
        let runOnPhone = app.buttons["runMatchOnPhone"]
        XCTAssertTrue(runOnPhone.waitForExistence(timeout: 5))
        for _ in 0..<4 where !runOnPhone.isHittable { app.swipeUp() }
        runOnPhone.tap()
        tapElement(app.buttons["kickOffFirstHalf"])
    }

    /// From the first half: plays on to the full-time whistle.
    @MainActor
    func playToFullTime(_ app: XCUIApplication) {
        tapElement(app.buttons["END FIRST HALF"])
        tapElement(app.buttons["Blow for half-time"])
        tapElement(app.buttons["kickOffSecondHalf"])
        tapElement(app.buttons["END MATCH"])
        tapElement(app.buttons["Blow the whistle"])
    }

    @MainActor
    func tapElement(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing \(element)", file: file, line: line)
        element.tap()
    }

    /// Scrolls the screen up until `element` can be tapped.
    @MainActor
    func scrollTo(_ element: XCUIElement, in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing \(element)", file: file, line: line)
        for _ in 0..<8 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.isHittable, "Could not scroll to \(element)", file: file, line: line)
    }

    /// The shared match record's text (it starts "RUGBY TIMER · MATCH RECORD").
    @MainActor
    func recordBody(_ app: XCUIApplication) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'RUGBY TIMER · MATCH RECORD'")).firstMatch
    }

    @MainActor
    func attachScreenshot(_ app: XCUIApplication, named name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
