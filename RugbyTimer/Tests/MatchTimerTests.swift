//
//  MatchTimerTests.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import XCTest
@testable import RugbyTimer

/// A clock the tests move by hand, so timer behaviour is checked without sleeping.
final class TestClock {
    var now = Date(timeIntervalSince1970: 1_000)
    func advance(_ seconds: TimeInterval) { now += seconds }
}

final class MatchTimerTests: XCTestCase {
    private var clock: TestClock!

    override func setUp() {
        clock = TestClock()
    }

    private func makeTimer(_ seconds: Int) -> MatchTimerService {
        MatchTimerService(initialSeconds: seconds, now: { [clock] in clock!.now })
    }

    func testTimerInitialization() {
        let timer = makeTimer(2400)
        XCTAssertEqual(timer.timeRemaining, 2400)
        XCTAssertEqual(timer.clockSeconds, 2400)
        XCTAssertEqual(timer.overtimeSeconds, 0)
        XCTAssertFalse(timer.isRunning)
        XCTAssertFalse(timer.isInOvertime)
        XCTAssertNil(timer.endDate)
    }

    func testStartSetsEndDateFromRemainingTime() {
        let timer = makeTimer(600)
        timer.start()
        XCTAssertTrue(timer.isRunning)
        XCTAssertEqual(timer.endDate, clock.now.addingTimeInterval(600))
        timer.pause()
    }

    func testStartTwiceKeepsOriginalEndDate() {
        let timer = makeTimer(600)
        timer.start()
        let endDate = timer.endDate
        clock.advance(10)
        timer.start()
        XCTAssertEqual(timer.endDate, endDate)
        timer.pause()
    }

    func testRefreshCountsDownFromWallClock() {
        let timer = makeTimer(600)
        timer.start()
        clock.advance(125)
        timer.refresh()
        XCTAssertEqual(timer.timeRemaining, 475)
        XCTAssertTrue(timer.isRunning)
        timer.pause()
    }

    func testPartialSecondsRoundUp() {
        let timer = makeTimer(10)
        timer.start()
        clock.advance(2.1)
        timer.refresh()
        XCTAssertEqual(timer.timeRemaining, 8)
        timer.pause()
    }

    func testPauseFreezesClockAndResumeContinuesFromThere() {
        let timer = makeTimer(600)
        timer.start()
        clock.advance(100)
        timer.pause()
        XCTAssertEqual(timer.timeRemaining, 500)
        XCTAssertFalse(timer.isRunning)
        XCTAssertNil(timer.endDate)

        clock.advance(300) // time off
        timer.refresh()
        XCTAssertEqual(timer.timeRemaining, 500)

        timer.start()
        clock.advance(50)
        timer.refresh()
        XCTAssertEqual(timer.timeRemaining, 450)
        timer.pause()
    }

    func testClockRunsIntoOvertimeInsteadOfStopping() {
        let timer = makeTimer(60)
        timer.start()
        clock.advance(97)
        timer.refresh()
        XCTAssertTrue(timer.isRunning)
        XCTAssertTrue(timer.isInOvertime)
        XCTAssertEqual(timer.timeRemaining, 0)
        XCTAssertEqual(timer.overtimeSeconds, 37)
        XCTAssertEqual(timer.clockSeconds, -37)
        timer.pause()
    }

    func testPausedOvertimeResumesCountingUp() {
        let timer = makeTimer(10)
        timer.start()
        clock.advance(15)
        timer.pause()
        XCTAssertEqual(timer.overtimeSeconds, 5)
        clock.advance(60)
        timer.start()
        clock.advance(5)
        timer.refresh()
        XCTAssertEqual(timer.overtimeSeconds, 10)
        timer.pause()
    }

    func testResetClearsOvertimeAndStops() {
        let timer = makeTimer(10)
        timer.start()
        clock.advance(30)
        timer.refresh()
        timer.reset(to: 2400)
        XCTAssertEqual(timer.timeRemaining, 2400)
        XCTAssertEqual(timer.overtimeSeconds, 0)
        XCTAssertFalse(timer.isRunning)
        XCTAssertNil(timer.endDate)
    }

    func testDisplayWatchTimeMirrorsSignedClockWithoutTicking() {
        let timer = makeTimer(2400)
        timer.displayWatchTime(remaining: -42, isRunning: true)
        XCTAssertTrue(timer.isRunning)
        XCTAssertEqual(timer.overtimeSeconds, 42)
        XCTAssertNil(timer.endDate)
        clock.advance(30)
        timer.refresh()
        XCTAssertEqual(timer.overtimeSeconds, 42, "The phone must not run its own clock")
    }

    func testRealTimerTicksOnMainRunLoop() {
        let timer = MatchTimerService(initialSeconds: 10)
        timer.start()
        let ticked = expectation(description: "Countdown tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            XCTAssertLessThanOrEqual(timer.timeRemaining, 9)
            timer.pause()
            ticked.fulfill()
        }
        wait(for: [ticked], timeout: 3.0)
    }
}
