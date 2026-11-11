//
//  AppState+PeriodEnd.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    /// Time is up (the hooter): play continues into overtime until the referee ends the period.
    public func handleTimeUp() {
        guard matchPeriod.isPlaying else { return }
        HapticService.playTimeUp()
    }

    /// Ends the current period when the referee blows the whistle (after time is up, or early).
    public func endPeriod() {
        handleTimerExpired()
        publishWatchSnapshot()
    }

    public func handleTimerExpired() {
        guard matchPeriod.isPlaying else { return }
        HapticService.playHalfTime()
        timerService.pause()
        logWhistle(Self.whistle(endingPeriod: matchPeriod))

        switch matchPeriod {
        case .firstHalf:
            matchPeriod = .halfTime
            halfTimeStartedAt = Date()
        case .extraTimeFirstHalf:
            matchPeriod = .extraTimeBreak
        default:
            // Full time, or more extra time if the match is level and extra time is on.
            matchPeriod = periodAfterDecidingWhistle
            currentScreen = .liveMatch
        }
    }

    /// The whistle that ends each period, as recorded in the match record (synced English).
    static func whistle(endingPeriod period: MatchPeriod) -> String {
        switch period {
        case .firstHalf: MatchStats.halfTimeWhistle
        case .extraTimeFirstHalf: ExtraTimeWhistle.halfTime
        case .extraTimeSecondHalf: ExtraTimeWhistle.fullTime
        case .suddenDeath: ExtraTimeWhistle.suddenDeath
        default: fullTimeWhistle
        }
    }

    /// Logs a whistle at the scheduled end of the period, with how long play ran past the clock.
    private func logWhistle(_ description: String) {
        matchEvents.append(MatchEvent(
            minute: (periodOffsetSeconds + currentPeriodSeconds) / 60,
            teamName: "OFFICIAL",
            type: .sub,
            description: description,
            overtimeSeconds: timerService.overtimeSeconds
        ))
    }
}
