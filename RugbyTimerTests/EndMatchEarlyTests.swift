//
//  EndMatchEarlyTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// Ending a match before time (abandoned for weather, injury or the pitch).
struct EndMatchEarlyTests {

    @MainActor private func runningMatch() -> AppState {
        let state = AppState()
        state.homeTeamName = "Rangers RFC"
        state.awayTeamName = "City Lions"
        state.matchDurationSeconds = 2400
        state.prepareMatch(onPhone: true)
        state.startMatch()
        return state
    }

    private func earlyEndEvents(_ state: AppState) -> [MatchEvent] {
        state.matchEvents.filter { $0.description == MatchEvent.matchEndedEarly }
    }

    @MainActor @Test func endingDuringFirstHalfStopsClockAndRecordsIt() {
        let state = runningMatch()
        state.recordScore(team: "Rangers RFC", points: 5, description: "Try scored (+5)")

        state.endMatch()

        #expect(state.matchPeriod == .fullTime)
        #expect(!state.timerService.isRunning)
        #expect(state.homeScore == 5)
        let event = earlyEndEvents(state).first
        #expect(event != nil)
        #expect(event?.minute == 0)
        #expect(event?.teamName == "OFFICIAL")
        #expect(MatchStats.timePastClock(of: state.matchEvents).secondHalf == nil)
    }

    @MainActor @Test func endingDuringHalfTimeClearsTheBreak() {
        let state = runningMatch()
        state.endPeriod()
        #expect(state.matchPeriod == .halfTime)
        #expect(state.halfTimeBreakEndsAt != nil)

        state.endMatch()

        #expect(state.matchPeriod == .fullTime)
        #expect(state.halfTimeBreakEndsAt == nil)
        #expect(state.halfTimeStartedAt == nil)
        #expect(earlyEndEvents(state).first?.minute == 40)
        #expect(earlyEndEvents(state).first?.overtimeSeconds == 0)
    }

    @MainActor @Test func endingTwiceRecordsOnlyOnce() {
        let state = runningMatch()
        state.endMatch()
        state.endMatch()
        #expect(earlyEndEvents(state).count == 1)
    }

    @Test func earlyEndEventIsTranslatedInRecord() {
        let event = MatchEvent(minute: 12, teamName: "OFFICIAL", type: .sub, description: MatchEvent.matchEndedEarly)
        #expect(!event.localizedDescription.isEmpty)
    }
}
