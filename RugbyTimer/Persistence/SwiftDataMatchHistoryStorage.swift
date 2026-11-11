//
//  SwiftDataMatchHistoryStorage.swift
//  RugbyTimer
//

import Foundation
import SwiftData

/// The match history on disk, in SwiftData. The only file outside `MatchRecord` that knows
/// about SwiftData.
final class SwiftDataMatchHistoryStorage: MatchHistoryStorage {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    /// `inMemory` keeps nothing on disk (tests). If the store on disk can't be opened, the
    /// history falls back to memory for this launch rather than stopping the app.
    init(inMemory: Bool = false) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        if let container = try? ModelContainer(for: MatchRecord.self, configurations: configuration) {
            self.container = container
        } else {
            self.container = try! ModelContainer(
                for: MatchRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        }
    }

    func loadAll() -> [MatchHistoryEntry] {
        let newestFirst = FetchDescriptor<MatchRecord>(sortBy: [SortDescriptor(\.playedAt, order: .reverse)])
        return ((try? context.fetch(newestFirst)) ?? []).map(\.entry)
    }

    func contains(matchID: UUID) -> Bool { record(matchID) != nil }

    func insert(_ match: FinishedMatch, playedAt: Date) {
        context.insert(MatchRecord(match, playedAt: playedAt))
        try? context.save()
    }

    func update(_ match: FinishedMatch) {
        record(match.matchID)?.update(from: match)
        try? context.save()
    }

    func delete(matchID: UUID) {
        guard let record = record(matchID) else { return }
        context.delete(record)
        try? context.save()
    }

    private func record(_ id: UUID) -> MatchRecord? {
        try? context.fetch(FetchDescriptor<MatchRecord>(predicate: #Predicate { $0.matchID == id })).first
    }
}
