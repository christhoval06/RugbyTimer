import Foundation
import Testing
@testable import RugbyTimerWatch_Watch_App

/// Moving through the halves: kick-off, half-time and full time.
struct WatchPeriodTests {
    @MainActor @Test func watchAdvancesBothHalves() {
        let state = AppState()
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400
        )
        state.startMatch()
        state.handleTimerExpired()
        #expect(state.matchPeriod == .halfTime)
        #expect(!state.timerService.isRunning)
        state.startSecondHalf()
        #expect(state.matchPeriod == .secondHalf)
        #expect(state.timerService.isRunning)
        state.handleTimerExpired()
        #expect(state.matchPeriod == .fullTime)
        #expect(!state.timerService.isRunning)
    }

    @MainActor @Test func secondHalfOnlyStartsFromHalfTime() {
        let state = AppState()
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400
        )
        state.startSecondHalf()
        #expect(state.matchPeriod == .preMatch)
        state.startMatch()
        state.startSecondHalf()
        #expect(state.matchPeriod == .firstHalf)
        state.timerService.pause()
    }

    @MainActor @Test func startMatchTwiceDoesNotRestartClock() {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400
        )
        state.startMatch()
        now += 100
        state.startMatch()
        state.timerService.refresh()
        #expect(state.timerService.timeRemaining == 2300)
        state.timerService.pause()
    }

    @MainActor @Test func timeUpDuringHalfTimeDoesNotChangePeriod() {
        let state = AppState()
        state.matchPeriod = .halfTime
        state.handleTimeUp()
        #expect(state.matchPeriod == .halfTime)
    }

    @MainActor @Test func endingSecondHalfInOvertimeGoesToFullTime() async {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 300
        )
        state.startMatch()
        state.endPeriod()
        state.startSecondHalf()
        now += 330
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.matchPeriod == .secondHalf)
        #expect(state.timerService.overtimeSeconds == 30)
        state.endPeriod()
        #expect(state.matchPeriod == .fullTime)
        #expect(state.matchEvents.map(\.description).suffix(2) == ["HALF-TIME WHISTLE", "FULL-TIME WHISTLE"])
    }
}
