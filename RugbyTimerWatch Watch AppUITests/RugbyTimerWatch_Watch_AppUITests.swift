//
//  RugbyTimerWatch_Watch_AppUITests.swift
//  RugbyTimerWatch Watch AppUITests
//
//  Created by @christhoval on 11/08/26.
//

import XCTest

final class RugbyTimerWatch_Watch_AppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testUnconfiguredWatchShowsIPhoneSetupMessage() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Set up on iPhone"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["START MATCH"].exists)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Watch requires iPhone setup"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    @MainActor
    func testLiveMatchLayoutOnSmallWatch() throws {
        let app = XCUIApplication()
        app.launch()
        if app.staticTexts["Set up on iPhone"].waitForExistence(timeout: 2) {
            throw XCTSkip("Send a match setup from iPhone before running the live-match layout test.")
        }
        let start = app.buttons["START MATCH"]
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["MATCH READY"].exists)
        XCTAssertTrue(start.isHittable)
        XCTAssertLessThanOrEqual(start.frame.maxY, app.frame.maxY - 6)
        let readyScreenshot = XCTAttachment(screenshot: app.screenshot())
        readyScreenshot.name = "Watch ready for kickoff"
        readyScreenshot.lifetime = .keepAlways
        add(readyScreenshot)
        start.tap()

        // Clock page: only the clock with elapsed and remaining time.
        let elapsed = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH %@", "ELAPSED")).firstMatch
        XCTAssertTrue(elapsed.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH %@", "REMAINING")).firstMatch.exists)
        XCTAssertLessThanOrEqual(elapsed.frame.maxY, app.frame.maxY - 6, "Clock stats must fit without scrolling")
        XCTAssertFalse(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Rangers RFC")).firstMatch.isHittable,
                       "The score lives on the Result page, not the clock page")
        let clockScreenshot = XCTAttachment(screenshot: app.screenshot())
        clockScreenshot.name = "Watch clock page"
        clockScreenshot.lifetime = .keepAlways
        add(clockScreenshot)

        // Swipe left → Score page.
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["SCORE"].waitForExistence(timeout: 5))
        let tryButton = app.buttons.containing(NSPredicate(format: "label BEGINSWITH %@", "Try scored")).firstMatch
        XCTAssertTrue(tryButton.waitForExistence(timeout: 5))
        XCTAssertTrue(tryButton.isHittable)
        XCTAssertLessThanOrEqual(tryButton.frame.maxY, app.frame.maxY - 6, "Score buttons must fit above the rounded bottom edge")
        let scoreScreenshot = XCTAttachment(screenshot: app.screenshot())
        scoreScreenshot.name = "Watch score page"
        scoreScreenshot.lifetime = .keepAlways
        add(scoreScreenshot)

        // Swipe left → Result page (last).
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["RESULT"].waitForExistence(timeout: 5))
        let home = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Rangers RFC")).firstMatch
        XCTAssertTrue(home.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(home.frame.minY, app.frame.minY + 20, "The scoreboard must clear the system clock")
        XCTAssertLessThanOrEqual(home.frame.maxX, app.frame.maxX)
        let resultScreenshot = XCTAttachment(screenshot: app.screenshot())
        resultScreenshot.name = "Watch result page"
        resultScreenshot.lifetime = .keepAlways
        add(resultScreenshot)

        // Back past Score and Clock, then swipe right → Sanctions page.
        app.swipeRight()
        app.swipeRight()
        app.swipeRight()
        XCTAssertTrue(app.staticTexts["SANCTION"].waitForExistence(timeout: 5))
        let yellow = app.buttons.containing(NSPredicate(format: "label BEGINSWITH %@", "Yellow card")).firstMatch
        XCTAssertTrue(yellow.waitForExistence(timeout: 5))
        let sanctionsScreenshot = XCTAttachment(screenshot: app.screenshot())
        sanctionsScreenshot.name = "Watch sanctions page"
        sanctionsScreenshot.lifetime = .keepAlways
        add(sanctionsScreenshot)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
