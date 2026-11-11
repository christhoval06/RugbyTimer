//
//  AppSettings.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/09/26.
//

import Foundation
import Combine

/// Referee preferences persisted on iPhone. Match defaults seed every new setup.
final class AppSettings: ObservableObject {
    static let halfLengthOptions = [40, 35, 30, 25, 20, 15, 10, 7]
    static let sinBinOptions = [10, 5, 2, 1]
    /// World Rugby allows up to 15 minutes at half-time.
    static let halfTimeBreakOptions = [15, 10, 5, 2]
    static let playerRangeOptions: [(max: Int, label: LocalizedStringResource)] = [
        (15, "Starting XV"), (23, "Match-day squad"), (30, "Extended squad"),
        (40, "Squad + extras"), (50, "Large squad"), (99, "Any number")
    ]

    static let standardHalfSeconds = 2400
    static let standardSinBinSeconds = 600
    static let standardMaxPlayerNumber = 40
    static let standardHalfTimeBreakSeconds = 120
    static let standardHomeTeam = "Rangers RFC"
    static let standardAwayTeam = "City Lions"

    private enum Key {
        static let onboarding = "settings.hasCompletedOnboarding"
        static let halfLength = "settings.defaultHalfSeconds"
        static let sinBin = "settings.defaultSinBinSeconds"
        static let maxPlayer = "settings.maxPlayerNumber"
        static let home = "settings.defaultHomeTeam"
        static let away = "settings.defaultAwayTeam"
        static let haptics = HapticService.enabledDefaultsKey
        static let keepAwake = "settings.keepScreenAwake"
        static let tapLock = "settings.tapLockEnabled"
        static let coinToss = "settings.coinTossEnabled"
        static let twentyMinuteRed = "settings.twentyMinuteRedEnabled"
        static let halfTimeBreak = "settings.halfTimeBreakSeconds"
        static let language = AppLanguage.defaultsKey
    }

    private let defaults: UserDefaults

    @Published var hasCompletedOnboarding: Bool { didSet { defaults.set(hasCompletedOnboarding, forKey: Key.onboarding) } }
    @Published var defaultHalfSeconds: Int { didSet { defaults.set(defaultHalfSeconds, forKey: Key.halfLength) } }
    @Published var defaultSinBinSeconds: Int { didSet { defaults.set(defaultSinBinSeconds, forKey: Key.sinBin) } }
    @Published var maxPlayerNumber: Int { didSet { defaults.set(maxPlayerNumber, forKey: Key.maxPlayer) } }
    @Published var defaultHomeTeam: String { didSet { defaults.set(defaultHomeTeam, forKey: Key.home) } }
    @Published var defaultAwayTeam: String { didSet { defaults.set(defaultAwayTeam, forKey: Key.away) } }
    @Published var hapticsEnabled: Bool { didSet { defaults.set(hapticsEnabled, forKey: Key.haptics) } }
    @Published var keepScreenAwake: Bool { didSet { defaults.set(keepScreenAwake, forKey: Key.keepAwake) } }
    @Published var tapLockEnabled: Bool { didSet { defaults.set(tapLockEnabled, forKey: Key.tapLock) } }
    @Published var coinTossEnabled: Bool { didSet { defaults.set(coinTossEnabled, forKey: Key.coinToss) } }
    @Published var twentyMinuteRedEnabled: Bool {
        didSet { defaults.set(twentyMinuteRedEnabled, forKey: Key.twentyMinuteRed) }
    }
    @Published var halfTimeBreakSeconds: Int { didSet { defaults.set(halfTimeBreakSeconds, forKey: Key.halfTimeBreak) } }
    /// Not part of "Restore defaults": resetting would switch the app to a language the referee may not read.
    @Published var language: AppLanguage { didSet { defaults.set(language.rawValue, forKey: Key.language) } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasCompletedOnboarding = defaults.bool(forKey: Key.onboarding)
        defaultHalfSeconds = defaults.positiveInt(forKey: Key.halfLength) ?? Self.standardHalfSeconds
        defaultSinBinSeconds = defaults.positiveInt(forKey: Key.sinBin) ?? Self.standardSinBinSeconds
        maxPlayerNumber = defaults.positiveInt(forKey: Key.maxPlayer) ?? Self.standardMaxPlayerNumber
        defaultHomeTeam = defaults.string(forKey: Key.home) ?? Self.standardHomeTeam
        defaultAwayTeam = defaults.string(forKey: Key.away) ?? Self.standardAwayTeam
        hapticsEnabled = defaults.object(forKey: Key.haptics) as? Bool ?? true
        keepScreenAwake = defaults.object(forKey: Key.keepAwake) as? Bool ?? true
        tapLockEnabled = defaults.object(forKey: Key.tapLock) as? Bool ?? true
        coinTossEnabled = defaults.bool(forKey: Key.coinToss)
        twentyMinuteRedEnabled = defaults.bool(forKey: Key.twentyMinuteRed)
        halfTimeBreakSeconds = defaults.positiveInt(forKey: Key.halfTimeBreak) ?? Self.standardHalfTimeBreakSeconds
        language = defaults.string(forKey: Key.language).flatMap(AppLanguage.init(rawValue:)) ?? .system
        // UI tests launch straight into Match Setup; not persisted.
        if ProcessInfo.processInfo.arguments.contains("-skipOnboarding") { hasCompletedOnboarding = true }
    }

    /// Restores every preference except the onboarding flag.
    func resetToStandard() {
        defaultHalfSeconds = Self.standardHalfSeconds
        defaultSinBinSeconds = Self.standardSinBinSeconds
        maxPlayerNumber = Self.standardMaxPlayerNumber
        defaultHomeTeam = Self.standardHomeTeam
        defaultAwayTeam = Self.standardAwayTeam
        hapticsEnabled = true
        keepScreenAwake = true
        tapLockEnabled = true
        coinTossEnabled = false
        twentyMinuteRedEnabled = false
        halfTimeBreakSeconds = Self.standardHalfTimeBreakSeconds
    }
}

private extension UserDefaults {
    func positiveInt(forKey key: String) -> Int? {
        let value = integer(forKey: key)
        return value > 0 ? value : nil
    }
}
