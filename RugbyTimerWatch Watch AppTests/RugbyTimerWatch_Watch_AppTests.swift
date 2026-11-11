import Foundation
import Testing
@testable import RugbyTimerWatch_Watch_App

/// Setting up a Watch match from the iPhone, and scoring.
struct RugbyTimerWatch_Watch_AppTests {
    @MainActor @Test func replacementSetupClearsPreviousWatchMatch() {
        let state = AppState()
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Old Home", away: "Old Away", duration: 2400
        )
        state.startMatch()
        state.recordScore(team: "Old Home", points: 5, description: "Previous try")
        state.addCard(team: "Old Home", playerNum: 8, type: .yellow)
        state.endMatch()

        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "New Home", away: "New Away", duration: 420,
            sinBinDurationSeconds: 120
        )

        #expect(state.homeTeamName == "New Home")
        #expect(state.awayTeamName == "New Away")
        #expect(state.sinBinDurationSeconds == 120)
        #expect(state.matchDurationText == "14:00 Total")
        #expect(state.homeScore == 0 && state.awayScore == 0)
        #expect(state.activeCards.isEmpty)
        #expect(state.matchEvents.isEmpty)
        #expect(state.matchPeriod == .preMatch)
        #expect(state.timerService.timeRemaining == 420)
        #expect(!state.timerService.isRunning)
    }

    @MainActor @Test func watchCannotStartWithoutPhoneSetup() {
        let state = AppState()
        #expect(!state.hasConfiguredMatch)
        state.startMatch()
        #expect(state.matchPeriod == .preMatch)
        #expect(!state.timerService.isRunning)
        state.timerService.pause()
    }

    @MainActor @Test func yellowCardsUseConfiguredSinBinDuration() throws {
        for seconds in [600, 120, 180] {
            let payload = """
            {"matchID":"\(UUID())","home":"Home","away":"Away","duration":2400,"sinBinDurationSeconds":\(seconds)}
            """
            let configuration = try JSONDecoder().decode(MatchConfiguration.self, from: Data(payload.utf8))
            let state = AppState()
            state.connectivityService.receivedConfiguration = configuration
            state.addCard(team: "Home", playerNum: 8, type: .yellow)
            #expect(state.activeCards.first?.remainingSeconds == seconds)
        }
    }

    @MainActor @Test func watchStartsConfiguredMatchAndIgnoresDuplicateSetup() {
        let state = AppState()
        let configuration = MatchConfiguration(matchID: UUID(), home: "Home XV", away: "Away XV", duration: 420)
        state.connectivityService.receivedConfiguration = configuration
        #expect(state.hasConfiguredMatch)
        #expect(state.matchPeriod == .preMatch)
        #expect(state.timerService.timeRemaining == 420)
        #expect(!state.timerService.isRunning)

        state.startMatch()
        #expect(state.matchPeriod == .firstHalf)
        #expect(state.timerService.isRunning)
        #expect(state.homeTeamName == "Home XV")
        state.connectivityService.receivedConfiguration = configuration
        #expect(state.matchPeriod == .firstHalf)
        #expect(state.timerService.isRunning)
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Late Home", away: "Late Away", duration: 1200
        )
        #expect(state.matchPeriod == .firstHalf)
        #expect(state.matchDurationSeconds == 420)
        #expect(state.homeTeamName == "Home XV")
        state.timerService.pause()
    }

    @MainActor @Test func scoresRecordOptionalScorer() {
        let state = AppState()
        state.recordScore(team: state.homeTeamName, points: 3, description: "Penalty goal (+3)")
        state.recordScore(team: state.awayTeamName, playerNumber: 37, points: 5, description: "Try scored (+5)")
        #expect(state.matchEvents.map(\.playerNumber) == [nil, 37])
        #expect(state.homeScore == 3 && state.awayScore == 5)
        #expect(MatchEvent.playerNumbers == 1...40)
    }
}
