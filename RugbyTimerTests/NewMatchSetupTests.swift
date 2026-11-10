//
//  NewMatchSetupTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// NEW MATCH SETUP on iPhone sends the Watch back to "Set up on iPhone".
struct NewMatchSetupTests {

    private func snapshot(_ id: UUID, period: MatchPeriod = .fullTime) -> MatchSnapshot {
        MatchSnapshot(matchID: id, home: "Rangers RFC", away: "City Lions", duration: 2400,
                      period: period, remaining: 0, isRunning: false,
                      homeScore: 12, awayScore: 7, cards: [])
    }

    @MainActor @Test func returnToSetupAfterWatchMatchIgnoresItsLateSnapshots() throws {
        let state = AppState()
        state.prepareMatch()
        let id = try #require(state.matchID)
        state.applyWatchSnapshot(snapshot(id))
        #expect(state.matchPeriod == .fullTime)

        state.returnToSetup()
        #expect(state.currentScreen == .setup)
        #expect(state.dismissedMatchID == id)

        // A snapshot of the finished match that arrives late keeps the iPhone on Setup.
        var late = snapshot(id)
        late.updatedAt = Date().addingTimeInterval(5)
        state.applyWatchSnapshot(late)
        #expect(state.currentScreen == .setup)
    }

    @MainActor @Test func returnToSetupInPhoneOnlyModeSendsNoReset() {
        let state = AppState()
        state.prepareMatch(onPhone: true)
        state.returnToSetup()
        #expect(state.currentScreen == .setup)
        #expect(state.dismissedMatchID == nil)
    }

    @MainActor @Test func watchClearsFinishedMatchOnReset() throws {
        let state = AppState()
        state.prepareMatch(onPhone: true)
        let id = try #require(state.matchID)
        state.homeScore = 12
        state.matchPeriod = .fullTime

        state.receiveMatchReset(id)
        #expect(!state.hasConfiguredMatch)
        #expect(state.matchPeriod == .preMatch)
        #expect(state.homeScore == 0)
        #expect(state.matchEvents.isEmpty)
    }

    @MainActor @Test func watchClearsMatchNotYetKickedOffOnReset() throws {
        let state = AppState()
        state.prepareMatch(onPhone: true)
        let id = try #require(state.matchID)
        state.receiveMatchReset(id)
        #expect(!state.hasConfiguredMatch)
    }

    @MainActor @Test func watchKeepsMatchInPlayOnReset() throws {
        let state = AppState()
        state.prepareMatch(onPhone: true)
        let id = try #require(state.matchID)
        state.startMatch()

        state.receiveMatchReset(id)
        #expect(state.hasConfiguredMatch)
        #expect(state.matchPeriod == .firstHalf)
    }

    @MainActor @Test func watchIgnoresResetForAnotherMatch() {
        let state = AppState()
        state.prepareMatch(onPhone: true)
        state.receiveMatchReset(UUID())
        #expect(state.hasConfiguredMatch)
    }
}
