import Foundation
import Testing
@testable import RugbyTimerWatch_Watch_App

/// Quick Match: a match set up on the Watch alone, never synced with the iPhone.
struct QuickMatchTests {
    private let setup = WatchQuickSetup(halfSeconds: 420, halfTimeBreakSeconds: 60, sinBinSeconds: 120,
                                        tapLockEnabled: false, coinTossEnabled: true)

    private func phoneSetup(_ id: UUID = UUID(), home: String = "Rangers RFC") -> MatchConfiguration {
        MatchConfiguration(matchID: id, home: home, away: "City Lions", duration: 2400)
    }

    @MainActor @Test func quickMatchUsesTheWatchChoices() {
        let state = AppState()
        state.startQuickMatch(setup)

        #expect(state.hasConfiguredMatch)
        #expect(state.isWatchOnlyMatch)
        #expect(state.matchPeriod == .preMatch)
        #expect(!state.homeTeamName.isEmpty && state.homeTeamName != state.awayTeamName)
        #expect(state.matchDurationSeconds == 420)
        #expect(state.timerService.timeRemaining == 420)
        #expect(state.halfTimeBreakSeconds == 60)
        #expect(state.sinBinDurationSeconds == 120)
        #expect(!state.tapLockEnabled)
        #expect(state.needsCoinToss)
    }

    @MainActor @Test func quickMatchCannotReplaceAMatchAlreadySetUp() {
        let state = AppState()
        state.connectivityService.receivedConfiguration = phoneSetup()
        state.startQuickMatch(setup)
        #expect(!state.isWatchOnlyMatch)
        #expect(state.homeTeamName == "Rangers RFC")
    }

    @MainActor @Test func resentPhoneSetupDoesNotReplaceQuickMatch() {
        let state = AppState()
        let old = phoneSetup()
        state.connectivityService.receivedConfiguration = old
        state.leaveMatch()
        #expect(!state.hasConfiguredMatch)

        state.startQuickMatch(setup)
        // The iPhone resends its last setup with every context update.
        state.connectivityService.receivedConfiguration = old
        #expect(state.isWatchOnlyMatch)
        #expect(state.matchDurationSeconds == 420)
    }

    @MainActor @Test func newPhoneSetupReplacesQuickMatchBeforeKickOff() {
        let state = AppState()
        state.startQuickMatch(setup)
        state.connectivityService.receivedConfiguration = phoneSetup(home: "Titanes")
        #expect(!state.isWatchOnlyMatch)
        #expect(state.homeTeamName == "Titanes")
    }

    @MainActor @Test func phoneSetupCannotInterruptQuickMatchInPlay() {
        let state = AppState()
        state.startQuickMatch(WatchQuickSetup())
        state.startMatch()
        state.connectivityService.receivedConfiguration = phoneSetup(home: "Titanes")
        #expect(state.isWatchOnlyMatch)
        #expect(state.matchPeriod == .firstHalf)
        state.timerService.pause()
    }

    @MainActor @Test func iPhoneResetIgnoresQuickMatch() throws {
        let state = AppState()
        state.startQuickMatch(setup)
        state.connectivityService.receivedMatchReset = UUID()
        #expect(state.hasConfiguredMatch)
    }

    @MainActor @Test func leaveMatchOnlyBeforeKickOffOrAtFullTime() {
        let state = AppState()
        state.startQuickMatch(WatchQuickSetup())
        state.startMatch()
        state.leaveMatch()
        #expect(state.hasConfiguredMatch)

        state.endMatch()
        state.recordScore(team: state.homeTeamName, points: 5, description: "Try scored (+5)")
        state.leaveMatch()
        #expect(!state.hasConfiguredMatch)
        #expect(!state.isWatchOnlyMatch)
        #expect(state.homeScore == 0)
        #expect(state.matchPeriod == .preMatch)
    }

    @Test func quickSetupRemembersTheLastChoices() throws {
        let defaults = try #require(UserDefaults(suiteName: "QuickMatchTests"))
        defaults.removePersistentDomain(forName: "QuickMatchTests")
        #expect(WatchQuickSetup.load(from: defaults) == WatchQuickSetup())
        setup.save(to: defaults)
        #expect(WatchQuickSetup.load(from: defaults) == setup)
    }
}
