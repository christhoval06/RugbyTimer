//
//  TimerRingTests.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import XCTest
@testable import RugbyTimer

final class TimerRingTests: XCTestCase {

    // MARK: Progress

    func testProgressIsFullAtKickoff() {
        XCTAssertEqual(TimerRingView.progress(timeRemaining: 2400, totalDuration: 2400, overtimeSeconds: 0), 1.0, accuracy: 0.001)
    }

    func testProgressAtHalfway() {
        XCTAssertEqual(TimerRingView.progress(timeRemaining: 1200, totalDuration: 2400, overtimeSeconds: 0), 0.5, accuracy: 0.001)
    }

    func testProgressIsEmptyAtZero() {
        XCTAssertEqual(TimerRingView.progress(timeRemaining: 0, totalDuration: 2400, overtimeSeconds: 0), 0.0, accuracy: 0.001)
    }

    func testProgressIsFullAgainInOvertime() {
        XCTAssertEqual(TimerRingView.progress(timeRemaining: 0, totalDuration: 2400, overtimeSeconds: 12), 1.0, accuracy: 0.001)
    }

    func testProgressHandlesZeroDurationAndClampsOverflow() {
        XCTAssertEqual(TimerRingView.progress(timeRemaining: 100, totalDuration: 0, overtimeSeconds: 0), 0.0)
        XCTAssertEqual(TimerRingView.progress(timeRemaining: 3000, totalDuration: 2400, overtimeSeconds: 0), 1.0)
    }

    // MARK: Colour zones

    func testClosingThresholdIsLastQuarterCappedAtFiveMinutes() {
        XCTAssertEqual(TimerRingView.closingThreshold(totalDuration: 2400), 300)
        XCTAssertEqual(TimerRingView.closingThreshold(totalDuration: 420), 105)
        XCTAssertEqual(TimerRingView.closingThreshold(totalDuration: 600), 150)
    }

    func testFortyMinuteHalfZones() {
        XCTAssertEqual(TimerRingView.zone(timeRemaining: 2400, totalDuration: 2400, overtimeSeconds: 0), .normal)
        XCTAssertEqual(TimerRingView.zone(timeRemaining: 301, totalDuration: 2400, overtimeSeconds: 0), .normal)
        XCTAssertEqual(TimerRingView.zone(timeRemaining: 300, totalDuration: 2400, overtimeSeconds: 0), .closing)
        XCTAssertEqual(TimerRingView.zone(timeRemaining: 1, totalDuration: 2400, overtimeSeconds: 0), .closing)
        XCTAssertEqual(TimerRingView.zone(timeRemaining: 0, totalDuration: 2400, overtimeSeconds: 0), .timeUp)
        XCTAssertEqual(TimerRingView.zone(timeRemaining: 0, totalDuration: 2400, overtimeSeconds: 12), .timeUp)
    }

    func testSevensHalfZones() {
        XCTAssertEqual(TimerRingView.zone(timeRemaining: 106, totalDuration: 420, overtimeSeconds: 0), .normal)
        XCTAssertEqual(TimerRingView.zone(timeRemaining: 105, totalDuration: 420, overtimeSeconds: 0), .closing)
    }
}
