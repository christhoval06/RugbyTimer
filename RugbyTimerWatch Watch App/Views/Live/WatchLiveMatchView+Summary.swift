import SwiftUI

extension WatchLiveMatchView {
    /// Score, cards, events and break time, bundled for the Clock and Result pages.
    var summary: WatchMatchSummary {
        WatchMatchSummary(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                          homeScore: homeScore, awayScore: awayScore, matchPeriod: matchPeriod,
                          activeCards: activeCards, matchEvents: matchEvents,
                          breakEndsAt: halfTimeBreakEndsAt, breakSeconds: halfTimeBreakSeconds, injuries: injuryTimers,
                          substitutionRules: substitutionRules)
    }
}
