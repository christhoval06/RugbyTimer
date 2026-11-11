//
//  OffFieldTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// Injury timers (HIA, blood) and corrections to sin-bins already shown.
struct OffFieldTests {
    @MainActor private func runningMatch() -> AppState {
        let state = AppState()
        state.homeTeamName = "Rangers RFC"
        state.awayTeamName = "City Lions"
        state.prepareMatch(onPhone: true)
        state.startMatch()
        return state
    }

    @Test func injuryTimersRunInRealTime() {
        let start = Date()
        let hia = InjuryTimer(teamName: "A", playerNumber: 12, kind: .hia, startedAt: start)
        let blood = InjuryTimer(teamName: "A", playerNumber: 3, kind: .blood, startedAt: start)
        #expect(hia.remainingSeconds(at: start) == 720)
        #expect(blood.remainingSeconds(at: start) == 900)
        #expect(hia.remainingSeconds(at: start.addingTimeInterval(800)) < 0)
    }

    @MainActor @Test func injuryIsLoggedAndClosedWithAnOutcome() {
        let state = runningMatch()
        state.startInjury(.hia, team: "City Lions", playerNum: 12)
        #expect(state.injuryTimers.count == 1)
        #expect(state.matchEvents.last?.description == "HIA - #12")
        #expect(state.matchEvents.last?.startsInjury == true)

        state.endInjury(id: state.injuryTimers[0].id, outcome: .replaced)
        #expect(state.injuryTimers.isEmpty)
        #expect(state.matchEvents.last?.description == "HIA · replaced - #12")
        #expect(state.matchEvents.last?.startsInjury == false)
    }

    @MainActor @Test func startingAnInjuryCanBeUndone() {
        let state = runningMatch()
        state.startInjury(.blood, team: "Rangers RFC", playerNum: 3)
        state.undoLastEntry()
        #expect(state.injuryTimers.isEmpty)
        #expect(state.matchEvents.isEmpty)
    }

    @Test func injuryDescriptionsAreTranslatedBackFromTheirEnglishText() {
        #expect(InjuryTimer.localizedDescription(of: "Blood replacement - #3") != nil)
        #expect(InjuryTimer.localizedDescription(of: "Blood · returned - #3") != nil)
        #expect(InjuryTimer.localizedDescription(of: "Try scored (+5)") == nil)
    }

    @MainActor @Test func sinBinCanBeEndedEarly() {
        let state = runningMatch()
        state.addCard(team: "City Lions", playerNum: 6, type: .yellow)
        state.endSinBinNow(cardID: state.activeCards[0].id)
        #expect(state.activeCards[0].isExpired)
        #expect(state.activeCards[0].remainingSeconds == 0)
    }

    @MainActor @Test func wrongShirtNumberIsFixedOnTheCardAndInTheRecord() {
        let state = runningMatch()
        state.addCard(team: "City Lions", playerNum: 6, type: .yellow)
        state.correctPlayerNumber(cardID: state.activeCards[0].id, to: 7)
        #expect(state.activeCards[0].playerNumber == 7)
        #expect(state.matchEvents[0].playerNumber == 7)
        #expect(state.matchEvents[0].description == "Yellow Card (Sin-Bin) - #7")
        #expect(state.hasYellow(team: "City Lions", playerNum: 7))
        #expect(!state.hasYellow(team: "City Lions", playerNum: 6))
    }

    @MainActor @Test func injuriesSurviveARelaunch() {
        let store = MatchPersistence(fileURL: FileManager.default.temporaryDirectory
            .appendingPathComponent("match-\(UUID().uuidString).json"))
        defer { store.clear() }
        let state = runningMatch()
        state.startInjury(.hia, team: "City Lions", playerNum: 12)
        state.saveMatch(to: store)

        let restored = AppState.launch(persistence: store)
        #expect(restored.injuryTimers == state.injuryTimers)
    }
}
