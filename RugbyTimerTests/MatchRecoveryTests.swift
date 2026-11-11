//
//  MatchRecoveryTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// Crash recovery: a match in progress survives the app being closed or crashing.
struct MatchRecoveryTests {
    private func temporaryStore() -> MatchPersistence {
        MatchPersistence(fileURL: FileManager.default.temporaryDirectory
            .appendingPathComponent("match-\(UUID().uuidString).json"))
    }

    @MainActor private func runningPhoneMatch() -> AppState {
        let state = AppState()
        state.homeTeamName = "Rangers RFC"
        state.awayTeamName = "City Lions"
        state.matchDurationSeconds = 2400
        state.prepareMatch(onPhone: true)
        state.startMatch()
        state.recordScore(team: "Rangers RFC", playerNumber: 11, points: 5, description: "Try scored (+5)")
        state.addCard(team: "City Lions", playerNum: 8, type: .yellow)
        return state
    }

    @MainActor @Test func runningMatchIsRestoredWithScoreCardsAndClock() {
        let store = temporaryStore()
        defer { store.clear() }
        let original = runningPhoneMatch()
        original.saveMatch(to: store)

        let restored = AppState.launch(persistence: store)
        #expect(restored.hasConfiguredMatch)
        #expect(restored.isPhoneHosted)
        #expect(restored.currentScreen == .liveMatch)
        #expect(restored.matchPeriod == .firstHalf)
        #expect(restored.homeScore == 5)
        #expect(restored.activeCards.map(\.playerNumber) == [8])
        #expect(restored.matchEvents.count == original.matchEvents.count)
        // The clock keeps running from its saved end date.
        #expect(restored.timerService.isRunning)
        #expect(restored.timerService.endDate == original.timerService.endDate)
    }

    @MainActor @Test func pausedClockIsRestoredPaused() {
        let store = temporaryStore()
        defer { store.clear() }
        let original = runningPhoneMatch()
        original.toggleClock()
        original.saveMatch(to: store)

        let restored = AppState.launch(persistence: store)
        #expect(!restored.timerService.isRunning)
        #expect(restored.timerService.clockSeconds == original.timerService.clockSeconds)
    }

    @MainActor @Test func nothingIsKeptWithoutAMatchOrWhenMirroringTheWatch() {
        let store = temporaryStore()
        defer { store.clear() }
        runningPhoneMatch().saveMatch(to: store)
        #expect(store.load() != nil)

        // The iPhone only mirrors a match run on the Watch, so it keeps no copy of its own.
        let mirror = AppState()
        mirror.prepareMatch()
        mirror.saveMatch(to: store)
        #expect(store.load() == nil)

        let fresh = AppState.launch(persistence: store)
        #expect(!fresh.hasConfiguredMatch)
    }
}
