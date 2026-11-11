//
//  AppState+WatchSync.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    func receiveConfiguration(_ configuration: MatchConfiguration) {
        // The iPhone resends its last setup with every context update (language, telemetry);
        // one already applied or left on the Watch must not replace a Watch-only match.
        guard configuration.matchID != matchID, configuration.matchID != lastAppliedConfigurationID,
              configuration.matchID != dismissedConfigurationID else { return }
        guard matchPeriod == .preMatch || matchPeriod == .fullTime else {
            // A delayed setup cannot replace a match already started on Watch.
            rejectedConfigurationID = configuration.matchID
            publishWatchSnapshot()
            return
        }
        matchID = configuration.matchID
        lastAppliedConfigurationID = configuration.matchID
        isWatchOnlyMatch = false
        homeTeamName = configuration.home
        awayTeamName = configuration.away
        matchDurationSeconds = configuration.duration
        sinBinDurationSeconds = configuration.sinBinDurationSeconds ?? 600
        maxPlayerNumber = configuration.maxPlayerNumber ?? MatchEvent.playerNumbers.upperBound
        tapLockEnabled = configuration.tapLockEnabled ?? false
        coinTossEnabled = configuration.coinTossEnabled ?? false
        halfTimeBreakSeconds = configuration.halfTimeBreakSeconds ?? 120
        twentyMinuteRedEnabled = configuration.twentyMinuteRedEnabled ?? false
        resetMatchData()
        publishWatchSnapshot()
    }

    public func applyWatchSnapshot(_ snapshot: MatchSnapshot) {
        #if !os(watchOS)
        // In iPhone-only mode the phone owns the match; a stale Watch must not overwrite it.
        guard !isPhoneHosted, snapshot.matchID != dismissedMatchID else { return }
        guard matchID == nil || matchID == snapshot.matchID || snapshot.rejectedConfigurationID == matchID else { return }
        if let lastWatchUpdate, snapshot.updatedAt <= lastWatchUpdate { return }
        lastWatchUpdate = snapshot.updatedAt
        // When the Watch sent it (capped at now, in case its clock runs ahead), so a report
        // delivered late still reads as old.
        let sentAt = min(snapshot.updatedAt, Date())
        lastWatchSyncAt = sentAt
        matchID = snapshot.matchID
        homeTeamName = snapshot.home
        awayTeamName = snapshot.away
        matchDurationSeconds = snapshot.duration
        sinBinDurationSeconds = snapshot.sinBinDurationSeconds ?? 600
        matchPeriod = snapshot.period
        homeScore = snapshot.homeScore
        awayScore = snapshot.awayScore
        activeCards = snapshot.cards
        mirroredCards = snapshot.cards
        mirroredClock = snapshot.remaining
        if let events = snapshot.events { matchEvents = events }
        // Older Watch builds send no end date; the send time plus the reading is within a second.
        let endDate = snapshot.clockEndDate
            ?? sentAt.addingTimeInterval(TimeInterval(snapshot.remaining))
        timerService.displayWatchTime(remaining: snapshot.remaining, isRunning: snapshot.isRunning, endDate: endDate)
        currentScreen = .liveMatch
        #endif
    }

    public func publishWatchSnapshot() {
        #if os(watchOS)
        guard let matchID, !isWatchOnlyMatch else { return }
        connectivityService.sendMatchSnapshot(MatchSnapshot(
            matchID: matchID, home: homeTeamName, away: awayTeamName,
            duration: matchDurationSeconds, period: matchPeriod,
            remaining: timerService.clockSeconds, isRunning: timerService.isRunning,
            homeScore: homeScore, awayScore: awayScore, cards: activeCards,
            rejectedConfigurationID: rejectedConfigurationID,
            sinBinDurationSeconds: sinBinDurationSeconds,
            events: matchEvents,
            clockEndDate: timerService.endDate
        ))
        #endif
    }
}
