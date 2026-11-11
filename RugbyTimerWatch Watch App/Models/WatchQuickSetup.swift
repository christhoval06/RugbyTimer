import Foundation

/// The choices on the Watch Quick Match screen. The last choices are remembered,
/// so the next quick match is a single tap on READY.
nonisolated struct WatchQuickSetup: Codable, Equatable {
    static let halfMinuteOptions = [40, 35, 30, 25, 20, 15, 10, 7]
    static let breakMinuteOptions = [1, 2, 5, 10, 15]
    static let sinBinMinuteOptions = [10, 5, 2, 1]
    static let defaultsKey = "watch.quickSetup" // l10n-ignore: defaults key

    var halfSeconds = 2400
    var halfTimeBreakSeconds = 120
    var sinBinSeconds = 600
    var tapLockEnabled = true
    var coinTossEnabled = false
    var twentyMinuteRedEnabled = false
    var extraTimeFormat = ExtraTimeFormat.off

    static func load(from defaults: UserDefaults = .standard) -> WatchQuickSetup {
        guard let data = defaults.data(forKey: defaultsKey),
              let setup = try? JSONDecoder().decode(WatchQuickSetup.self, from: data) else {
            return WatchQuickSetup()
        }
        return setup
    }

    func save(to defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: Self.defaultsKey)
    }
}
