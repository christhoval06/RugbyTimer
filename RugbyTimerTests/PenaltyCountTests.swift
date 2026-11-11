//
//  PenaltyCountTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// Penalties and free kicks conceded per team.
struct PenaltyCountTests {
    @MainActor private func runningMatch() -> AppState {
        let state = AppState()
        state.homeTeamName = "Rangers RFC"
        state.awayTeamName = "City Lions"
        state.prepareMatch(onPhone: true)
        state.startMatch()
        return state
    }

    @MainActor @Test func countsPenaltiesAndFreeKicksPerTeam() {
        let state = runningMatch()
        state.concede(.penalty, team: "City Lions")
        state.concede(.penalty, team: "City Lions")
        state.concede(.freeKick, team: "City Lions")
        state.concede(.penalty, team: "Rangers RFC")

        #expect(state.infringements(for: "City Lions") == InfringementCount(penalties: 2, freeKicks: 1))
        #expect(state.infringements(for: "Rangers RFC") == InfringementCount(penalties: 1, freeKicks: 0))
        // Penalties never change the score.
        #expect(state.homeScore == 0 && state.awayScore == 0)
    }

    @MainActor @Test func lastPenaltyCanBeUndone() {
        let state = runningMatch()
        state.concede(.penalty, team: "City Lions")
        state.undoLastEntry()
        #expect(state.infringements(for: "City Lions").penalties == 0)
        #expect(state.matchEvents.isEmpty)
    }

    @MainActor @Test func nothingIsCountedWhilePlayIsStopped() {
        let state = runningMatch()
        state.endPeriod()
        state.concede(.penalty, team: "City Lions")
        #expect(state.infringements(for: "City Lions").penalties == 0)
    }

    @MainActor @Test func penaltiesSplitByHalf() {
        let state = runningMatch()
        state.concede(.penalty, team: "City Lions")
        state.endPeriod()
        state.startSecondHalf()
        state.concede(.penalty, team: "City Lions")
        state.concede(.penalty, team: "City Lions")

        let halves = InfringementCount.byHalf(in: state.matchEvents, team: "City Lions")
        #expect(halves.firstHalf.penalties == 1)
        #expect(halves.secondHalf.penalties == 2)
    }

    @MainActor @Test func matchRecordSumsPenaltiesInsteadOfListingThem() {
        let state = runningMatch()
        state.concede(.penalty, team: "City Lions")
        state.concede(.freeKick, team: "Rangers RFC")
        let record = MatchRecordFormatter.record(
            homeTeam: "Rangers RFC", awayTeam: "City Lions", homeScore: 0, awayScore: 0,
            halfDurationSeconds: 2400, events: state.matchEvents
        )
        #expect(!record.contains("Penalty conceded"))
        #expect(record.contains("No recorded events."))
        #expect(record.contains("PENALTIES CONCEDED"))
        #expect(record.contains("City Lions: penalties 1 (H1 1, H2 0) · free kicks 0"))
    }
}
