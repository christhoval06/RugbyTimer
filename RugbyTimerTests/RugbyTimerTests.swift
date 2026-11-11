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
}
