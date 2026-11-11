import Foundation

/// The App Group store the Watch app writes and its complication reads.
nonisolated enum ComplicationStore {
    static let appGroup = "group.dev.christhoval.apps.RugbyTimer"
    static let key = "complication.snapshot"

    static func load(from defaults: UserDefaults? = UserDefaults(suiteName: appGroup)) -> MatchGlance {
        guard let data = defaults?.data(forKey: key),
              let glance = try? JSONDecoder().decode(MatchGlance.self, from: data) else { return .idle }
        return glance
    }

    static func save(_ glance: MatchGlance, to defaults: UserDefaults? = UserDefaults(suiteName: appGroup)) {
        guard let data = try? JSONEncoder().encode(glance) else { return }
        defaults?.set(data, forKey: key)
    }
}
