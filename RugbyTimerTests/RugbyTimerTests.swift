//
//  RugbyTimerTests.swift
//  RugbyTimerTests
//
//  Created by @christhoval on 11/08/26.
//

import Testing
import Foundation
@testable import RugbyTimer

struct RugbyTimerTests {

    @MainActor @Test func sendingNewSetupClearsPreviousMatchAndKeepsConfiguration() {
        let state = AppState()
        let previousSnapshot = MatchSnapshot(
            matchID: UUID(), home: "Previous Home", away: "Previous Away", duration: 2400,
            period: .fullTime, remaining: 0, isRunning: false,
            homeScore: 25, awayScore: 10, cards: []
        )
        state.applyWatchSnapshot(previousSnapshot)
        state.addCard(team: "Previous Home", playerNum: 8, type: .yellow)
        state.recordScore(team: "Previous Home", points: 5, description: "Previous try")
        state.timerService.start()
        state.homeTeamName = "New Home"
        state.awayTeamName = "New Away"
        state.matchDurationSeconds = 420
        state.sinBinDurationSeconds = 120

        state.prepareMatch()

        #expect(state.homeTeamName == "New Home")
        #expect(state.awayTeamName == "New Away")
        #expect(state.matchDurationSeconds == 420)
        #expect(state.sinBinDurationSeconds == 120)
        #expect(state.matchDurationText == "14:00 Total")
        #expect(state.homeScore == 0 && state.awayScore == 0)
        #expect(state.activeCards.isEmpty)
        #expect(state.matchEvents.isEmpty)
        #expect(state.matchPeriod == .preMatch)
        #expect(state.timerService.timeRemaining == 420)
        #expect(!state.timerService.isRunning)
        #expect(state.hasConfiguredMatch)
        #expect(state.currentScreen == .liveMatch)

        var delayedSnapshot = previousSnapshot
        delayedSnapshot.updatedAt = Date().addingTimeInterval(1)
        state.applyWatchSnapshot(delayedSnapshot)
        #expect(state.homeTeamName == "New Home")
        #expect(state.matchPeriod == .preMatch)
        #expect(state.homeScore == 0)
        #expect(state.timerService.timeRemaining == 420)
    }

    @MainActor @Test func iPhoneCannotStartMatch() {
        let state = AppState()
        state.startMatch()
        #expect(state.matchPeriod == .preMatch)
        #expect(!state.timerService.isRunning)
        #expect(state.currentScreen == .setup)
    }

    @MainActor @Test func preparingMatchWaitsForWatchKickoff() {
        let state = AppState()
        state.matchDurationSeconds = 420
        state.prepareMatch()
        #expect(state.matchPeriod == .preMatch)
        #expect(state.timerService.timeRemaining == 420)
        #expect(!state.timerService.isRunning)
        #expect(state.currentScreen == .liveMatch)
    }

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
