import XCTest
@testable import RugbyTimer

/// Overtime and Watch mirroring: the clock counts up past zero until the referee ends the half.
final class MatchTimerOvertimeTests: XCTestCase {
    private var clock: TestClock!

    override func setUp() {
        clock = TestClock()
    }

    private func makeTimer(_ seconds: Int) -> MatchTimerService {
        MatchTimerService(initialSeconds: seconds, now: { [clock] in clock!.now })
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
