//
//  SubstitutionTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// Permanent substitutions: recorded per team, counted against the limit, checked for likely mistakes.
struct SubstitutionTests {

    @MainActor private func matchInPlay(_ rules: SubstitutionRules = SubstitutionRules(isEnabled: true)) -> AppState {
        let state = AppState()
        state.substitutionRules = rules
        state.prepareMatch(onPhone: true)
        state.startMatch()
        return state
    }

    @MainActor @Test func substitutionIsRecordedAndCounted() throws {
        let state = matchInPlay()
        let team = state.homeTeamName
        state.substitute(team: team, off: 3, on: 18)

        #expect(state.substitutionCount(for: team) == 1)
        #expect(state.substitutionCount(for: state.awayTeamName) == 0)
        let event = try #require(state.matchEvents.last)
        #expect(Substitution.of(event) == Substitution(off: 3, on: 18))
        #expect(event.localizedDescription.contains("18"))
        state.timerService.pause()
    }

    @MainActor @Test func nothingIsRecordedWhenSubstitutionsAreOff() {
        let state = matchInPlay(SubstitutionRules(isEnabled: false))
        state.substitute(team: state.homeTeamName, off: 3, on: 18)
        #expect(state.matchEvents.allSatisfy { Substitution.of($0) == nil })
        state.timerService.pause()
    }

    @MainActor @Test func substitutionsWorkAtHalfTimeButNotBeforeKickOff() {
        let state = AppState()
        state.substitutionRules = SubstitutionRules(isEnabled: true)
        state.prepareMatch(onPhone: true)
        state.substitute(team: state.homeTeamName, off: 3, on: 18)
        #expect(state.substitutionCount(for: state.homeTeamName) == 0)

        state.startMatch()
        state.endPeriod()
        #expect(state.matchPeriod == .halfTime)
        state.substitute(team: state.homeTeamName, off: 3, on: 18)
        #expect(state.substitutionCount(for: state.homeTeamName) == 1)
    }

    @MainActor @Test func samePlayerOffAndOnIsIgnored() {
        let state = matchInPlay()
        state.substitute(team: state.homeTeamName, off: 9, on: 9)
        #expect(state.substitutionCount(for: state.homeTeamName) == 0)
        state.timerService.pause()
    }

    @MainActor @Test func undoTakesBackASubstitution() {
        let state = matchInPlay()
        state.substitute(team: state.homeTeamName, off: 3, on: 18)
        state.undoLastEntry()
        #expect(state.substitutionCount(for: state.homeTeamName) == 0)
        state.timerService.pause()
    }

    @MainActor @Test func warningsCatchLikelyMistakes() {
        let state = matchInPlay(SubstitutionRules(isEnabled: true, limit: 2))
        let team = state.homeTeamName
        #expect(state.substitutionWarning(team: team, off: 3, on: 18) == nil)

        state.issue(.yellow, team: team, playerNum: 7)
        #expect(state.substitutionWarning(team: team, off: 7, on: 19) == .offPlayerSanctioned(7))

        state.substitute(team: team, off: 3, on: 18)
        #expect(state.substitutionWarning(team: team, off: 3, on: 20) == .offPlayerAlreadyReplaced(3))
        // Back on (rolling substitutions): no longer "already replaced".
        state.substitute(team: team, off: 18, on: 3)
        #expect(state.substitutionWarning(team: team, off: 3, on: 20) == .limitReached(2))
        state.timerService.pause()
    }

    @MainActor @Test func noLimitNeverWarnsAboutTheCount() {
        let state = matchInPlay(SubstitutionRules(isEnabled: true, limit: SubstitutionRules.unlimited))
        for number in 1...10 { state.substitute(team: state.homeTeamName, off: number, on: number + 20) }
        #expect(state.substitutionWarning(team: state.homeTeamName, off: 11, on: 31) == nil)
        state.timerService.pause()
    }

    @MainActor @Test func matchRecordListsSubstitutions() {
        let state = matchInPlay()
        state.substitute(team: state.homeTeamName, off: 3, on: 18)
        let record = MatchRecordFormatter.record(homeTeam: state.homeTeamName, awayTeam: state.awayTeamName,
                                                 homeScore: 0, awayScore: 0, halfDurationSeconds: 2400,
                                                 events: state.matchEvents)
        #expect(record.contains("SUBSTITUTIONS"))
        state.timerService.pause()
    }

    @Test func settingsRememberSubstitutionRules() throws {
        let defaults = try #require(UserDefaults(suiteName: "SubstitutionTests"))
        defaults.removePersistentDomain(forName: "SubstitutionTests")
        #expect(AppSettings(defaults: defaults).substitutionRules == SubstitutionRules())

        AppSettings(defaults: defaults).substitutionRules = SubstitutionRules(isEnabled: true, limit: 5)
        #expect(AppSettings(defaults: defaults).substitutionRules == SubstitutionRules(isEnabled: true, limit: 5))
    }
}
