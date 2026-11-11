import Foundation
import Testing
@testable import RugbyTimerWatch_Watch_App

/// Sin-bins follow the match clock: they stop when it stops and carry over at half-time.
struct WatchSinBinTests {
    @MainActor @Test func sinBinsRunWithMatchClockAndExpireAfterGap() async {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400, sinBinDurationSeconds: 120
        )
        state.startMatch()
        state.addCard(team: "Home", playerNum: 8, type: .yellow)

        now += 50
        state.timerService.refresh()
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.activeCards.first?.remainingSeconds == 70)

        now += 200
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.activeCards.first?.isExpired == true)
        state.timerService.pause()
    }

    @MainActor @Test func sinBinsDoNotTickWhileClockIsPaused() async {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400, sinBinDurationSeconds: 120
        )
        state.startMatch()
        state.addCard(team: "Home", playerNum: 8, type: .yellow)
        state.timerService.pause()
        now += 300
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.activeCards.first?.remainingSeconds == 120)
    }

    @MainActor @Test func unfinishedSinBinCarriesOverIntoSecondHalf() async {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 600, sinBinDurationSeconds: 120
        )
        state.startMatch()
        now += 560
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        state.addCard(team: "Away", playerNum: 4, type: .yellow)
        now += 40
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        state.endPeriod()
        #expect(state.activeCards.first?.remainingSeconds == 80)

        state.startSecondHalf()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.activeCards.first?.remainingSeconds == 80, "Resetting the clock must not tick the sin-bin")
        now += 30
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.activeCards.first?.remainingSeconds == 50)
        state.timerService.pause()
    }
}
