import Foundation
import Testing
@testable import RugbyTimer

/// When the iPhone starts, updates, replaces and ends the match's Live Activity.
struct LiveActivityPlanTests {
    private let match = UUID()

    private func plan(_ period: MatchPeriod, matchID: UUID?, shown: Bool = true, activity: UUID?) -> LiveActivityPlan {
        LiveActivityPlan.action(for: period, matchID: matchID, isMatchShown: shown, activityMatchID: activity)
    }

    /// The Watch kicks off with the iPhone in a pocket, and iOS only starts activities in the foreground.
    @Test func startsWhenTheMatchIsSetUpNotAtKickOff() {
        #expect(plan(.preMatch, matchID: match, activity: nil) == .start)
        #expect(plan(.preMatch, matchID: match, shown: false, activity: nil) == .none)
        #expect(plan(.preMatch, matchID: nil, activity: nil) == .none)
    }

    @Test func aRefusedStartIsRetriedLaterInTheMatch() {
        #expect(plan(.firstHalf, matchID: match, activity: nil) == .start)
    }

    @Test func updatesThroughHalvesAndBreaks() {
        for period in [MatchPeriod.preMatch, .firstHalf, .halfTime, .secondHalf, .extraTimeBreak, .suddenDeath] {
            #expect(plan(period, matchID: match, activity: match) == .update)
        }
    }

    @Test func fullTimeKeepsTheFinalScoreLeavingDoesNot() {
        #expect(plan(.fullTime, matchID: match, activity: match) == .end(keepsFinalScore: true))
        #expect(plan(.fullTime, matchID: match, shown: false, activity: match) == .end(keepsFinalScore: true))
        #expect(plan(.preMatch, matchID: match, shown: false, activity: match) == .end(keepsFinalScore: false))
    }

    @Test func aNewMatchReplacesTheOldActivity() {
        #expect(plan(.preMatch, matchID: UUID(), activity: match) == .replace)
        #expect(plan(.firstHalf, matchID: UUID(), activity: match) == .replace)
        #expect(plan(.preMatch, matchID: UUID(), shown: false, activity: match) == .end(keepsFinalScore: false))
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
