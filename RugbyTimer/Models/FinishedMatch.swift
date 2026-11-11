//
//  FinishedMatch.swift
//  RugbyTimer
//

import Foundation

/// Where a match was run: the Watch (set up on iPhone), the iPhone alone, or a Watch Quick Match.
nonisolated public enum MatchSource: String, Codable {
    case watch
    case iPhone
    case quickMatch
}

/// A match at full time, as it goes into the history. The Watch sends one for a Quick Match,
/// which the iPhone otherwise never sees.
nonisolated public struct FinishedMatch: Codable, Equatable {
    public var matchID: UUID
    public var home: String
    public var away: String
    public var homeScore: Int
    public var awayScore: Int
    public var halfSeconds: Int
    public var extraTimeFormat: ExtraTimeFormat
    public var source: MatchSource
    public var events: [MatchEvent]
}

extension AppState {
    /// This match once it's over; nil before full time.
    public var finishedMatch: FinishedMatch? {
        guard matchPeriod == .fullTime, let matchID else { return nil }
        return FinishedMatch(
            matchID: matchID, home: homeTeamName, away: awayTeamName,
            homeScore: homeScore, awayScore: awayScore, halfSeconds: matchDurationSeconds,
            extraTimeFormat: extraTimeFormat,
            source: isPhoneHosted ? .iPhone : isWatchOnlyMatch ? .quickMatch : .watch,
            events: matchEvents
        )
    }
}
