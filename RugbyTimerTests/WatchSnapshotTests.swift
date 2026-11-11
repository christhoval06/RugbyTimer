import Testing
import Foundation
@testable import RugbyTimer

/// The iPhone following the Watch's match: live clock, stale updates and rejected setups.
struct WatchSnapshotTests {
    /// The phone never starts or ends the match, but keeps counting the Watch clock between
    /// updates so it does not freeze while the Watch is out of range.
    @MainActor @Test func phoneKeepsCountingWatchClockBetweenUpdates() async throws {
        let state = AppState()
        let snapshot = MatchSnapshot(
            matchID: UUID(), home: "Home XV", away: "Away XV", duration: 420,
            period: .secondHalf, remaining: 123, isRunning: true,
            homeScore: 10, awayScore: 5, cards: []
        )
        state.applyWatchSnapshot(snapshot)
        #expect(state.currentScreen == .liveMatch)
        #expect(state.matchPeriod == .secondHalf)
        #expect(state.homeTeamName == "Home XV")
        #expect(state.homeScore == 10)
        #expect(state.timerService.timeRemaining == 123)
        #expect(state.timerService.isRunning)
        try await Task.sleep(for: .milliseconds(1200))
        #expect(state.timerService.timeRemaining == 122)
    }

    @MainActor @Test func delayedWatchUpdateDoesNotRewindMatch() {
        let state = AppState()
        var snapshot = MatchSnapshot(
            matchID: UUID(), home: "Home", away: "Away", duration: 420,
            period: .fullTime, remaining: 0, isRunning: false,
            homeScore: 10, awayScore: 5, cards: []
        )
        state.applyWatchSnapshot(snapshot)
        snapshot.updatedAt = snapshot.updatedAt.addingTimeInterval(-1)
        snapshot.period = .firstHalf
        snapshot.remaining = 400
        state.applyWatchSnapshot(snapshot)
        #expect(state.matchPeriod == .fullTime)
        #expect(state.currentScreen == .liveMatch)
        #expect(state.timerService.timeRemaining == 0)
    }

    @MainActor @Test func rejectedSetupRestoresAuthoritativeWatchMatch() {
        let state = AppState()
        let requestedID = UUID()
        var snapshot = MatchSnapshot(
            matchID: requestedID, home: "New Home", away: "New Away", duration: 420,
            period: .preMatch, remaining: 420, isRunning: false,
            homeScore: 0, awayScore: 0, cards: []
        )
        state.applyWatchSnapshot(snapshot)
        snapshot.updatedAt = snapshot.updatedAt.addingTimeInterval(1)
        snapshot.matchID = UUID()
        snapshot.rejectedConfigurationID = requestedID
        snapshot.period = .firstHalf
        snapshot.remaining = 390
        snapshot.isRunning = true
        state.applyWatchSnapshot(snapshot)
        #expect(state.matchPeriod == .firstHalf)
        #expect(state.timerService.timeRemaining == 390)
        #expect(state.timerService.isRunning)
    }
}
