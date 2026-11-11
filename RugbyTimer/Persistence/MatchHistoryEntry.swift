//
//  MatchHistoryEntry.swift
//  RugbyTimer
//

import Foundation

/// A finished match as the history screens see it: a plain value, with nothing from the
/// storage underneath (SwiftData stays inside `Persistence/`).
struct MatchHistoryEntry: Identifiable, Equatable {
    let matchID: UUID
    let playedAt: Date
    let homeTeam: String
    let awayTeam: String
    let homeScore: Int
    let awayScore: Int
    let halfSeconds: Int
    let extraTimeFormat: ExtraTimeFormat
    let source: MatchSource
    let events: [MatchEvent]

    var id: UUID { matchID }

    /// The shareable match record text, dated when the match was played.
    var recordText: String {
        MatchRecordFormatter.record(homeTeam: homeTeam, awayTeam: awayTeam, homeScore: homeScore,
                                    awayScore: awayScore, halfDurationSeconds: halfSeconds,
                                    events: events, date: playedAt)
    }
}
