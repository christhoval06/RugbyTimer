import Foundation
import Testing
@testable import RugbyTimer

/// When the iPhone starts, updates, replaces and ends the match's Live Activity.
struct LiveActivityPlanTests {
    private let match = UUID()

    @Test func startsAtKickOffNotBefore() {
        #expect(LiveActivityPlan.action(for: .preMatch, matchID: match, activityMatchID: nil) == .none)
        #expect(LiveActivityPlan.action(for: .firstHalf, matchID: match, activityMatchID: nil) == .start)
        #expect(LiveActivityPlan.action(for: .firstHalf, matchID: nil, activityMatchID: nil) == .none)
    }

    @Test func updatesThroughHalvesAndBreaks() {
        for period in [MatchPeriod.firstHalf, .halfTime, .secondHalf, .extraTimeBreak, .suddenDeath] {
            #expect(LiveActivityPlan.action(for: period, matchID: match, activityMatchID: match) == .update)
        }
    }

    @Test func fullTimeKeepsTheFinalScoreLeavingDoesNot() {
        #expect(LiveActivityPlan.action(for: .fullTime, matchID: match, activityMatchID: match) == .end(keepsFinalScore: true))
        #expect(LiveActivityPlan.action(for: .preMatch, matchID: nil, activityMatchID: match) == .end(keepsFinalScore: false))
    }

    @Test func aNewMatchReplacesTheOldActivity() {
        #expect(LiveActivityPlan.action(for: .firstHalf, matchID: UUID(), activityMatchID: match) == .replace)
        #expect(LiveActivityPlan.action(for: .preMatch, matchID: UUID(), activityMatchID: match) == .end(keepsFinalScore: false))
    }

    @Test func glanceIgnoresEndDateJitterButNotRealChanges() {
        var glance = MatchGlance.idle
        glance.clockEndsAt = Date(timeIntervalSince1970: 1_000)
        glance.clockSeconds = 600
        var later = glance
        later.clockEndsAt = Date(timeIntervalSince1970: 1_000.4)
        later.clockSeconds = 590
        #expect(glance.isSameGlance(as: later))
        later.homeScore = 3
        #expect(!glance.isSameGlance(as: later))
    }
}
