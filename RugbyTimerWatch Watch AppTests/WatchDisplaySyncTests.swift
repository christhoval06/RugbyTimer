import Foundation
import Testing
@testable import RugbyTimerWatch_Watch_App

struct WatchDisplaySyncTests {
    @MainActor @Test func newSetupAppliesBothPreferencesButReplayPreservesWatchEdits() throws {
        let suiteName = UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let state = AppState()
        var setup = MatchConfiguration(matchID: UUID(), home: "Home", away: "Away", duration: 2400)
        let phoneChoices = WatchDisplayPreferences(extendedLayout: true, showDiscipline: false)
        setup.watchDisplayPreferences = phoneChoices

        let data = try JSONEncoder().encode(setup)
        let received = try JSONDecoder().decode(MatchConfiguration.self, from: data)
        state.receiveConfiguration(received, displayDefaults: defaults)
        #expect(WatchDisplayPreferences.load(from: defaults) == phoneChoices)

        let watchChoices = WatchDisplayPreferences.standard
        watchChoices.save(to: defaults)
        state.receiveConfiguration(received, displayDefaults: defaults)
        #expect(WatchDisplayPreferences.load(from: defaults) == watchChoices)
    }

    @MainActor @Test func olderSetupPreservesWatchPreferences() throws {
        let suiteName = UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let watchChoices = WatchDisplayPreferences(extendedLayout: true, showDiscipline: false)
        watchChoices.save(to: defaults)

        let state = AppState()
        let legacySetup = MatchConfiguration(matchID: UUID(), home: "Home", away: "Away", duration: 2400)
        state.receiveConfiguration(legacySetup, displayDefaults: defaults)
        #expect(WatchDisplayPreferences.load(from: defaults) == watchChoices)
    }
}
