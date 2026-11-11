//
//  Infringement.swift
//  RugbyTimer
//

import Foundation

/// A penalty or free kick awarded against a team. Each one is a match-record entry for the
/// team that conceded it, so it can be undone and split by half; the record shows the
/// counts, not every entry.
nonisolated public enum Infringement: String, CaseIterable {
    case penalty
    case freeKick

    /// English, like every synced description.
    var eventDescription: String {
        self == .penalty ? "Penalty conceded" : "Free kick conceded" // l10n-ignore: synced English
    }

    /// The infringement an entry records, if it records one.
    static func of(_ event: MatchEvent) -> Infringement? {
        guard event.type == .sub else { return nil }
        return allCases.first { $0.eventDescription == event.description }
    }
}

/// Penalties and free kicks conceded by one team.
nonisolated public struct InfringementCount: Equatable {
    public var penalties = 0
    public var freeKicks = 0

    /// Counts the team's infringements in `events`.
    public static func count(in events: [MatchEvent], team: String) -> InfringementCount {
        events.reduce(into: InfringementCount()) { total, event in
            guard event.teamName == team, let kind = Infringement.of(event) else { return }
            if kind == .penalty { total.penalties += 1 } else { total.freeKicks += 1 }
        }
    }

    /// The same count for the first and second half, split at the half-time whistle.
    public static func byHalf(in events: [MatchEvent], team: String)
        -> (firstHalf: InfringementCount, secondHalf: InfringementCount) {
        let split = events.firstIndex { $0.type == .sub && $0.description == MatchStats.halfTimeWhistle } ?? events.endIndex
        return (count(in: Array(events[..<split]), team: team), count(in: Array(events[split...]), team: team))
    }
}
