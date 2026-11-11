//
//  InMemoryMatchHistoryStorage.swift
//  RugbyTimer
//

import Foundation

/// A match history that lives only in memory: for unit tests and SwiftUI previews.
final class InMemoryMatchHistoryStorage: MatchHistoryStorage {
    private var entries: [MatchHistoryEntry] = []

    init(_ matches: [FinishedMatch] = [], playedAt: Date = Date()) {
        for (offset, match) in matches.enumerated() {
            insert(match, playedAt: playedAt.addingTimeInterval(TimeInterval(-offset * 86_400)))
        }
    }

    func loadAll() -> [MatchHistoryEntry] { entries.sorted { $0.playedAt > $1.playedAt } }

    func contains(matchID: UUID) -> Bool { entries.contains { $0.matchID == matchID } }

    func insert(_ match: FinishedMatch, playedAt: Date) {
        entries.append(Self.entry(match, playedAt: playedAt))
    }

    func update(_ match: FinishedMatch) {
        guard let index = entries.firstIndex(where: { $0.matchID == match.matchID }) else { return }
        entries[index] = Self.entry(match, playedAt: entries[index].playedAt)
    }

    func delete(matchID: UUID) {
        entries.removeAll { $0.matchID == matchID }
    }

    private static func entry(_ match: FinishedMatch, playedAt: Date) -> MatchHistoryEntry {
        MatchHistoryEntry(
            matchID: match.matchID, playedAt: playedAt, homeTeam: match.home, awayTeam: match.away,
            homeScore: match.homeScore, awayScore: match.awayScore, halfSeconds: match.halfSeconds,
            extraTimeFormat: match.extraTimeFormat, source: match.source, events: match.events
        )
    }
}
