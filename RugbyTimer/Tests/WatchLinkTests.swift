import XCTest
@testable import RugbyTimer

/// The iPhone mirror while the Watch is out of range: the clock and sin-bins keep counting,
/// and the live screen warns that the Watch stopped reporting.
final class WatchLinkTests: XCTestCase {
    private var clock: TestClock!

    override func setUp() {
        clock = TestClock()
    }

    private func makeTimer(_ seconds: Int) -> MatchTimerService {
        MatchTimerService(initialSeconds: seconds, now: { [clock] in clock!.now })
    }

    private func snapshot(id: UUID = UUID(), remaining: Int, running: Bool, endDate: Date?,
                          cards: [MatchCard] = []) -> MatchSnapshot {
        MatchSnapshot(
            updatedAt: clock.now, matchID: id, home: "Home", away: "Away", duration: 2400,
            period: .firstHalf, remaining: remaining, isRunning: running,
            homeScore: 0, awayScore: 0, cards: cards, clockEndDate: endDate
        )
    }

    func testMirroredClockKeepsCountingFromWatchEndDate() {
        let timer = makeTimer(2400)
        timer.displayWatchTime(remaining: 1000, isRunning: true, endDate: clock.now + 1000)
        clock.advance(42)
        timer.refresh()
        XCTAssertEqual(timer.timeRemaining, 958, "The phone clock must not freeze without Watch updates")
        clock.advance(1000)
        timer.refresh()
        XCTAssertEqual(timer.overtimeSeconds, 42)
    }

    func testMirroredClockStopsWhenWatchPauses() {
        let timer = makeTimer(2400)
        timer.displayWatchTime(remaining: 1000, isRunning: true, endDate: clock.now + 1000)
        timer.displayWatchTime(remaining: 990, isRunning: false, endDate: nil)
        clock.advance(30)
        timer.refresh()
        XCTAssertEqual(timer.timeRemaining, 990)
        XCTAssertFalse(timer.isRunning)
        XCTAssertNil(timer.endDate)
    }

    func testSnapshotWithoutEndDateStillRunsFromSendTime() {
        let state = AppState(timerService: makeTimer(2400))
        state.applyWatchSnapshot(snapshot(remaining: 1000, running: true, endDate: nil))
        clock.advance(10)
        state.timerService.refresh()
        XCTAssertEqual(state.timerService.timeRemaining, 990)
    }

    func testMirroredSinBinFollowsClockWithoutDrift() {
        let state = AppState(timerService: makeTimer(2400))
        let card = MatchCard(teamName: "Home", playerNumber: 8, type: .yellow, durationSeconds: 300)
        let id = UUID()
        state.applyWatchSnapshot(snapshot(id: id, remaining: 1000, running: true,
                                          endDate: clock.now + 1000, cards: [card]))
        clock.advance(60)
        state.timerService.refresh()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        XCTAssertEqual(state.activeCards.first?.remainingSeconds, 240)
    }

    func testLinkLostAfterSilenceWhileClockRuns() {
        let status = WatchLinkStatus(isReachable: true, lastSyncAt: clock.now, isClockRunning: true)
        XCTAssertFalse(status.isLost(at: clock.now + 3))
        XCTAssertTrue(status.isLost(at: clock.now + 6))
        XCTAssertEqual(status.secondsSinceSync(at: clock.now + 42), 42)
    }

    func testPausedClockOnlyLostWhenUnreachable() {
        let reachable = WatchLinkStatus(isReachable: true, lastSyncAt: clock.now, isClockRunning: false)
        XCTAssertFalse(reachable.isLost(at: clock.now + 120), "A paused Watch goes quiet on purpose")
        let gone = WatchLinkStatus(isReachable: false, lastSyncAt: clock.now, isClockRunning: false)
        XCTAssertTrue(gone.isLost(at: clock.now + 120))
    }

    func testNoWatchStatusWithoutMatchOrInPhoneOnlyMode() {
        let state = AppState()
        XCTAssertNil(state.watchLinkStatus, "No match set up yet")
        state.prepareMatch(onPhone: true)
        XCTAssertNil(state.watchLinkStatus)
    }
}
