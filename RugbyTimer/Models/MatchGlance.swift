import Foundation

/// The match at a glance, for the Watch complication and the iPhone Live Activity: score,
/// period and clock. Labels arrive already translated, so both follow the in-app language.
nonisolated struct MatchGlance: Codable, Hashable {
    var homeTeamName: String
    var awayTeamName: String
    var homeScore: Int
    var awayScore: Int
    /// Short period label, for example "H1", "HT" or "FT", in the app language.
    var periodLabel: String
    var pausedLabel: String
    var timeUpLabel: String
    /// While the clock runs: when the period's time is up. Past that date the clock counts overtime.
    var clockEndsAt: Date?
    /// While the clock is stopped: the reading to show, negative in overtime.
    var clockSeconds: Int
    /// The length of the period, for the progress ring.
    var periodSeconds: Int
    /// When the half-time interval ends; nil outside the break.
    var breakEndsAt: Date?
    /// The sin-bin due back first while the clock runs, and how many players are off.
    var nextSinBinEndsAt: Date?
    var sinBinCount: Int
    /// A half (or extra-time period) is on: show the match clock.
    var isPlaying: Bool
    /// Playing or at a break: the match is still to finish.
    var isMatchLive: Bool

    var isRunning: Bool { clockEndsAt != nil }
    /// No match set up.
    var isIdle: Bool { homeTeamName.isEmpty && awayTeamName.isEmpty }
    var isAtBreak: Bool { breakEndsAt != nil }
    /// Clock or break countdown on screen; otherwise (ready, full time) the score takes its place.
    var showsClock: Bool { isPlaying || isAtBreak }
    /// "12–7"
    var score: String { "\(homeScore)–\(awayScore)" } // l10n-ignore: numbers only
    var homeCode: String { Self.code(for: homeTeamName) }
    var awayCode: String { Self.code(for: awayTeamName) }

    /// Shown before kick-off and after a match: the app name and no clock.
    static let idle = MatchGlance(
        homeTeamName: "", awayTeamName: "", homeScore: 0, awayScore: 0,
        periodLabel: "", pausedLabel: "", timeUpLabel: "",
        clockEndsAt: nil, clockSeconds: 0, periodSeconds: 0,
        breakEndsAt: nil, nextSinBinEndsAt: nil, sinBinCount: 0, isPlaying: false, isMatchLive: false
    )

    /// A three-letter code for tight spaces: "Rangers RFC" → "RAN".
    static func code(for teamName: String) -> String {
        String(teamName.filter { $0.isLetter || $0.isNumber }.prefix(3)).uppercased()
    }
}
