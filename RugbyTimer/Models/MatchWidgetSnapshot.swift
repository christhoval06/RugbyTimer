import Foundation

/// What the iPhone Home Screen and Lock Screen widget shows: the match under way, or else the
/// last finished one. The app saves it to the App Group; labels arrive already translated.
nonisolated struct MatchWidgetSnapshot: Codable, Equatable {
    /// A match set up or under way; nil once it reaches full time or the referee leaves it.
    var liveMatch: MatchGlance?
    /// The newest match in the history.
    var lastResult: MatchWidgetResult?
    var savedAt: Date
    /// "LAST MATCH" and "NO MATCHES YET", in the app language.
    var lastMatchLabel: String
    var noMatchesLabel: String
    /// The app language's locale, for dates.
    var localeIdentifier: String

    /// A live match the app stopped updating (closed mid-match, phone off) gives way to the last result.
    static let liveMatchLifetime: TimeInterval = 4 * 60 * 60

    var liveMatchExpiresAt: Date { savedAt.addingTimeInterval(Self.liveMatchLifetime) }

    func liveMatch(at date: Date) -> MatchGlance? {
        date < liveMatchExpiresAt ? liveMatch : nil
    }

    /// Before the app has saved anything.
    static let empty = MatchWidgetSnapshot(
        liveMatch: nil, lastResult: nil, savedAt: .distantPast,
        lastMatchLabel: "LAST MATCH", noMatchesLabel: "NO MATCHES YET", // l10n-ignore: replaced by the app's translation
        localeIdentifier: "en" // l10n-ignore: locale identifier
    )
}

/// A finished match's final score.
nonisolated struct MatchWidgetResult: Codable, Equatable {
    var homeTeamName: String
    var awayTeamName: String
    var homeScore: Int
    var awayScore: Int
    var playedAt: Date
}
