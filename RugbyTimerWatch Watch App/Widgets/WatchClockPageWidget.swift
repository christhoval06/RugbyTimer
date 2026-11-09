import SwiftUI

/// Main live page: only the clock, with elapsed and remaining time.
struct WatchClockPageWidget: View {
    let timerService: MatchTimerService
    let matchPeriod: MatchPeriod
    let totalDuration: Int
    let onStartSecondHalf: () -> Void
    let onEndPeriod: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                switch matchPeriod {
                case .halfTime:
                    WatchLivePeriodWidget(matchPeriod: matchPeriod)
                    WatchHalfTimeWidget(onStartSecondHalf: onStartSecondHalf)
                case .fullTime:
                    WatchLivePeriodWidget(matchPeriod: matchPeriod)
                    WatchFullTimeWidget()
                default:
                    // The dial carries the period label, like the iPhone clock.
                    WatchLiveClockWidget(timerService: timerService, totalDuration: totalDuration,
                                         matchPeriod: matchPeriod)
                    WatchClockStatsWidget(timerService: timerService, totalDuration: totalDuration)
                    WatchEndPeriodWidget(
                        timerService: timerService,
                        matchPeriod: matchPeriod,
                        onEndPeriod: onEndPeriod
                    )
                }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }
}
