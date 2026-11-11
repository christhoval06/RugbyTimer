import Foundation

/// What the watch-face complication shows, written by the Watch app and read by the widget.
/// Labels arrive already translated, so the complication follows the in-app language setting.
nonisolated struct ComplicationSnapshot: Codable, Equatable {
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
    /// No match set up on the Watch.
    var isIdle: Bool { homeTeamName.isEmpty && awayTeamName.isEmpty }

    /// Shown before kick-off and after a match: the app name and no clock.
    static let idle = ComplicationSnapshot(
        homeTeamName: "", awayTeamName: "", homeScore: 0, awayScore: 0,
        periodLabel: "", pausedLabel: "", timeUpLabel: "",
        clockEndsAt: nil, clockSeconds: 0, periodSeconds: 0,
        breakEndsAt: nil, nextSinBinEndsAt: nil, sinBinCount: 0, isPlaying: false, isMatchLive: false
    )

    /// A three-letter code for tight complications: "Rangers RFC" → "RAN".
    static func code(for teamName: String) -> String {
        String(teamName.filter { $0.isLetter || $0.isNumber }.prefix(3)).uppercased()
    }
}

/// The App Group store both the Watch app and its widget extension read.
nonisolated enum ComplicationStore {
    static let appGroup = "group.dev.christhoval.apps.RugbyTimer"
    static let key = "complication.snapshot"

    static func load(from defaults: UserDefaults? = UserDefaults(suiteName: appGroup)) -> ComplicationSnapshot {
        guard let data = defaults?.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(ComplicationSnapshot.self, from: data) else { return .idle }
        return snapshot
    }

    static func save(_ snapshot: ComplicationSnapshot, to defaults: UserDefaults? = UserDefaults(suiteName: appGroup)) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults?.set(data, forKey: key)
    }
}
