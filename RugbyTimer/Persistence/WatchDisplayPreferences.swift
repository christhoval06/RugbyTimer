import Foundation

nonisolated public struct WatchDisplayPreferences: Codable, Equatable {
    static let extendedLayoutKey = "watchExtendedLayout"
    static let showDisciplineKey = "watchShowDiscipline"
    static let standard = Self(extendedLayout: false, showDiscipline: true)

    var extendedLayout: Bool
    var showDiscipline: Bool

    static func load(from defaults: UserDefaults = .standard) -> Self {
        Self(
            extendedLayout: defaults.object(forKey: extendedLayoutKey) as? Bool ?? standard.extendedLayout,
            showDiscipline: defaults.object(forKey: showDisciplineKey) as? Bool ?? standard.showDiscipline
        )
    }

    func save(to defaults: UserDefaults) {
        defaults.set(extendedLayout, forKey: Self.extendedLayoutKey)
        defaults.set(showDiscipline, forKey: Self.showDisciplineKey)
    }
}
