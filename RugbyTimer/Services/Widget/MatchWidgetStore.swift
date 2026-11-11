import Foundation

/// The App Group store the iPhone app writes and its Home Screen widget reads.
nonisolated enum MatchWidgetStore {
    static let appGroup = "group.dev.christhoval.apps.RugbyTimer" // l10n-ignore: App Group identifier
    static let key = "widget.match" // l10n-ignore: defaults key
    static let kind = "RugbyTimerMatchWidget" // l10n-ignore: widget kind

    static func load(from defaults: UserDefaults? = UserDefaults(suiteName: appGroup)) -> MatchWidgetSnapshot {
        guard let data = defaults?.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(MatchWidgetSnapshot.self, from: data) else { return .empty }
        return snapshot
    }

    static func save(_ snapshot: MatchWidgetSnapshot, to defaults: UserDefaults? = UserDefaults(suiteName: appGroup)) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults?.set(data, forKey: key)
    }
}
