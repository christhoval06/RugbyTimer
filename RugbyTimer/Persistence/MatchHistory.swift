//
//  MatchHistory.swift
//  RugbyTimer
//

import Foundation
import Combine

/// The match history the screens observe. It keeps the list and the rules for saving;
/// the storage behind it is swappable (`MatchHistoryStorage`).
final class MatchHistory: ObservableObject {
    /// Every saved match, newest first.
    @Published private(set) var entries: [MatchHistoryEntry] = []

    private let storage: MatchHistoryStorage
    private var recordedIDs: RecordedMatchIDs

    init(storage: MatchHistoryStorage, recordedIDs: RecordedMatchIDs = RecordedMatchIDs()) {
        self.storage = storage
        self.recordedIDs = recordedIDs
        entries = storage.loadAll()
    }

    /// A match is reported several times at full time (every Watch update, every relaunch):
    /// a known match is updated, never duplicated, and one the referee deleted stays deleted.
    func save(_ match: FinishedMatch) {
        if storage.contains(matchID: match.matchID) {
            storage.update(match)
        } else if !recordedIDs.contains(match.matchID) {
            storage.insert(match, playedAt: Date())
            recordedIDs.add(match.matchID)
        } else {
            return
        }
        entries = storage.loadAll()
    }

    func delete(_ entry: MatchHistoryEntry) {
        storage.delete(matchID: entry.matchID)
        entries = storage.loadAll()
    }
}

/// The matches ever saved, so a deleted one isn't saved again when it's reported later.
struct RecordedMatchIDs {
    var defaults: UserDefaults = .standard

    static let key = "history.recordedMatchIDs" // l10n-ignore: defaults key
    /// Enough to cover any match still on screen; older matches can't be reported again.
    static let limit = 100

    func contains(_ id: UUID) -> Bool { ids.contains(id.uuidString) }

    mutating func add(_ id: UUID) {
        defaults.set(Array((ids + [id.uuidString]).suffix(Self.limit)), forKey: Self.key)
    }

    private var ids: [String] { defaults.stringArray(forKey: Self.key) ?? [] }
}
