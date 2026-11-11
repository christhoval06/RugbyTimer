import Foundation
import Testing
@testable import RugbyTimerWatch_Watch_App

/// Substitution rules on the Watch: from the iPhone setup, or chosen in Quick Match.
struct WatchSubstitutionTests {
    @MainActor @Test func phoneSetupBringsItsSubstitutionRules() {
        let state = AppState()
        var setup = MatchConfiguration(matchID: UUID(), home: "Titanes", away: "City Lions", duration: 2400)
        setup.substitutionRules = SubstitutionRules(isEnabled: true, limit: 5)
        state.connectivityService.receivedConfiguration = setup
        #expect(state.substitutionRules == SubstitutionRules(isEnabled: true, limit: 5))

        // An older iPhone sends no rules: substitutions stay off.
        state.leaveMatch()
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Titanes", away: "City Lions", duration: 2400)
        #expect(!state.substitutionRules.isEnabled)
    }

    @MainActor @Test func quickMatchUsesItsSubstitutionChoice() {
        let state = AppState()
        var choices = WatchQuickSetup()
        choices.substitutionRules = SubstitutionRules(isEnabled: true, limit: SubstitutionRules.unlimited)
        state.startQuickMatch(choices)
        #expect(state.substitutionRules.isEnabled)
        #expect(!state.substitutionRules.hasLimit)
    }

    @Test func quickSetupSavedBeforeSubstitutionsStillLoads() throws {
        let defaults = try #require(UserDefaults(suiteName: "QuickMatchTests.legacy"))
        defaults.removePersistentDomain(forName: "QuickMatchTests.legacy")
        let legacy = #"{"halfSeconds":420,"halfTimeBreakSeconds":60,"sinBinSeconds":120,"tapLockEnabled":false,"coinTossEnabled":true,"twentyMinuteRedEnabled":false,"extraTimeFormat":"off"}"#
        defaults.set(Data(legacy.utf8), forKey: WatchQuickSetup.defaultsKey)
        let loaded = WatchQuickSetup.load(from: defaults)
        #expect(loaded.halfSeconds == 420)
        #expect(!loaded.substitutionRules.isEnabled)
    }
}
