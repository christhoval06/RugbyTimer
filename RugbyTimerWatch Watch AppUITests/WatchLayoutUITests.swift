import XCTest

final class WatchLayoutUITests: XCTestCase {
    @MainActor
    func testQuickMatchOffersIndependentDisplayToggles() {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-settings.appLanguage", "en", "-skipOnboarding", "-uiTesting"]
        app.launch()

        let quickMatch = app.buttons["QUICK MATCH"]
        XCTAssertTrue(quickMatch.waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["Watch display settings"].exists)
        reveal(quickMatch, in: app)
        quickMatch.tap()

        let extended = app.switches["Extended layout"]
        let discipline = app.switches["Show penalties and sanctions"]
        XCTAssertTrue(extended.waitForExistence(timeout: 5))
        XCTAssertTrue(discipline.exists)
        let originalDiscipline = discipline.value as? String
        let originalLayout = extended.value as? String
        extended.tap()
        XCTAssertNotEqual(extended.value as? String, originalLayout)
        XCTAssertEqual(discipline.value as? String, originalDiscipline)
        extended.tap()
        discipline.tap()
        XCTAssertNotEqual(discipline.value as? String, originalDiscipline)
        XCTAssertEqual(extended.value as? String, originalLayout)
        discipline.tap()
    }

    @MainActor
    func testExtendedLayoutSwipesBetweenTeamsAndCenterPages() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(en)", "-settings.appLanguage", "en", "-skipOnboarding", "-uiTesting",
            "-watchExtendedLayout", "YES", "-watchShowDiscipline", "YES"
        ]
        app.launch()

        let clock = app.buttons.containing(NSPredicate(format: "label BEGINSWITH %@", "FIRST HALF")).firstMatch
        let quickMatch = app.buttons["QUICK MATCH"]
        if quickMatch.waitForExistence(timeout: 5) {
            quickMatch.tap()
            scrollQuickMatchToBottom(in: app)
            let ready = app.buttons["READY"]
            reveal(ready, in: app)
            ready.tap()
            app.buttons["START MATCH"].tap()
        }
        XCTAssertTrue(clock.waitForExistence(timeout: 5))

        app.swipeRight()
        XCTAssertTrue(app.staticTexts["Team B"].isHittable)
        XCTAssertTrue(heading("SCORE", in: app).isHittable)
        app.swipeRight()
        XCTAssertTrue(heading("PENALTIES", in: app).isHittable)
        app.swipeRight()
        XCTAssertTrue(heading("SANCTIONS", in: app).isHittable)
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        XCTAssertTrue(clock.isHittable)
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["Team A"].isHittable)
        XCTAssertTrue(heading("SCORE", in: app).isHittable)
        app.swipeRight()
        XCTAssertTrue(clock.isHittable)

        reveal(heading("TIME DETAILS", in: app), in: app)
        reveal(heading("ACTIVE TIMERS", in: app), in: app)
        reveal(heading("RESULT", in: app), in: app)
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["Team A"].isHittable)
        app.swipeRight()
        let returnToClock = app.buttons["MATCH CLOCK"]
        reveal(returnToClock, in: app)
        returnToClock.tap()
        XCTAssertTrue(clock.isHittable)
        finishQuickMatch(in: app)
    }

    @MainActor
    private func heading(_ title: String, in app: XCUIApplication) -> XCUIElement {
        app.staticTexts.containing(NSPredicate(format: "label ENDSWITH %@", title)).firstMatch
    }

    @MainActor
    private func finishQuickMatch(in app: XCUIApplication) {
        reveal(heading("TIME DETAILS", in: app), in: app)
        let endEarly = app.buttons.containing(NSPredicate(format: "label CONTAINS[cd] %@", "End match early")).firstMatch
        XCTAssertTrue(endEarly.isHittable)
        guard endEarly.isHittable else { return }
        endEarly.press(forDuration: 0.7)
        app.buttons["End match"].tap()

        let finalResult = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH %@", "FINAL")).firstMatch
        XCTAssertTrue(finalResult.waitForExistence(timeout: 5))
        let newMatch = app.buttons["NEW MATCH"]
        reveal(newMatch, in: app)
        guard newMatch.isHittable else { return }
        newMatch.tap()
        app.buttons["New match"].tap()
    }

    @MainActor
    private func scrollQuickMatchToBottom(in app: XCUIApplication) {
        for _ in 0..<4 { app.swipeUp() }
    }

    @MainActor
    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 where !element.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }
}
