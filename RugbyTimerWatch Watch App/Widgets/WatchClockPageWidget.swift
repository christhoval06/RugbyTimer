import SwiftUI

/// Main live page: the clock while playing; the break or the result once play stops.
struct WatchClockPageWidget: View {
    let timerService: MatchTimerService
    let summary: WatchMatchSummary
    let totalDuration: Int
    let onStartSecondHalf: () -> Void
    let onEndPeriod: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                switch summary.matchPeriod {
                case .halfTime:
                    WatchLivePeriodWidget(matchPeriod: summary.matchPeriod)
                    WatchHalfTimeWidget(homeScore: summary.homeScore, awayScore: summary.awayScore,
                                        kickOffTeamName: summary.secondHalfKickOff,
                                        onStartSecondHalf: onStartSecondHalf)
                    // Players still off when the second half kicks off.
                    if !summary.carriedSinBins.isEmpty {
                        WatchSinBinListWidget(cards: summary.carriedSinBins, title: "STILL OFF FOR H2")
                    }
                case .fullTime:
                    WatchLivePeriodWidget(matchPeriod: summary.matchPeriod)
                    WatchFullTimeWidget(summary: summary)
                default:
                    // The dial carries the period label, like the iPhone clock.
                    WatchLiveClockWidget(timerService: timerService, totalDuration: totalDuration,
                                         matchPeriod: summary.matchPeriod)
                    WatchClockStatsWidget(timerService: timerService, totalDuration: totalDuration)
                    WatchEndPeriodWidget(
                        timerService: timerService,
                        matchPeriod: summary.matchPeriod,
                        onEndPeriod: onEndPeriod
                    )
                }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }
}
