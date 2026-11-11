//
//  ExtraTimeTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// Extra time for knockout matches level at full time.
struct ExtraTimeTests {
    @MainActor private func levelAtFullTime(_ format: ExtraTimeFormat) -> AppState {
        let state = AppState()
        state.homeTeamName = "Rangers RFC"
        state.awayTeamName = "City Lions"
        state.extraTimeFormat = format
        state.prepareMatch(onPhone: true)
        state.startMatch()
        state.recordScore(team: "Rangers RFC", points: 5, description: "Try scored (+5)")
        state.endPeriod()
        state.startSecondHalf()
        state.recordScore(team: "City Lions", points: 5, description: "Try scored (+5)")
        state.endPeriod()
        return state
    }

    @MainActor @Test func levelMatchWithoutExtraTimeEndsAtFullTime() {
        let state = levelAtFullTime(.off)
        #expect(state.matchPeriod == .fullTime)
    }

    @MainActor @Test func decidedMatchEndsAtFullTimeEvenWithExtraTimeOn() {
        let state = AppState()
        state.extraTimeFormat = .twoHalves
        state.prepareMatch(onPhone: true)
        state.startMatch()
        state.recordScore(team: state.homeTeamName, points: 3, description: "Penalty goal (+3)")
        state.endPeriod()
        state.startSecondHalf()
        state.endPeriod()
        #expect(state.matchPeriod == .fullTime)
    }

    @MainActor @Test func fifteensPlaysTwoHalvesThenSuddenDeath() {
        let state = levelAtFullTime(.twoHalves)
        #expect(state.matchPeriod == .extraTimeBreak)
        #expect(state.nextExtraPeriod == .extraTimeFirstHalf)

        state.startExtraPeriod()
        #expect(state.matchPeriod == .extraTimeFirstHalf)
        #expect(state.currentPeriodSeconds == 600)
        #expect(state.timerService.timeRemaining == 600)
        state.endPeriod()
        #expect(state.nextExtraPeriod == .extraTimeSecondHalf)

        state.startExtraPeriod()
        state.endPeriod()
        // Still level after 100 minutes: sudden death.
        #expect(state.matchPeriod == .extraTimeBreak)
        #expect(state.nextExtraPeriod == .suddenDeath)

        state.startExtraPeriod()
        #expect(state.matchPeriod == .suddenDeath)
        state.recordScore(team: "City Lions", points: 3, description: "Penalty goal (+3)")
        #expect(state.hasSuddenDeathWinner)
        // The first score is undoable until the referee blows the whistle.
        #expect(state.undoableEntry() != nil)
        state.endPeriod()
        #expect(state.matchPeriod == .fullTime)
    }

    @MainActor @Test func sevensGoesStraightToSuddenDeathPeriods() {
        let state = levelAtFullTime(.suddenDeath)
        #expect(state.nextExtraPeriod == .suddenDeath)
        state.startExtraPeriod()
        #expect(state.currentPeriodSeconds == 300)
        state.endPeriod()
        // No score in the period: another sudden-death period.
        #expect(state.matchPeriod == .extraTimeBreak)
        #expect(state.nextExtraPeriod == .suddenDeath)
    }

    @MainActor @Test func extraTimeScoreInFirstPeriodEndsMatchAtItsWhistle() {
        let state = levelAtFullTime(.twoHalves)
        state.startExtraPeriod()
        state.recordScore(team: "Rangers RFC", points: 3, description: "Drop goal (+3)")
        state.endPeriod()
        // Half-time of extra time: the second extra-time half is always played.
        #expect(state.matchPeriod == .extraTimeBreak)
        state.startExtraPeriod()
        state.endPeriod()
        #expect(state.matchPeriod == .fullTime)
    }

    @MainActor @Test func refereeCanEndLevelAsADraw() {
        let state = levelAtFullTime(.twoHalves)
        let eventCount = state.matchEvents.count
        state.endMatch()
        #expect(state.matchPeriod == .fullTime)
        #expect(state.matchEvents.count == eventCount) // not an abandoned match
    }

    @MainActor @Test func extraTimeContinuesTheMatchClockAndSplitsTheStats() {
        let state = levelAtFullTime(.twoHalves)
        state.startExtraPeriod()
        state.recordScore(team: "Rangers RFC", points: 3, description: "Drop goal (+3)")
        // Kicked off at 80:00, so the score is in the 81st minute.
        #expect((state.matchEvents.last?.matchSeconds ?? 0) >= 4800)
        #expect(state.matchEvents.last?.minute == 81)

        let halves = MatchStats.scoreByHalf(of: state.matchEvents, home: "Rangers RFC", away: "City Lions")
        #expect(halves?.secondHalf.home == 0 && halves?.secondHalf.away == 5)
        let extra = MatchStats.extraTimeScore(of: state.matchEvents, home: "Rangers RFC", away: "City Lions")
        #expect(extra?.home == 3 && extra?.away == 0)
    }

    @MainActor @Test func noExtraTimeScoreWhenNonePlayed() {
        #expect(MatchStats.extraTimeScore(of: levelAtFullTime(.off).matchEvents, home: "Rangers RFC", away: "City Lions") == nil)
    }
}
