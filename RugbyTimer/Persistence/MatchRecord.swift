//
//  MatchRecord.swift
//  RugbyTimer
//

import Foundation
import SwiftData

/// How a finished match is stored in SwiftData. Only `SwiftDataMatchHistoryStorage` uses it;
/// the rest of the app sees `MatchHistoryEntry`.
///
/// The fields the list sorts and shows are stored on their own; the timeline is stored as
/// encoded `MatchEvent`s, the same encoding the Watch sync and crash recovery use. Every
/// field has a default and nothing is unique, so the store can sync with iCloud later.
@Model
final class MatchRecord {
    var matchID: UUID = UUID()
    var playedAt: Date = Date()
    var homeTeam: String = ""
    var awayTeam: String = ""
    var homeScore: Int = 0
    var awayScore: Int = 0
    var halfSeconds: Int = 2400
    var extraTimeFormatRaw: String = ExtraTimeFormat.off.rawValue
    var sourceRaw: String = MatchSource.iPhone.rawValue
    var eventsData: Data = Data()

    init(_ match: FinishedMatch, playedAt: Date) {
        self.playedAt = playedAt
        update(from: match)
    }

    func update(from match: FinishedMatch) {
        matchID = match.matchID
        homeTeam = match.home
        awayTeam = match.away
        homeScore = match.homeScore
        awayScore = match.awayScore
        halfSeconds = match.halfSeconds
        extraTimeFormatRaw = match.extraTimeFormat.rawValue
        sourceRaw = match.source.rawValue
        eventsData = (try? JSONEncoder().encode(match.events)) ?? Data()
    }

    var entry: MatchHistoryEntry {
        MatchHistoryEntry(
            matchID: matchID, playedAt: playedAt, homeTeam: homeTeam, awayTeam: awayTeam,
            homeScore: homeScore, awayScore: awayScore, halfSeconds: halfSeconds,
            extraTimeFormat: ExtraTimeFormat(rawValue: extraTimeFormatRaw) ?? .off,
            source: MatchSource(rawValue: sourceRaw) ?? .iPhone,
            events: (try? JSONDecoder().decode([MatchEvent].self, from: eventsData)) ?? []
        )
    }
}
