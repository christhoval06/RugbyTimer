//
//  UndoLastEntryTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// "Undo last entry": a mis-tapped score or card can be taken back for a few seconds.
struct UndoLastEntryTests {
    @MainActor private func runningMatch() -> AppState {
        let state = AppState()
        state.homeTeamName = "Rangers RFC"
        state.awayTeamName = "City Lions"
        state.prepareMatch(onPhone: true)
        state.startMatch()
        return state
    }

    @MainActor @Test func undoTakesBackTheLatestScore() {
        let state = runningMatch()
        state.recordScore(team: "Rangers RFC", points: 5, description: "Try scored (+5)")
        state.recordScore(team: "City Lions", points: 3, description: "Penalty goal (+3)")

        state.undoLastEntry()
        #expect(state.homeScore == 5)
        #expect(state.awayScore == 0)
        #expect(state.matchEvents.count == 1)
    }

    @MainActor @Test func undoingACardRemovesItsSinBin() {
        let state = runningMatch()
        state.addCard(team: "City Lions", playerNum: 6, type: .yellow)
        state.addCard(team: "Rangers RFC", playerNum: 9, type: .yellow)

        state.undoLastEntry()
        #expect(state.activeCards.map(\.playerNumber) == [6])
        #expect(state.matchEvents.count == 1)
    }

    @MainActor @Test func undoWindowCloses() {
        let state = runningMatch()
        state.recordScore(team: "Rangers RFC", points: 5, description: "Try scored (+5)")
        let later = Date().addingTimeInterval(MatchEvent.undoWindow + 1)

        #expect(state.undoableEntry(at: later) == nil)
        state.undoLastEntry(at: later)
        #expect(state.homeScore == 5)
    }

    @MainActor @Test func whistlesCannotBeUndone() {
        let state = runningMatch()
        state.recordScore(team: "Rangers RFC", points: 5, description: "Try scored (+5)")
        state.endPeriod()

        // Half-time: the last entry is the whistle, and play has stopped.
        #expect(state.undoableEntry() == nil)
        state.undoLastEntry()
        #expect(state.homeScore == 5)
    }
}
