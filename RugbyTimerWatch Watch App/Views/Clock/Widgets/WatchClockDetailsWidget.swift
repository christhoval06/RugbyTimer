import SwiftUI

struct WatchClockDetailsWidget: View {
    let timerService: MatchTimerService
    let totalDuration: Int
    let matchPeriod: MatchPeriod
    let onEndMatch: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchPageTitleWidget(eyebrow: "MATCH CLOCK", title: "TIME DETAILS", tint: .pitchEmerald)
                WatchClockStatsWidget(timerService: timerService, totalDuration: totalDuration)
                if matchPeriod.isPlaying || matchPeriod == .halfTime {
                    WatchEndMatchEarlyWidget(timerService: timerService, matchPeriod: matchPeriod, onEndMatch: onEndMatch)
                }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }
}

#Preview {
    WatchClockDetailsWidget(timerService: MatchTimerService(initialSeconds: 1850), totalDuration: 2400,
                            matchPeriod: .firstHalf, onEndMatch: {})
}
