import Foundation
import Testing
@testable import RugbyTimer

/// What the Home Screen widget shows: the match while it is on, otherwise the last result.
struct MatchWidgetSnapshotTests {
    private let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
    private var glance: MatchGlance { MatchGlance.samples(now: now)[0] }
    private var lastMatch: MatchHistoryEntry {
        MatchHistoryEntry(matchID: UUID(), playedAt: now.addingTimeInterval(-86_400), homeTeam: "Rangers RFC",
                          awayTeam: "City Lions", homeScore: 24, awayScore: 17, halfSeconds: 2400,
                          extraTimeFormat: .off, source: .iPhone, events: [])
    }

    private func snapshot(_ period: MatchPeriod, shown: Bool = true, glance: MatchGlance? = nil,
                          last: MatchHistoryEntry? = nil) -> MatchWidgetSnapshot {
        .make(glance: glance ?? self.glance, period: period, isMatchShown: shown, lastMatch: last, now: now)
    }

    @Test func showsTheMatchFromSetUpUntilFullTime() {
        for period in [MatchPeriod.preMatch, .firstHalf, .halfTime, .secondHalf, .suddenDeath] {
            #expect(snapshot(period).liveMatch != nil)
        }
        #expect(snapshot(.fullTime).liveMatch == nil)
        #expect(snapshot(.firstHalf, shown: false).liveMatch == nil)
        #expect(snapshot(.preMatch, glance: .idle).liveMatch == nil)
    }

    @Test func keepsTheNewestMatchFromTheHistory() {
        let result = snapshot(.fullTime, last: lastMatch).lastResult
        #expect(result?.homeTeamName == "Rangers RFC")
        #expect(result?.homeScore == 24)
        #expect(result?.awayScore == 17)
        #expect(snapshot(.fullTime).lastResult == nil)
    }

    @Test func aMatchTheAppStoppedUpdatingGivesWayToTheLastResult() {
        let live = snapshot(.firstHalf)
        #expect(live.liveMatch(at: now.addingTimeInterval(3600)) != nil)
        #expect(live.liveMatch(at: live.liveMatchExpiresAt) == nil)
    }

    @Test func clockJitterIsNotAChangeButAScoreIs() {
        var jittered = glance
        jittered.clockEndsAt = glance.clockEndsAt?.addingTimeInterval(0.4)
        #expect(snapshot(.firstHalf).showsSame(as: snapshot(.firstHalf, glance: jittered)))
        var scored = glance
        scored.homeScore += 5
        #expect(!snapshot(.firstHalf).showsSame(as: snapshot(.firstHalf, glance: scored)))
        #expect(!snapshot(.firstHalf).showsSame(as: snapshot(.fullTime)))
    }

    @Test func storeRoundTripsAndFallsBackToEmpty() throws {
        let defaults = try #require(UserDefaults(suiteName: "MatchWidgetSnapshotTests"))
        defaults.removePersistentDomain(forName: "MatchWidgetSnapshotTests")
        #expect(MatchWidgetStore.load(from: defaults) == .empty)
        let saved = snapshot(.secondHalf, last: lastMatch)
        MatchWidgetStore.save(saved, to: defaults)
        #expect(MatchWidgetStore.load(from: defaults) == saved)
    }
}
