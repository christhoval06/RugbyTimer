//
//  PhoneHostedMatchTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// iPhone-only mode: the phone runs the whole match when the referee has no Apple Watch.
struct PhoneHostedMatchTests {

    @MainActor @Test func phoneHostedMatchRunsFullFlowOnIPhone() {
        let state = AppState()
        state.homeTeamName = "Rangers RFC"
        state.awayTeamName = "City Lions"
        state.matchDurationSeconds = 2400

        state.prepareMatch(onPhone: true)
        #expect(state.isPhoneHosted)
        #expect(state.currentScreen == .liveMatch)
        #expect(state.matchPeriod == .preMatch)

        state.startMatch()
        #expect(state.matchPeriod == .firstHalf)
        #expect(state.timerService.isRunning)

        state.toggleClock()
        #expect(!state.timerService.isRunning)
        state.toggleClock()
        #expect(state.timerService.isRunning)

        state.recordScore(team: "Rangers RFC", playerNumber: 11, points: 5, description: "Try scored (+5)")
        state.addCard(team: "City Lions", playerNum: 8, type: .yellow)
        #expect(state.homeScore == 5)
        #expect(state.activeCards.count == 1)

        state.endPeriod()
        #expect(state.matchPeriod == .halfTime)
        #expect(!state.timerService.isRunning)

        state.startSecondHalf()
        #expect(state.matchPeriod == .secondHalf)
        #expect(state.timerService.isRunning)
        #expect(state.timerService.timeRemaining == 2400)

        state.recordScore(team: "City Lions", points: 3, description: "Penalty goal (+3)")
        #expect(state.awayScore == 3)
        // Second-half events continue the minute count.
        #expect((state.matchEvents.last?.minute ?? 0) > 40)

        state.endPeriod()
        #expect(state.matchPeriod == .fullTime)
        #expect(state.matchEvents.map(\.description).contains("HALF-TIME WHISTLE"))
        #expect(state.matchEvents.last?.description == "FULL-TIME WHISTLE")
    }

    @MainActor @Test func staleWatchSnapshotCannotOverwritePhoneHostedMatch() {
        let state = AppState()
        state.prepareMatch(onPhone: true)
        state.startMatch()

        state.applyWatchSnapshot(MatchSnapshot(
            matchID: UUID(), home: "Other", away: "Team", duration: 1200,
            period: .fullTime, remaining: 0, isRunning: false,
            homeScore: 30, awayScore: 0, cards: []
        ))

        #expect(state.matchPeriod == .firstHalf)
        #expect(state.homeScore == 0)
        #expect(state.timerService.isRunning)
    }

    @MainActor @Test func watchHostedSetupLeavesIPhoneAsMirror() {
        let state = AppState()
        state.prepareMatch(onPhone: true)
        state.startMatch()
        state.endMatch()

        state.prepareMatch()
        #expect(!state.isPhoneHosted)
        state.startMatch()
        #expect(state.matchPeriod == .preMatch)
        #expect(!state.timerService.isRunning)
        state.toggleClock()
        #expect(!state.timerService.isRunning)
    }
}
