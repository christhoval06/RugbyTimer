//
//  AppState+ExtraTime.swift
//  RugbyTimer
//

import Foundation

/// Extra time: when a knockout match is level at full time, the match goes to an extra-time
/// break instead of ending. The referee kicks off each period from there, or ends the match
/// as a draw (for a kicking competition, say).
extension AppState {
    /// Length of the period on the clock: a half, or an extra-time period.
    public var currentPeriodSeconds: Int {
        matchPeriod.isExtraTime ? extraTimeFormat.periodSeconds : matchDurationSeconds
    }

    /// Match seconds when the current period kicked off; each period continues from the last.
    var periodOffsetSeconds: Int {
        let half = matchDurationSeconds
        let extra = extraTimeFormat.periodSeconds
        switch matchPeriod {
        case .secondHalf: return half
        case .extraTimeFirstHalf: return 2 * half
        case .extraTimeSecondHalf: return 2 * half + extra
        case .suddenDeath:
            let halves = extraTimeFormat == .twoHalves ? 2 : 0
            let periodsPlayed = matchEvents.filter { $0.description == ExtraTimeWhistle.suddenDeath }.count
            return 2 * half + (halves + periodsPlayed) * extra
        default: return 0
        }
    }

    /// The period the next kick-off starts, read from the last whistle. Nil outside the extra-time break.
    public var nextExtraPeriod: MatchPeriod? {
        guard matchPeriod == .extraTimeBreak else { return nil }
        let whistles = [Self.fullTimeWhistle, ExtraTimeWhistle.halfTime, ExtraTimeWhistle.fullTime, ExtraTimeWhistle.suddenDeath]
        switch matchEvents.last(where: { $0.type == .sub && whistles.contains($0.description) })?.description {
        case Self.fullTimeWhistle?: return extraTimeFormat == .twoHalves ? .extraTimeFirstHalf : .suddenDeath
        case ExtraTimeWhistle.halfTime?: return .extraTimeSecondHalf
        default: return .suddenDeath
        }
    }

    /// Kicks off the next extra-time period.
    public func startExtraPeriod() {
        guard runsClockLocally, let next = nextExtraPeriod else { return }
        HapticService.playHalfTime()
        matchPeriod = next
        timerService.reset(to: extraTimeFormat.periodSeconds)
        timerService.start()
        publishWatchSnapshot()
    }

    /// Where a deciding whistle leads: more extra time while the scores are level, otherwise full time.
    var periodAfterDecidingWhistle: MatchPeriod {
        extraTimeFormat != .off && homeScore == awayScore ? .extraTimeBreak : .fullTime
    }

    /// Sudden death: the first score wins, so the final whistle is offered straight away.
    public var hasSuddenDeathWinner: Bool { matchPeriod == .suddenDeath && homeScore != awayScore }

    static let fullTimeWhistle = "FULL-TIME WHISTLE" // l10n-ignore: synced English
}
