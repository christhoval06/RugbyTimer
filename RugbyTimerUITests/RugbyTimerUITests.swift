//
//  RugbyTimerUITests.swift
//  RugbyTimerUITests
//
//  Created by @christhoval on 11/08/26.
//

import XCTest

final class RugbyTimerUITests: XCTestCase {

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
    func testSetupPreparesMatchWithoutStartingOnPhone() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-skipOnboarding", "-uiTesting"]
        app.launch()
        let sendSetup = app.buttons["sendMatchSetup"]
        XCTAssertTrue(sendSetup.waitForExistence(timeout: 5))
        XCTAssertTrue(sendSetup.isHittable, "The setup action should remain visible without scrolling")
        let topScreenshot = XCTAttachment(screenshot: app.screenshot())
        topScreenshot.name = "iPhone setup overview"
        topScreenshot.lifetime = .keepAlways
        add(topScreenshot)
        let actionY = sendSetup.frame.minY
        app.swipeUp()
        XCTAssertEqual(sendSetup.frame.minY, actionY, accuracy: 1, "The send action must stay pinned while scrolling")
        XCTAssertTrue(sendSetup.isHittable)
        let rulesScreenshot = XCTAttachment(screenshot: app.screenshot())
        rulesScreenshot.name = "iPhone setup rules and pinned action"
        rulesScreenshot.lifetime = .keepAlways
        add(rulesScreenshot)
        for _ in 0..<4 where !sendSetup.isHittable { app.swipeUp() }
        XCTAssertTrue(sendSetup.waitForExistence(timeout: 5))
        sendSetup.tap()
        XCTAssertTrue(app.staticTexts["Start the match on Apple Watch"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["PRE-MATCH"].exists)
        XCTAssertFalse(app.buttons["CARD"].exists)
        XCTAssertFalse(app.buttons["SCORE"].exists)
        XCTAssertFalse(app.buttons["KICK OFF H2"].exists)
    }

    @MainActor
    func testSetupWidgetsKeepCustomDurations() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-skipOnboarding", "-uiTesting"]
        app.launch()

        let customDuration = app.buttons["customMatchDuration"]
        // The format grid is lazy: the tile only exists once it scrolls near the screen.
        XCTAssertTrue(app.buttons["sendMatchSetup"].waitForExistence(timeout: 5))
        for _ in 0..<4 where !customDuration.exists || !customDuration.isHittable { app.swipeUp() }
        XCTAssertTrue(customDuration.waitForExistence(timeout: 5))
        customDuration.tap()
        let halfLengthAlert = app.alerts["Custom Half-Length"]
        XCTAssertTrue(halfLengthAlert.waitForExistence(timeout: 5))
        let halfLength = halfLengthAlert.textFields.firstMatch
        halfLength.tap()
        halfLength.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: (halfLength.value as? String ?? "").count) + "35")
        halfLengthAlert.buttons["Set Duration"].tap()
        XCTAssertTrue(customDuration.label.contains("35"))

        let sinBinDuration = app.buttons["Sin-bin duration"]
        for _ in 0..<3 where !sinBinDuration.isHittable { app.swipeUp() }
        sinBinDuration.tap()
        app.buttons["Custom…"].tap()
        let sinBinAlert = app.alerts["Custom Sin-Bin Duration"]
        XCTAssertTrue(sinBinAlert.waitForExistence(timeout: 5))
        let sinBinMinutes = sinBinAlert.textFields.firstMatch
        sinBinMinutes.tap()
        sinBinMinutes.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: (sinBinMinutes.value as? String ?? "").count) + "3")
        sinBinAlert.buttons["Set Duration"].tap()
        XCTAssertEqual(sinBinDuration.value as? String, "3 minutes")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
