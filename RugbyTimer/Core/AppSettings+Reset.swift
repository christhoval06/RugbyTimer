import Foundation

extension AppSettings {
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
        extraTimeFormat = .off
        substitutionRules = SubstitutionRules()
        halfTimeBreakSeconds = Self.standardHalfTimeBreakSeconds
        liveActivityEnabled = true
    }
}
