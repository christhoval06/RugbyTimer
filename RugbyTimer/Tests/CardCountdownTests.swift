//
//  CardCountdownTests.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import XCTest
@testable import RugbyTimer

final class CardCountdownTests: XCTestCase {

    func testYellowCardInitialization() {
        let card = MatchCard(teamName: "Rangers", playerNumber: 8, type: .yellow, durationSeconds: 600)
        XCTAssertEqual(card.remainingSeconds, 600)
        XCTAssertFalse(card.isExpired)
        XCTAssertEqual(card.type, .yellow)
    }

    func testDefaultDurationIsTenMinutes() {
        XCTAssertEqual(MatchCard(teamName: "Rangers", playerNumber: 8, type: .yellow).remainingSeconds, 600)
    }

    func testCardTickReducesTime() {
        var card = MatchCard(teamName: "Lions", playerNumber: 13, type: .yellow, durationSeconds: 2)

        card.tick()
        XCTAssertEqual(card.remainingSeconds, 1)
        XCTAssertFalse(card.isExpired)

        card.tick()
        XCTAssertEqual(card.remainingSeconds, 0)
        XCTAssertTrue(card.isExpired)
    }

    func testTickBySeveralSecondsCatchesUpAfterSuspension() {
        var card = MatchCard(teamName: "Lions", playerNumber: 13, type: .yellow, durationSeconds: 120)
        card.tick(seconds: 50)
        XCTAssertEqual(card.remainingSeconds, 70)
        XCTAssertFalse(card.isExpired)
    }

    func testTickPastZeroClampsAndExpires() {
        var card = MatchCard(teamName: "Lions", playerNumber: 13, type: .yellow, durationSeconds: 30)
        card.tick(seconds: 500)
        XCTAssertEqual(card.remainingSeconds, 0)
        XCTAssertTrue(card.isExpired)
    }

    func testZeroOrNegativeTickIsIgnored() {
        var card = MatchCard(teamName: "Lions", playerNumber: 13, type: .yellow, durationSeconds: 30)
        card.tick(seconds: 0)
        card.tick(seconds: -10)
        XCTAssertEqual(card.remainingSeconds, 30)
    }

    func testExpiredCardStopsTicking() {
        var card = MatchCard(teamName: "Lions", playerNumber: 13, type: .yellow, durationSeconds: 1)
        card.tick()
        card.tick(seconds: 5)
        XCTAssertEqual(card.remainingSeconds, 0)
        XCTAssertTrue(card.isExpired)
    }

    func testRedCardNeverExpiresViaTicks() {
        var card = MatchCard(teamName: "Rangers", playerNumber: 5, type: .red, durationSeconds: 600)
        XCTAssertTrue(card.isExpired, "A red card is permanent, never a countdown")
        card.tick(seconds: 30)
        XCTAssertEqual(card.remainingSeconds, 600)
        XCTAssertTrue(card.isExpired)
    }

    func testCardSurvivesSnapshotEncoding() throws {
        var card = MatchCard(teamName: "Lions", playerNumber: 40, type: .yellow, durationSeconds: 120)
        card.tick(seconds: 20)
        let decoded = try JSONDecoder().decode(MatchCard.self, from: JSONEncoder().encode(card))
        XCTAssertEqual(decoded, card)
    }
}
