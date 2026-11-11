//
//  HalfTimeBreakTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// Half-time interval countdown and the time each half ran past the clock.
struct HalfTimeBreakTests {
    @Test func halfTimeWhistleRecordsTimePastTheClockAndStartsTheBreak() {
        let state = AppState()
        state.halfTimeBreakSeconds = 900
        state.matchPeriod = .firstHalf
        state.timerService.reset(to: -72) // 1:12 played after time was up

        state.handleTimerExpired()

        #expect(state.matchPeriod == .halfTime)
        #expect(state.matchEvents.last?.overtimeSeconds == 72)
        let startedAt = state.halfTimeStartedAt
        #expect(startedAt != nil)
        #expect(state.halfTimeBreakEndsAt == startedAt?.addingTimeInterval(900))
    }

    @Test func endingAHalfEarlyRecordsNoTimePastTheClock() {
        let state = AppState()
        state.matchPeriod = .secondHalf
        state.timerService.reset(to: 95)

        state.handleTimerExpired()

        #expect(state.matchPeriod == .fullTime)
        #expect(state.matchEvents.last?.overtimeSeconds == 0)
        #expect(state.halfTimeBreakEndsAt == nil)
    }

    @Test func timePastClockReadsBothWhistles() {
        let events = [
            MatchEvent(minute: 40, teamName: "OFFICIAL", type: .sub, description: "HALF-TIME WHISTLE", overtimeSeconds: 72),
            MatchEvent(minute: 80, teamName: "OFFICIAL", type: .sub, description: "FULL-TIME WHISTLE", overtimeSeconds: 160)
        ]
        let played = MatchStats.timePastClock(of: events)
        #expect(played.firstHalf == 72)
        #expect(played.secondHalf == 160)
    }

    @Test func olderWhistleEventsWithoutOvertimeStillDecode() throws {
        let legacy = #"{"id":"6F9619FF-8B86-D011-B42D-00C04FC964FF","minute":40,"teamName":"OFFICIAL","type":{"sub":{}},"description":"HALF-TIME WHISTLE"}"#
        let event = try JSONDecoder().decode(MatchEvent.self, from: Data(legacy.utf8))
        #expect(event.overtimeSeconds == nil)
        #expect(MatchStats.timePastClock(of: [event]).firstHalf == nil)
    }

    @Test func breakLengthTravelsWithTheMatchSetup() throws {
        let config = MatchConfiguration(matchID: UUID(), home: "A", away: "B", duration: 2400, halfTimeBreakSeconds: 720)
        let decoded = try JSONDecoder().decode(MatchConfiguration.self, from: JSONEncoder().encode(config))
        #expect(decoded.halfTimeBreakSeconds == 720)
    }
}
