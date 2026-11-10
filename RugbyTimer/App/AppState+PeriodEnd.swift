//
//  AppState+PeriodEnd.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    /// Time is up (the hooter): play continues into overtime until the referee ends the period.
    public func handleTimeUp() {
        guard matchPeriod == .firstHalf || matchPeriod == .secondHalf else { return }
        HapticService.playTimeUp()
    }

    /// Ends the current half when the referee blows the whistle (after time is up, or early).
    public func endPeriod() {
        handleTimerExpired()
        publishWatchSnapshot()
    }

    public func handleTimerExpired() {
        HapticService.playHalfTime()

        if matchPeriod == .firstHalf {
            matchPeriod = .halfTime
            timerService.pause()
            halfTimeStartedAt = Date()

            let htEvent = MatchEvent(
                minute: matchDurationSeconds / 60,
                teamName: "OFFICIAL",
                type: .sub,
                description: "HALF-TIME WHISTLE",
                overtimeSeconds: timerService.overtimeSeconds
            )
            matchEvents.append(htEvent)

        } else if matchPeriod == .secondHalf {
            matchPeriod = .fullTime
            timerService.pause()
            currentScreen = .liveMatch

            let ftEvent = MatchEvent(
                minute: (matchDurationSeconds * 2) / 60,
                teamName: "OFFICIAL",
                type: .sub,
                description: "FULL-TIME WHISTLE",
                overtimeSeconds: timerService.overtimeSeconds
            )
            matchEvents.append(ftEvent)
        }
    }
}
