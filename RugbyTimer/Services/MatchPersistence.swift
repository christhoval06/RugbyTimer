//
//  MatchPersistence.swift
//  RugbyTimer
//

import Foundation

/// Stores the match in progress on disk, so a crash or force-quit doesn't lose it.
public struct MatchPersistence {
    let fileURL: URL

    public init(fileURL: URL = MatchPersistence.defaultURL) {
        self.fileURL = fileURL
    }

    public static var defaultURL: URL {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return folder.appendingPathComponent("current-match.json") // l10n-ignore: file name
    }

    public func load() -> SavedMatch? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(SavedMatch.self, from: data)
    }

    public func save(_ match: SavedMatch) {
        guard let data = try? JSONEncoder().encode(match) else { return }
        try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
        try? data.write(to: fileURL, options: .atomic)
    }

    public func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
