import SwiftUI

/// Main live page: the clock while playing; the break or the result once play stops.
struct WatchClockPageWidget: View {
    let timerService: MatchTimerService
    let summary: WatchMatchSummary
    let totalDuration: Int
    let onStartSecondHalf: () -> Void
    let onEndPeriod: () -> Void
    var onEndMatch: () -> Void = {}
    /// Full time only: back to the Watch main screen for the next match.
    var onNewMatch: (() -> Void)? = nil
    /// The latest score or card, offered for undo while its window is open.
    var lastEntry: MatchEvent? = nil
    var offFieldActions: OffFieldActions? = nil
    var onUndo: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                switch summary.matchPeriod {
                case .halfTime:
                    WatchLivePeriodWidget(matchPeriod: summary.matchPeriod)
                    WatchHalfTimeWidget(homeScore: summary.homeScore, awayScore: summary.awayScore,
                                        kickOffTeamName: summary.secondHalfKickOff,
                                        onStartSecondHalf: onStartSecondHalf)
                    if let breakEndsAt = summary.breakEndsAt {
                        WatchBreakCountdownWidget(endsAt: breakEndsAt, totalSeconds: summary.breakSeconds)
                    }
                    // Players still off when the second half kicks off.
                    if !summary.carriedSinBins.isEmpty || !summary.injuries.isEmpty {
                        WatchSinBinListWidget(cards: summary.carriedSinBins, injuries: summary.injuries,
                                              title: "STILL OFF FOR H2", actions: offFieldActions)
                    }
                    WatchEndMatchEarlyWidget(timerService: timerService, matchPeriod: summary.matchPeriod,
                                             onEndMatch: onEndMatch)
                case .fullTime:
                    WatchLivePeriodWidget(matchPeriod: summary.matchPeriod)
                    WatchFullTimeWidget(summary: summary)
                    WatchTimePastClockWidget(firstHalf: summary.timePastClock.firstHalf,
                                             secondHalf: summary.timePastClock.secondHalf)
                    if let onNewMatch {
                        WatchLeaveMatchWidget(kind: .newMatch, onLeave: onNewMatch)
                    }
                default:
                    // The dial carries the period label, like the iPhone clock.
                    WatchLiveClockWidget(timerService: timerService, totalDuration: totalDuration,
                                         matchPeriod: summary.matchPeriod)
                    WatchClockStatsWidget(timerService: timerService, totalDuration: totalDuration)
                    WatchUndoLastWidget(lastEntry: lastEntry, onUndo: onUndo)
                    WatchEndPeriodWidget(
                        timerService: timerService,
                        matchPeriod: summary.matchPeriod,
                        onEndPeriod: onEndPeriod
                    )
                    WatchEndMatchEarlyWidget(timerService: timerService, matchPeriod: summary.matchPeriod,
                                             onEndMatch: onEndMatch)
                }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }
}
