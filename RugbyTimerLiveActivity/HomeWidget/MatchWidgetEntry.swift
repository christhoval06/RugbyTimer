import Foundation
import WidgetKit

/// One moment of the Home Screen widget: the saved snapshot read at `date`.
struct MatchWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: MatchWidgetSnapshot

    /// The match under way, read at this moment; nil once it is over or went quiet.
    var liveMatch: MatchClockEntry? {
        snapshot.liveMatch(at: date).map { MatchClockEntry(date: date, glance: $0) }
    }

    /// For the Lock Screen sizes: the live match, else the last result as a glance labelled
    /// "LAST MATCH", else the idle glance (app name).
    var accessoryEntry: MatchClockEntry {
        if let liveMatch { return liveMatch }
        guard let result = snapshot.lastResult else { return MatchClockEntry(date: date, glance: .idle) }
        var glance = MatchGlance.idle
        glance.homeTeamName = result.homeTeamName
        glance.awayTeamName = result.awayTeamName
        glance.homeScore = result.homeScore
        glance.awayScore = result.awayScore
        glance.periodLabel = snapshot.lastMatchLabel
        return MatchClockEntry(date: date, glance: glance)
    }

    var locale: Locale { Locale(identifier: snapshot.localeIdentifier) }
}

extension MatchWidgetEntry {
    /// Preview and gallery entries: a running half, a closing half with a sin-bin, the last result, nothing yet.
    static var samples: [MatchWidgetEntry] {
        let now = Date()
        let glances = MatchGlance.samples(now: now)
        var live = MatchWidgetSnapshot.empty
        live.savedAt = now
        live.liveMatch = glances[0]
        var closing = live
        closing.liveMatch = glances[1]
        var result = MatchWidgetSnapshot.empty
        result.lastResult = MatchWidgetResult(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", // l10n-ignore: sample data
                                        homeScore: 24, awayScore: 17, playedAt: now.addingTimeInterval(-2 * 86_400))
        return [live, closing, result, .empty].map { MatchWidgetEntry(date: now, snapshot: $0) }
    }
}
