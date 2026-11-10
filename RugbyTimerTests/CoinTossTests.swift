//
//  CoinTossTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// Coin toss: who wins, who kicks off each half, and how the toss travels with the match.
struct CoinTossTests {

    @Test func correctCallWinsForCaller() {
        let toss = CoinTossResult(caller: .away, call: .tails, outcome: .tails, choice: .kickOff)
        #expect(toss.winner == .away)
        #expect(toss.firstHalfKickOff == .away)
        #expect(toss.secondHalfKickOff == .home)
    }

    @Test func wrongCallHandsTossToOpponent() {
        let toss = CoinTossResult(caller: .away, call: .heads, outcome: .tails, choice: .kickOff)
        #expect(toss.winner == .home)
        #expect(toss.firstHalfKickOff == .home)
    }

    @Test func choosingAnEndGivesOpponentTheKickOff() {
        let toss = CoinTossResult.recorded(winner: .home, choice: .chooseEnd)
        #expect(toss.winner == .home)
        #expect(toss.firstHalfKickOff == .away)
        #expect(toss.secondHalfKickOff == .home)
    }

    @Test func serviceUsesInjectedCoin() {
        #expect(CoinTossService(flipCoin: { .tails }).flip() == .tails)
        #expect(CoinTossService(flipCoin: { .heads }).flip() == .heads)
    }

    @Test func toggleTravelsWithConfiguration() throws {
        let configuration = MatchConfiguration(matchID: UUID(), home: "A", away: "B", duration: 2400, coinTossEnabled: true)
        let decoded = try JSONDecoder().decode(MatchConfiguration.self, from: JSONEncoder().encode(configuration))
        #expect(decoded.coinTossEnabled == true)
    }

    @Test func olderConfigurationWithoutTossDecodes() throws {
        let json = #"{"matchID":"\#(UUID().uuidString)","home":"A","away":"B","duration":2400}"#
        let decoded = try JSONDecoder().decode(MatchConfiguration.self, from: Data(json.utf8))
        #expect(decoded.coinTossEnabled == nil)
    }

    @MainActor private func preparedState(tossEnabled: Bool) -> AppState {
        let state = AppState()
        state.homeTeamName = "Rangers RFC"
        state.awayTeamName = "City Lions"
        state.coinTossEnabled = tossEnabled
        state.prepareMatch()
        return state
    }

    @MainActor @Test func watchNeedsTossBeforeKickOffWhenEnabled() {
        let state = preparedState(tossEnabled: true)
        #expect(state.needsCoinToss)
        #expect(state.matchEvents.isEmpty)

        state.recordCoinToss(.recorded(winner: .away, choice: .kickOff))

        #expect(!state.needsCoinToss)
        #expect(state.matchEvents.count == 1)
        #expect(state.matchEvents.first?.teamName == "City Lions")
        #expect(state.matchEvents.first?.minute == 0)
        #expect(state.kickOffTeamName(for: .firstHalf) == "City Lions")
        #expect(state.kickOffTeamName(for: .halfTime) == "Rangers RFC")
        let teams = CoinTossResult.kickOffTeams(in: state.matchEvents, home: "Rangers RFC", away: "City Lions")
        #expect(teams?.firstHalf == "City Lions")
        #expect(teams?.secondHalf == "Rangers RFC")
    }

    @MainActor @Test func redoingTossReplacesRecordEntry() {
        let state = preparedState(tossEnabled: true)
        state.recordCoinToss(.recorded(winner: .away, choice: .kickOff))
        state.recordCoinToss(.recorded(winner: .home, choice: .chooseEnd))
        #expect(state.matchEvents.count == 1)
        #expect(state.kickOffTeamName(for: .firstHalf) == "City Lions")
    }

    @MainActor @Test func noTossWhenToggleIsOff() {
        let state = preparedState(tossEnabled: false)
        #expect(!state.needsCoinToss)
        state.recordCoinToss(.recorded(winner: .home, choice: .kickOff))
        #expect(state.coinToss == nil)
        #expect(state.matchEvents.isEmpty)
        #expect(state.kickOffTeamName(for: .firstHalf) == nil)
    }

    @MainActor @Test func iPhoneOnlyMatchDoesNotWaitForToss() {
        let state = AppState()
        state.coinTossEnabled = true
        state.prepareMatch(onPhone: true)
        #expect(!state.needsCoinToss)
        state.startMatch()
        #expect(state.matchPeriod == .firstHalf)
    }

    @MainActor @Test func newMatchClearsPreviousToss() {
        let state = preparedState(tossEnabled: true)
        state.recordCoinToss(.recorded(winner: .home, choice: .kickOff))
        state.endMatch()
        state.prepareMatch()
        #expect(state.coinToss == nil)
        #expect(state.needsCoinToss)
    }

    @Test func tossEventIsTranslatedInRecord() {
        let event = MatchEvent(minute: 0, teamName: "City Lions", type: .sub, description: "Won the toss · kicks off")
        #expect(!event.localizedDescription.isEmpty)
        #expect(MatchStats.breakdown(of: [event], team: "City Lions").tries == 0)
    }
}
