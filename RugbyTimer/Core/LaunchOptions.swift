//
//  LaunchOptions.swift
//  RugbyTimer
//

import Foundation

/// Builds the app's state, settings and history. UI tests launch with `-uiTesting`, and then
/// every launch starts clean: no saved match to recover, default settings, an empty history
/// kept in memory. Nothing a test does touches the referee's real data.
enum LaunchOptions {
    static var isUITesting: Bool { ProcessInfo.processInfo.arguments.contains(uiTestingArgument) }
    static let uiTestingArgument = "-uiTesting" // l10n-ignore: launch argument

    static func makeAppState() -> AppState {
        if isUITesting { MatchPersistence().clear() }
        return AppState.launch()
    }

    static func makeSettings() -> AppSettings {
        AppSettings(defaults: settingsDefaults)
    }

    static func makeHistory() -> MatchHistory {
        guard isUITesting else { return MatchHistory(storage: SwiftDataMatchHistoryStorage()) }
        return MatchHistory(storage: InMemoryMatchHistoryStorage(), recordedIDs: RecordedMatchIDs(defaults: settingsDefaults))
    }

    /// UI tests get their own settings, wiped at every launch.
    private static let settingsDefaults: UserDefaults = {
        guard isUITesting else { return .standard }
        let suite = "RugbyTimer.uiTesting" // l10n-ignore: defaults suite
        UserDefaults.standard.removePersistentDomain(forName: suite)
        return UserDefaults(suiteName: suite) ?? .standard
    }()
}
