import Foundation
import Testing
@testable import RugbyTimerWatch_Watch_App

/// The Watch clock after suspension and when time runs out.
struct WatchClockTests {
    @MainActor @Test func clockCatchesUpAfterSuspension() {
        var now = Date(timeIntervalSince1970: 1_000)
        let timer = MatchTimerService(initialSeconds: 600, now: { now })
        timer.start()
        now += 125 // app suspended, no ticks delivered
        timer.refresh()
        #expect(timer.timeRemaining == 475)
        #expect(timer.isRunning)

        timer.pause()
        now += 300 // paused clock does not move
        timer.start()
        timer.refresh()
        #expect(timer.timeRemaining == 475)

        now += 1_000
        timer.refresh()
        #expect(timer.timeRemaining == 0)
        #expect(timer.overtimeSeconds == 525)
        #expect(timer.isRunning) // play continues until the ball is dead
        timer.pause()
    }

    @MainActor @Test func timeUpRunsIntoOvertimeUntilRefereeEndsHalf() async {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 600, sinBinDurationSeconds: 120
        )
        state.startMatch()
        now += 540
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        state.addCard(team: "Home", playerNum: 8, type: .yellow)

        now += 95 // 60s to time up, then 35s of overtime
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.matchPeriod == .firstHalf)
        #expect(state.timerService.isRunning)
        #expect(state.timerService.overtimeSeconds == 35)
        #expect(state.activeCards.first?.remainingSeconds == 25) // sin-bin keeps running in overtime

        state.endPeriod()
        #expect(state.matchPeriod == .halfTime)
        #expect(!state.timerService.isRunning)
        #expect(state.matchEvents.last?.description == "HALF-TIME WHISTLE")
    }
}
