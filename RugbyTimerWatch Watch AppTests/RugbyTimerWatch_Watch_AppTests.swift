import Foundation
import Testing
@testable import RugbyTimerWatch_Watch_App

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

    @MainActor @Test func watchAdvancesBothHalves() {
        let state = AppState()
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400
        )
        state.startMatch()
        state.handleTimerExpired()
        #expect(state.matchPeriod == .halfTime)
        #expect(!state.timerService.isRunning)
        state.startSecondHalf()
        #expect(state.matchPeriod == .secondHalf)
        #expect(state.timerService.isRunning)
        state.handleTimerExpired()
        #expect(state.matchPeriod == .fullTime)
        #expect(!state.timerService.isRunning)
    }

    @MainActor @Test func clockCatchesUpAfterSuspension() {
        var now = Date(timeIntervalSince1970: 1_000)
        let timer = MatchTimerService(initialSeconds: 600, now: { now })
        timer.start()
        now += 125 // app suspended, no ticks delivered
        timer.refresh()
        #expect(timer.timeRemaining == 475)
        #expect(timer.isRunning)

        timer.pause()
        now += 300 // paused clock does not move
        timer.start()
        timer.refresh()
        #expect(timer.timeRemaining == 475)

        now += 1_000
        timer.refresh()
        #expect(timer.timeRemaining == 0)
        #expect(timer.overtimeSeconds == 525)
        #expect(timer.isRunning) // play continues until the ball is dead
        timer.pause()
    }

    @MainActor @Test func timeUpRunsIntoOvertimeUntilRefereeEndsHalf() async {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 600, sinBinDurationSeconds: 120
        )
        state.startMatch()
        now += 540
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        state.addCard(team: "Home", playerNum: 8, type: .yellow)

        now += 95 // 60s to time up, then 35s of overtime
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.matchPeriod == .firstHalf)
        #expect(state.timerService.isRunning)
        #expect(state.timerService.overtimeSeconds == 35)
        #expect(state.activeCards.first?.remainingSeconds == 25) // sin-bin keeps running in overtime

        state.endPeriod()
        #expect(state.matchPeriod == .halfTime)
        #expect(!state.timerService.isRunning)
        #expect(state.matchEvents.last?.description == "HALF-TIME WHISTLE")
    }

    @MainActor @Test func sinBinsRunWithMatchClockAndExpireAfterGap() async {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400, sinBinDurationSeconds: 120
        )
        state.startMatch()
        state.addCard(team: "Home", playerNum: 8, type: .yellow)

        now += 50
        state.timerService.refresh()
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.activeCards.first?.remainingSeconds == 70)

        now += 200
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.activeCards.first?.isExpired == true)
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

    @MainActor @Test func sinBinsDoNotTickWhileClockIsPaused() async {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400, sinBinDurationSeconds: 120
        )
        state.startMatch()
        state.addCard(team: "Home", playerNum: 8, type: .yellow)
        state.timerService.pause()
        now += 300
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.activeCards.first?.remainingSeconds == 120)
    }

    @MainActor @Test func unfinishedSinBinCarriesOverIntoSecondHalf() async {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 600, sinBinDurationSeconds: 120
        )
        state.startMatch()
        now += 560
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        state.addCard(team: "Away", playerNum: 4, type: .yellow)
        now += 40
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        state.endPeriod()
        #expect(state.activeCards.first?.remainingSeconds == 80)

        state.startSecondHalf()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.activeCards.first?.remainingSeconds == 80, "Resetting the clock must not tick the sin-bin")
        now += 30
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.activeCards.first?.remainingSeconds == 50)
        state.timerService.pause()
    }

    @MainActor @Test func secondHalfOnlyStartsFromHalfTime() {
        let state = AppState()
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400
        )
        state.startSecondHalf()
        #expect(state.matchPeriod == .preMatch)
        state.startMatch()
        state.startSecondHalf()
        #expect(state.matchPeriod == .firstHalf)
        state.timerService.pause()
    }

    @MainActor @Test func startMatchTwiceDoesNotRestartClock() {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 2400
        )
        state.startMatch()
        now += 100
        state.startMatch()
        state.timerService.refresh()
        #expect(state.timerService.timeRemaining == 2300)
        state.timerService.pause()
    }

    @MainActor @Test func timeUpDuringHalfTimeDoesNotChangePeriod() {
        let state = AppState()
        state.matchPeriod = .halfTime
        state.handleTimeUp()
        #expect(state.matchPeriod == .halfTime)
    }

    @MainActor @Test func endingSecondHalfInOvertimeGoesToFullTime() async {
        var now = Date(timeIntervalSince1970: 1_000)
        let state = AppState(timerService: MatchTimerService(initialSeconds: 2400, now: { now }))
        state.connectivityService.receivedConfiguration = MatchConfiguration(
            matchID: UUID(), home: "Home", away: "Away", duration: 300
        )
        state.startMatch()
        state.endPeriod()
        state.startSecondHalf()
        now += 330
        state.timerService.refresh()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(state.matchPeriod == .secondHalf)
        #expect(state.timerService.overtimeSeconds == 30)
        state.endPeriod()
        #expect(state.matchPeriod == .fullTime)
        #expect(state.matchEvents.map(\.description).suffix(2) == ["HALF-TIME WHISTLE", "FULL-TIME WHISTLE"])
    }
}
