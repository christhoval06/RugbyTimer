//
//  SetupValidationTests.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import XCTest
@testable import RugbyTimer

/// iPhone-side setup: preparing a match and the guards around it.
@MainActor
final class SetupValidationTests: XCTestCase {

    func testDefaultSetup() {
        let state = AppState()
        XCTAssertEqual(state.currentScreen, .setup)
        XCTAssertEqual(state.matchDurationSeconds, 2400)
        XCTAssertEqual(state.sinBinDurationSeconds, 600)
        XCTAssertEqual(state.matchPeriod, .preMatch)
        XCTAssertFalse(state.hasConfiguredMatch)
        XCTAssertFalse(state.homeTeamName.isEmpty)
        XCTAssertFalse(state.awayTeamName.isEmpty)
    }

    func testMatchDurationTextCoversBothHalves() {
        let state = AppState()
        state.matchDurationSeconds = 2400
        XCTAssertEqual(state.matchDurationText, "80:00 Total")
        state.matchDurationSeconds = 420
        XCTAssertEqual(state.matchDurationText, "14:00 Total")
        state.matchDurationSeconds = 2100
        XCTAssertEqual(state.matchDurationText, "70:00 Total")
    }

    func testPrepareMatchUsesChosenDurationAndOpensLiveScreen() {
        let state = AppState()
        state.matchDurationSeconds = 420
        state.prepareMatch()
        XCTAssertTrue(state.hasConfiguredMatch)
        XCTAssertEqual(state.currentScreen, .liveMatch)
        XCTAssertEqual(state.timerService.timeRemaining, 420)
        XCTAssertFalse(state.timerService.isRunning, "Only the Watch starts the clock")
    }

    func testCannotPrepareNewMatchWhileOneIsLive() {
        let state = AppState()
        state.applyWatchSnapshot(MatchSnapshot(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400,
            period: .firstHalf, remaining: 1000, isRunning: true,
            homeScore: 5, awayScore: 0, cards: []
        ))
        state.homeTeamName = "Someone Else"
        state.prepareMatch()
        XCTAssertEqual(state.matchPeriod, .firstHalf)
        XCTAssertEqual(state.homeScore, 5)
    }

    func testCanPrepareAgainAfterFullTime() {
        let state = AppState()
        state.applyWatchSnapshot(MatchSnapshot(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400,
            period: .fullTime, remaining: 0, isRunning: false,
            homeScore: 21, awayScore: 14, cards: []
        ))
        state.prepareMatch()
        XCTAssertEqual(state.matchPeriod, .preMatch)
        XCTAssertEqual(state.homeScore, 0)
        XCTAssertEqual(state.awayScore, 0)
    }

    func testPlayerNumbersCoverOneToForty() {
        XCTAssertEqual(MatchEvent.playerNumbers, 1...40)
    }
}
