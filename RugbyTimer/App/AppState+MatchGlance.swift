import Foundation

extension AppState {
    /// The match as the Watch complication and the iPhone Live Activity show it; idle when no match is set up.
    var matchGlance: MatchGlance {
        guard hasConfiguredMatch else { return .idle }
        let timer = timerService
        let now = Date()
        let sinBins = activeCards.filter { $0.countsDown && !$0.isExpired }
        let nextSinBin = timer.isRunning ? sinBins.map(\.remainingSeconds).min() : nil
        return MatchGlance(
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
            homeScore: homeScore,
            awayScore: awayScore,
            periodLabel: String(appLocalized: matchPeriod.glanceLabel),
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
    /// A few letters for the watch face and the Lock Screen: "H1", "HT", "FT".
    var glanceLabel: LocalizedStringResource {
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
