import Testing
import Foundation
@testable import RugbyTimer

/// What the iPhone copies from a Watch snapshot: overtime, cards and the sin-bin length.
struct WatchSnapshotMirrorTests {
    @MainActor @Test func phoneShowsWatchOvertime() {
        let state = AppState()
        state.applyWatchSnapshot(MatchSnapshot(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400,
            period: .firstHalf, remaining: -37, isRunning: true,
            homeScore: 7, awayScore: 3, cards: []
        ))
        #expect(state.timerService.timeRemaining == 0)
        #expect(state.timerService.overtimeSeconds == 37)
        #expect(state.timerService.isInOvertime)
        #expect(state.matchPeriod == .firstHalf)
    }

    @MainActor @Test func phoneMirrorsWatchCardsAndSinBinDuration() {
        let state = AppState()
        var card = MatchCard(teamName: "Home", playerNumber: 8, type: .yellow, durationSeconds: 120)
        card.tick(seconds: 30)
        state.applyWatchSnapshot(MatchSnapshot(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400,
            period: .secondHalf, remaining: 900, isRunning: false,
            homeScore: 0, awayScore: 0, cards: [card],
            sinBinDurationSeconds: 120
        ))
        #expect(state.activeCards == [card])
        #expect(state.activeCards.first?.remainingSeconds == 90)
        #expect(state.sinBinDurationSeconds == 120)
    }

    @MainActor @Test func phoneIgnoresSnapshotsFromAnotherMatch() {
        let state = AppState()
        state.prepareMatch()
        state.applyWatchSnapshot(MatchSnapshot(
            matchID: UUID(), home: "Stranger", away: "Other", duration: 600,
            period: .secondHalf, remaining: 10, isRunning: true,
            homeScore: 50, awayScore: 0, cards: []
        ))
        #expect(state.homeTeamName != "Stranger")
        #expect(state.matchPeriod == .preMatch)
        #expect(state.homeScore == 0)
    }

    @MainActor @Test func snapshotWithoutSinBinDurationFallsBackToTenMinutes() throws {
        let payload = """
        {"updatedAt":0,"matchID":"\(UUID())","home":"H","away":"A","duration":2400,"period":"FIRST HALF (H1)",
         "remaining":100,"isRunning":true,"homeScore":0,"awayScore":0,"cards":[]}
        """
        let snapshot = try JSONDecoder().decode(MatchSnapshot.self, from: Data(payload.utf8))
        let state = AppState()
        state.sinBinDurationSeconds = 120
        state.applyWatchSnapshot(snapshot)
        #expect(state.sinBinDurationSeconds == 600)
    }
}
