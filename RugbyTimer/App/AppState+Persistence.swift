//
//  AppState+Persistence.swift
//  RugbyTimer
//

import Foundation
import Combine

/// Crash recovery: the device running the clock saves the match after every change and
/// picks it back up on the next launch, clock and sin-bins included.
extension AppState {
    /// The app's state at launch: the saved match, if there is one, with autosave turned on.
    public static func launch(persistence: MatchPersistence = MatchPersistence()) -> AppState {
        let state = AppState()
        if let saved = persistence.load() { state.restore(saved) }
        state.startAutosave(to: persistence)
        return state
    }

    func startAutosave(to persistence: MatchPersistence) {
        objectWillChange.map { _ in () }
            .merge(with: timerService.$isRunning.map { _ in () })
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] in self?.saveMatch(to: persistence) }
            .store(in: &subscriptions)
    }

    /// Writes the match now; also called when the app leaves the foreground.
    public func saveMatch(to persistence: MatchPersistence = MatchPersistence()) {
        guard let savedMatch else { persistence.clear(); return }
        persistence.save(savedMatch)
    }

    /// Nil when there is nothing to keep: no match, or the iPhone only mirrors the Watch.
    var savedMatch: SavedMatch? {
        guard let matchID, runsClockLocally else { return nil }
        return SavedMatch(
            matchID: matchID, isWatchOnlyMatch: isWatchOnlyMatch, isPhoneHosted: isPhoneHosted,
            lastAppliedConfigurationID: lastAppliedConfigurationID,
            home: homeTeamName, away: awayTeamName, halfSeconds: matchDurationSeconds,
            sinBinSeconds: sinBinDurationSeconds, maxPlayerNumber: maxPlayerNumber,
            tapLockEnabled: tapLockEnabled, coinTossEnabled: coinTossEnabled,
            halfTimeBreakSeconds: halfTimeBreakSeconds, twentyMinuteRedEnabled: twentyMinuteRedEnabled,
            extraTimeFormat: extraTimeFormat, halfTimeStartedAt: halfTimeStartedAt,
            coinToss: coinToss, period: matchPeriod, homeScore: homeScore, awayScore: awayScore,
            cards: activeCards, injuries: injuryTimers, cardsClock: lastClockReading, events: matchEvents,
            clockSeconds: timerService.clockSeconds, clockEndDate: timerService.endDate
        )
    }

    func restore(_ saved: SavedMatch) {
        matchID = saved.matchID
        isWatchOnlyMatch = saved.isWatchOnlyMatch
        isPhoneHosted = saved.isPhoneHosted
        lastAppliedConfigurationID = saved.lastAppliedConfigurationID
        homeTeamName = saved.home
        awayTeamName = saved.away
        matchDurationSeconds = saved.halfSeconds
        sinBinDurationSeconds = saved.sinBinSeconds
        maxPlayerNumber = saved.maxPlayerNumber
        tapLockEnabled = saved.tapLockEnabled
        coinTossEnabled = saved.coinTossEnabled
        halfTimeBreakSeconds = saved.halfTimeBreakSeconds
        twentyMinuteRedEnabled = saved.twentyMinuteRedEnabled ?? false
        extraTimeFormat = saved.extraTimeFormat ?? .off
        halfTimeStartedAt = saved.halfTimeStartedAt
        coinToss = saved.coinToss
        matchPeriod = saved.period
        homeScore = saved.homeScore
        awayScore = saved.awayScore
        matchEvents = saved.events
        injuryTimers = saved.injuries ?? []
        // Sin-bins catch up from the reading they were saved at as the restored clock ticks in.
        activeCards = saved.cards
        lastClockReading = saved.cardsClock
        timerService.restore(clock: saved.clockSeconds, endDate: saved.clockEndDate)
        if isPhoneHosted { currentScreen = .liveMatch }
        publishWatchSnapshot()
    }
}
