//
//  MatchHistoryStorage.swift
//  RugbyTimer
//

import Foundation

/// Where finished matches are kept. `MatchHistory` is the only caller; the app ships
/// `SwiftDataMatchHistoryStorage`, and tests and previews use `InMemoryMatchHistoryStorage`.
protocol MatchHistoryStorage {
    /// Every saved match, newest first.
    func loadAll() -> [MatchHistoryEntry]
    func contains(matchID: UUID) -> Bool
    func insert(_ match: FinishedMatch, playedAt: Date)
    /// Refreshes a saved match from a later report; keeps when it was played.
    func update(_ match: FinishedMatch)
    func delete(matchID: UUID)
}
