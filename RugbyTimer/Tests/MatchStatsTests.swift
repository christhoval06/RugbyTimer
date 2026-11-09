//
//  MatchStatsTests.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/09/26.
//

import XCTest
@testable import RugbyTimer

final class MatchStatsTests: XCTestCase {
    private func score(_ team: String, _ points: Int, _ description: String, minute: Int = 10) -> MatchEvent {
        MatchEvent(minute: minute, teamName: team, type: .tryScore(points: points), description: description)
    }

    private var events: [MatchEvent] {
        [
            score("Home", 5, "Try scored (+5)", minute: 6),
            score("Home", 2, "Conversion (+2)", minute: 7),
            score("Away", 3, "Penalty goal (+3)", minute: 20),
            MatchEvent(minute: 40, teamName: "OFFICIAL", type: .sub, description: "HALF-TIME WHISTLE"),
            score("Away", 3, "Drop goal (+3)", minute: 50),
            score("Home", 5, "Try scored (+5)", minute: 64),
            MatchEvent(minute: 70, teamName: "Away", playerNumber: 8, type: .yellowCard, description: "Yellow")
        ]
    }

    func testBreakdownCountsEachScoreType() {
        let home = MatchStats.breakdown(of: events, team: "Home")
        XCTAssertEqual(home, ScoreBreakdown(tries: 2, conversions: 1, penalties: 0, dropGoals: 0, points: 12))
        let away = MatchStats.breakdown(of: events, team: "Away")
        XCTAssertEqual(away, ScoreBreakdown(tries: 0, conversions: 0, penalties: 1, dropGoals: 1, points: 6))
    }

    func testScoreByHalfSplitsAtHalfTimeWhistle() {
        let halves = MatchStats.scoreByHalf(of: events, home: "Home", away: "Away")
        XCTAssertEqual(halves?.firstHalf.home, 7)
        XCTAssertEqual(halves?.firstHalf.away, 3)
        XCTAssertEqual(halves?.secondHalf.home, 5)
        XCTAssertEqual(halves?.secondHalf.away, 3)
    }

    func testScoreByHalfIsNilBeforeHalfTime() {
        XCTAssertNil(MatchStats.scoreByHalf(of: Array(events.prefix(3)), home: "Home", away: "Away"))
    }

    func testResultReportsWinnerMarginAndDraw() {
        XCTAssertEqual(MatchStats.result(home: "Home", away: "Away", homeScore: 12, awayScore: 7),
                       .win(team: "Home", margin: 5))
        XCTAssertEqual(MatchStats.result(home: "Home", away: "Away", homeScore: 3, awayScore: 10),
                       .win(team: "Away", margin: 7))
        XCTAssertEqual(MatchStats.result(home: "Home", away: "Away", homeScore: 12, awayScore: 12), .draw)
    }

    func testCarriedSinBinsKeepsRunningYellowsAndReds() {
        var served = MatchCard(teamName: "Home", playerNumber: 4, type: .yellow, durationSeconds: 60)
        served.tick(seconds: 60)
        let running = MatchCard(teamName: "Away", playerNumber: 8, type: .yellow, durationSeconds: 300)
        let red = MatchCard(teamName: "Away", playerNumber: 13, type: .red)
        XCTAssertEqual(MatchStats.carriedSinBins([served, running, red]).map(\.playerNumber), [8, 13])
    }
}
