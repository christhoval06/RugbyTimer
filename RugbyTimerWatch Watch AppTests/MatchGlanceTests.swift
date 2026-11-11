import Foundation
import Testing
@testable import RugbyTimerWatch_Watch_App

/// What the Watch complication and the iPhone Live Activity are given to show.
struct MatchGlanceTests {
    @MainActor private func liveMatch(now: @escaping () -> Date) -> AppState {
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: now))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Rangers RFC", away: "City Lions", duration: 2400, sinBinDurationSeconds: 600
        )
        return state
    }

    @MainActor @Test func noMatchIsIdle() {
        #expect(AppState().matchGlance == .idle)
    }

    @MainActor @Test func runningClockGivesItsEndDateAndSinBins() {
        let now = Date(timeIntervalSince1970: 1_000)
        let state = liveMatch { now }
        state.startMatch()
        state.recordScore(team: "Rangers RFC", points: 5, description: "Try scored (+5)")
        state.addCard(team: "City Lions", playerNum: 8, type: .yellow)

        let snapshot = state.matchGlance
        #expect(snapshot.isMatchLive && snapshot.isRunning)
        #expect(snapshot.clockEndsAt == now.addingTimeInterval(2400))
        #expect(snapshot.periodSeconds == 2400)
        #expect(snapshot.homeScore == 5 && snapshot.awayScore == 0)
        #expect(snapshot.sinBinCount == 1)
        #expect(snapshot.nextSinBinEndsAt != nil)
        state.timerService.pause()
    }

    @MainActor @Test func pausedClockGivesItsReadingAndNoSinBinDate() {
        let now = Date(timeIntervalSince1970: 1_000)
        let state = liveMatch { now }
        state.startMatch()
        state.addCard(team: "City Lions", playerNum: 8, type: .yellow)
        state.timerService.pause()

        let snapshot = state.matchGlance
        #expect(!snapshot.isRunning)
        #expect(snapshot.clockSeconds == 2400)
        #expect(snapshot.nextSinBinEndsAt == nil, "A stopped sin-bin has no end time")
        #expect(snapshot.sinBinCount == 1)
    }

    @Test func storeRoundTripsAndFallsBackToIdle() throws {
        let defaults = try #require(UserDefaults(suiteName: "MatchGlanceTests"))
        defaults.removePersistentDomain(forName: "MatchGlanceTests")
        #expect(ComplicationStore.load(from: defaults) == .idle)

        var snapshot = MatchGlance.idle
        snapshot.homeTeamName = "Rangers RFC"
        snapshot.homeScore = 12
        ComplicationStore.save(snapshot, to: defaults)
        #expect(ComplicationStore.load(from: defaults) == snapshot)
    }

    @Test func teamCodesAreThreeLetters() {
        #expect(MatchGlance.code(for: "Rangers RFC") == "RAN")
        #expect(MatchGlance.code(for: "St. Kilda") == "STK")
    }
}
