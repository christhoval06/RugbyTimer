import Foundation

extension AppState {
    /// The match as the watch-face complication shows it; idle when no match is set up.
    var complicationSnapshot: ComplicationSnapshot {
        guard hasConfiguredMatch else { return .idle }
        let timer = timerService
        let now = Date()
        let sinBins = activeCards.filter { $0.countsDown && !$0.isExpired }
        let nextSinBin = timer.isRunning ? sinBins.map(\.remainingSeconds).min() : nil
        return ComplicationSnapshot(
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
            homeScore: homeScore,
            awayScore: awayScore,
            periodLabel: String(appLocalized: matchPeriod.complicationLabel),
            pausedLabel: String(appLocalized: "PAUSED"),
            timeUpLabel: String(appLocalized: "TIME UP"),
            clockEndsAt: timer.isRunning ? timer.endDate : nil,
            clockSeconds: timer.clockSeconds,
            periodSeconds: currentPeriodSeconds,
            breakEndsAt: halfTimeBreakEndsAt,
            nextSinBinEndsAt: nextSinBin.map { now.addingTimeInterval(TimeInterval($0)) },
            sinBinCount: sinBins.count,
            isPlaying: matchPeriod.isPlaying,
            isMatchLive: matchPeriod.isPlaying || matchPeriod.isBreak
        )
    }
}

extension MatchPeriod {
    /// A few letters for the watch face: "H1", "HT", "FT".
    var complicationLabel: LocalizedStringResource {
        switch self {
        case .preMatch: "READY"
        case .firstHalf: "H1"
        case .halfTime: "HT"
        case .secondHalf: "H2"
        case .fullTime: "FT"
        case .extraTimeBreak: "ET BREAK"
        case .extraTimeFirstHalf: "ET1"
        case .extraTimeSecondHalf: "ET2"
        case .suddenDeath: "SD"
        }
    }
}
