//
//  AppState+MatchFlow.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    /// Sets up a new match. `onPhone: false` sends it to the Watch, which then runs the match;
    /// `onPhone: true` runs it on this iPhone (iPhone-only mode, for referees without a Watch).
    public func prepareMatch(onPhone: Bool = false) {
        guard matchPeriod == .preMatch || matchPeriod == .fullTime else { return }
        let id = UUID()
        matchID = id
        isPhoneHosted = onPhone
        resetMatchData()
        if onPhone {
            currentScreen = .liveMatch
            return
        }
        connectivityService.sendMatchConfig(MatchConfiguration(
            matchID: id, home: homeTeamName, away: awayTeamName, duration: matchDurationSeconds,
            sinBinDurationSeconds: sinBinDurationSeconds, maxPlayerNumber: maxPlayerNumber,
            tapLockEnabled: tapLockEnabled, coinTossEnabled: coinTossEnabled,
            halfTimeBreakSeconds: halfTimeBreakSeconds, twentyMinuteRedEnabled: twentyMinuteRedEnabled
        ))
        currentScreen = .liveMatch
    }

    public var matchDurationText: String {
        let totalSeconds = matchDurationSeconds * 2
        return String(format: "%d:%02d Total", totalSeconds / 60, totalSeconds % 60) // l10n-ignore: unused
    }

    // Keep the new setup and match identity while discarding the previous match.
    func resetMatchData() {
        lastWatchUpdate = nil
        lastWatchSyncAt = nil
        rejectedConfigurationID = nil
        matchPeriod = .preMatch
        homeScore = 0
        awayScore = 0
        activeCards = []
        mirroredCards = []
        coinToss = nil
        halfTimeStartedAt = nil
        matchEvents = []
        timerService.reset(to: matchDurationSeconds)
    }

    public func startMatch() {
        guard runsClockLocally, matchPeriod == .preMatch, hasConfiguredMatch, !needsCoinToss else { return }
        HapticService.playHalfTime()
        matchPeriod = .firstHalf
        timerService.reset(to: matchDurationSeconds)
        timerService.start()
        currentScreen = .liveMatch
        publishWatchSnapshot()
    }

    /// Pauses or resumes the match clock (iPhone-only mode; the Watch has its own control).
    public func toggleClock() {
        guard runsClockLocally, matchPeriod == .firstHalf || matchPeriod == .secondHalf else { return }
        HapticService.playStartStop()
        if timerService.isRunning { timerService.pause() } else { timerService.start() }
        publishWatchSnapshot()
    }

    public func startSecondHalf() {
        guard runsClockLocally, matchPeriod == .halfTime else { return }
        HapticService.playHalfTime()
        matchPeriod = .secondHalf
        halfTimeStartedAt = nil
        timerService.reset(to: matchDurationSeconds)
        timerService.start()
        publishWatchSnapshot()
    }

    /// Ends the match on the spot, before time is up (e.g. abandoned for weather, injury or the pitch).
    /// The current score becomes the final result.
    public func endMatch() {
        if matchPeriod == .firstHalf || matchPeriod == .halfTime || matchPeriod == .secondHalf {
            HapticService.playHalfTime()
            matchEvents.append(MatchEvent(
                minute: secondsPlayed / 60, teamName: "OFFICIAL", type: .sub,
                description: MatchEvent.matchEndedEarly,
                overtimeSeconds: matchPeriod == .halfTime ? 0 : timerService.overtimeSeconds,
                matchSeconds: secondsPlayed
            ))
        }
        timerService.pause()
        matchPeriod = .fullTime
        halfTimeStartedAt = nil
        currentScreen = .liveMatch
        publishWatchSnapshot()
    }

    /// Match seconds played so far, counting both halves and any time past the clock.
    private var secondsPlayed: Int {
        let half = matchDurationSeconds
        let elapsedInHalf = max(0, half - timerService.clockSeconds)
        switch matchPeriod {
        case .firstHalf: return elapsedInHalf
        case .secondHalf: return half + elapsedInHalf
        default: return half
        }
    }
}
