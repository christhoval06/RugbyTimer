//
//  LawUpdatesTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// Penalty tries, 20-minute red cards and second yellows.
struct LawUpdatesTests {
    @MainActor private func runningMatch(twentyMinuteRed: Bool = false) -> AppState {
        let state = AppState()
        state.homeTeamName = "Rangers RFC"
        state.awayTeamName = "City Lions"
        state.twentyMinuteRedEnabled = twentyMinuteRed
        state.prepareMatch(onPhone: true)
        state.startMatch()
        return state
    }

    @MainActor @Test func penaltyTryScoresSevenAndCountsAsAPenaltyTry() {
        let state = runningMatch()
        state.recordScore(team: "City Lions", playerNumber: nil, points: 7, description: "Penalty try (+7)")
        #expect(state.awayScore == 7)

        let breakdown = MatchStats.breakdown(of: state.matchEvents, team: "City Lions")
        #expect(breakdown.penaltyTries == 1)
        #expect(breakdown.penalties == 0)
        #expect(breakdown.points == 7)
    }

    @Test func twentyMinuteRedCountsDownThenAllowsAReplacement() {
        var card = MatchCard(teamName: "City Lions", playerNumber: 4, type: .red, twentyMinuteRed: true)
        #expect(card.countsDown)
        #expect(!card.isExpired)
        #expect(card.remainingSeconds == MatchCard.twentyMinuteRedSeconds)

        card.tick(seconds: 1199)
        #expect(!card.isExpired)
        card.tick(seconds: 1)
        #expect(card.isExpired)
    }

    @Test func fullRedNeverCountsDown() {
        var card = MatchCard(teamName: "City Lions", playerNumber: 4, type: .red)
        #expect(!card.countsDown)
        card.tick(seconds: 600)
        #expect(card.isTwentyMinuteRed == nil)
    }

    @Test func cardsFromOlderVersionsDecodeAsFullReds() throws {
        let json = #"{"id":"6F9619FF-8B86-D011-B42D-00CF4FC964FF","teamName":"A","playerNumber":5,"type":"red","remainingSeconds":600,"isExpired":true}"#
        let card = try JSONDecoder().decode(MatchCard.self, from: Data(json.utf8))
        #expect(!card.countsDown)
    }

    @MainActor @Test func twentyMinuteRedIsRecordedAndShownInTheLog() {
        let state = runningMatch(twentyMinuteRed: true)
        state.issue(.twentyMinuteRed, team: "City Lions", playerNum: 4)
        #expect(state.activeCards.first?.countsDown == true)
        #expect(state.matchEvents.last?.isTwentyMinuteRed == true)
        #expect(state.matchEvents.last?.description == "20-Minute Red Card - #4")
    }

    @MainActor @Test func secondYellowEndsTheSinBinAndUndoPutsItBack() {
        let state = runningMatch(twentyMinuteRed: true)
        state.issue(.yellow, team: "City Lions", playerNum: 6)
        #expect(state.hasYellow(team: "City Lions", playerNum: 6))
        #expect(!state.hasYellow(team: "Rangers RFC", playerNum: 6))

        state.issue(.secondYellowRed, team: "City Lions", playerNum: 6)
        #expect(state.activeCards.count == 1)
        #expect(state.activeCards.first?.type == .red)
        // With the 20-minute rule on, a second yellow is a 20-minute red.
        #expect(state.activeCards.first?.countsDown == true)
        #expect(state.matchEvents.last?.isSecondYellow == true)
        #expect(state.matchEvents.last?.description == "20-Minute Red Card (Second Yellow) - #6")

        state.undoLastEntry()
        #expect(state.activeCards.map(\.type) == [.yellow])
    }

    @MainActor @Test func secondYellowWithoutTheTwentyMinuteRuleIsAFullRed() {
        let state = runningMatch()
        state.issue(.yellow, team: "Rangers RFC", playerNum: 2)
        state.issue(.secondYellowRed, team: "Rangers RFC", playerNum: 2)
        #expect(state.activeCards.map(\.countsDown) == [false])
        #expect(state.matchEvents.last?.description == "Red Card (Second Yellow) - #2")
    }
}
