//
//  LiveMatchIntegrationTests.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import XCTest
@testable import RugbyTimer

/// Match flow that runs on both devices: scores, cards and ending halves.
@MainActor
final class LiveMatchIntegrationTests: XCTestCase {

    func testTimerToggleBehavior() {
        let timerService = MatchTimerService(initialSeconds: 2400)
        XCTAssertFalse(timerService.isRunning)
        timerService.start()
        XCTAssertTrue(timerService.isRunning)
        timerService.pause()
        XCTAssertFalse(timerService.isRunning)
    }

    func testScoresGoToTheRightTeam() {
        let state = AppState()
        state.recordScore(team: state.homeTeamName, points: 5, description: "Try scored (+5)")
        state.recordScore(team: state.homeTeamName, points: 2, description: "Conversion (+2)")
        state.recordScore(team: state.awayTeamName, points: 3, description: "Penalty goal (+3)")
        XCTAssertEqual(state.homeScore, 7)
        XCTAssertEqual(state.awayScore, 3)
        XCTAssertEqual(state.matchEvents.count, 3)
        XCTAssertEqual(state.matchEvents.first?.type, .tryScore(points: 5))
    }

    func testScorerIsOptional() {
        let state = AppState()
        state.recordScore(team: state.homeTeamName, points: 3, description: "Drop goal (+3)")
        state.recordScore(team: state.awayTeamName, playerNumber: 37, points: 5, description: "Try scored (+5)")
        XCTAssertNil(state.matchEvents[0].playerNumber)
        XCTAssertEqual(state.matchEvents[1].playerNumber, 37)
        XCTAssertEqual(state.matchEvents[1].teamName, state.awayTeamName)
    }

    func testYellowCardUsesSinBinDurationAndLogsEvent() {
        let state = AppState()
        state.sinBinDurationSeconds = 120
        state.addCard(team: "Home", playerNum: 8, type: .yellow)
        XCTAssertEqual(state.activeCards.count, 1)
        XCTAssertEqual(state.activeCards.first?.remainingSeconds, 120)
        XCTAssertFalse(state.activeCards.first?.isExpired ?? true)
        XCTAssertEqual(state.matchEvents.last?.type, .yellowCard)
        XCTAssertEqual(state.matchEvents.last?.playerNumber, 8)
        XCTAssertEqual(state.matchEvents.last?.description, "Yellow Card (Sin-Bin) - #8")
    }

    func testRedCardIsPermanentAndLogsEvent() {
        let state = AppState()
        state.addCard(team: "Away", playerNum: 40, type: .red)
        XCTAssertEqual(state.activeCards.first?.type, .red)
        XCTAssertTrue(state.activeCards.first?.isExpired ?? false)
        XCTAssertEqual(state.matchEvents.last?.type, .redCard)
    }

    func testEventMinuteFollowsTheClockIncludingOvertime() {
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400))
        state.matchDurationSeconds = 2400
        state.recordScore(team: state.homeTeamName, points: 5, description: "Kickoff try")
        XCTAssertEqual(state.matchEvents.last?.minute, 1, "Events in the first minute count as minute 1")

        state.timerService.displayWatchTime(remaining: 2400 - 25 * 60, isRunning: true)
        state.addCard(team: "Home", playerNum: 6, type: .yellow)
        XCTAssertEqual(state.matchEvents.last?.minute, 25)

        state.timerService.displayWatchTime(remaining: -90, isRunning: true)
        state.recordScore(team: state.awayTeamName, points: 5, description: "Overtime try")
        XCTAssertEqual(state.matchEvents.last?.minute, 41)
    }

    func testFirstHalfEndsAtHalfTimeWithWhistle() {
        let state = AppState()
        state.matchPeriod = .firstHalf
        state.timerService.start()
        state.handleTimerExpired()
        XCTAssertEqual(state.matchPeriod, .halfTime)
        XCTAssertFalse(state.timerService.isRunning)
        XCTAssertEqual(state.matchEvents.last?.description, "HALF-TIME WHISTLE")
    }

    func testSecondHalfEndsAtFullTimeWithWhistle() {
        let state = AppState()
        state.matchPeriod = .secondHalf
        state.timerService.start()
        state.endPeriod()
        XCTAssertEqual(state.matchPeriod, .fullTime)
        XCTAssertFalse(state.timerService.isRunning)
        XCTAssertEqual(state.matchEvents.last?.description, "FULL-TIME WHISTLE")
    }

    func testEndingPeriodOutsideAHalfChangesNothing() {
        let state = AppState()
        state.matchPeriod = .halfTime
        state.handleTimerExpired()
        XCTAssertEqual(state.matchPeriod, .halfTime)
        XCTAssertTrue(state.matchEvents.isEmpty)
    }

    func testEndMatchStopsClockAndGoesToFullTime() {
        let state = AppState()
        state.matchPeriod = .secondHalf
        state.timerService.start()
        state.endMatch()
        XCTAssertEqual(state.matchPeriod, .fullTime)
        XCTAssertFalse(state.timerService.isRunning)
        XCTAssertEqual(state.currentScreen, .liveMatch)
    }
}
