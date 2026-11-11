import Foundation

extension MatchWidgetSnapshot {
    /// The widget's picture of the app: the match while it is set up or under way and on screen,
    /// and the newest match in the history.
    static func make(glance: MatchGlance, period: MatchPeriod, isMatchShown: Bool,
                     lastMatch: MatchHistoryEntry?, now: Date = Date()) -> MatchWidgetSnapshot {
        let isLive = isMatchShown && !glance.isIdle && period != .fullTime
        return MatchWidgetSnapshot(
            liveMatch: isLive ? glance : nil,
            lastResult: lastMatch.map(MatchWidgetResult.init(entry:)),
            savedAt: now,
            lastMatchLabel: String(appLocalized: "LAST MATCH"),
            noMatchesLabel: String(appLocalized: "NO MATCHES YET"),
            localeIdentifier: AppLanguage.current.locale.identifier
        )
    }

    /// Same picture on the widget: ignores when it was saved and sub-second clock jitter.
    func showsSame(as other: MatchWidgetSnapshot) -> Bool {
        let sameMatch = switch (liveMatch, other.liveMatch) {
        case (nil, nil): true
        case let (mine?, theirs?): mine.isSameGlance(as: theirs)
        default: false
        }
        return sameMatch && lastResult == other.lastResult && lastMatchLabel == other.lastMatchLabel
            && noMatchesLabel == other.noMatchesLabel && localeIdentifier == other.localeIdentifier
    }
}

extension MatchWidgetResult {
    init(entry: MatchHistoryEntry) {
        self.init(homeTeamName: entry.homeTeam, awayTeamName: entry.awayTeam,
                  homeScore: entry.homeScore, awayScore: entry.awayScore, playedAt: entry.playedAt)
    }
}
