import SwiftUI

/// Result page: the scoreboard, players in the sin-bin while playing and, once play stops,
/// the scoring breakdown (with points per half) and, at full time, the discipline summary.
struct WatchResultPageView: View {
    let summary: WatchMatchSummary
    var showsExpandedDetails = false
    var onNewMatch: (() -> Void)? = nil
    var onReturnToClock: (() -> Void)? = nil

    private var isFullTime: Bool { summary.matchPeriod == .fullTime }

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchPageTitleWidget(
                    eyebrow: isFullTime ? "FINAL" : "LIVE",
                    title: "RESULT",
                    tint: isFullTime ? .iceTitanium : .pitchEmerald
                )

                if isFullTime && showsExpandedDetails {
                    WatchFullTimeWidget(summary: summary)
                }

                WatchScoreboardWidget(
                    homeTeamName: summary.homeTeamName,
                    awayTeamName: summary.awayTeamName,
                    homeScore: summary.homeScore,
                    awayScore: summary.awayScore
                )

                if !isFullTime, let onReturnToClock {
                    Button(action: onReturnToClock) {
                        Label("MATCH CLOCK", systemImage: "timer")
                            .font(.system(size: 11, weight: .heavy).width(.condensed))
                            .foregroundStyle(Color.pitchEmerald)
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.armorBorder))
                    }
                    .buttonStyle(.plain)
                }

                if summary.isStopped || showsExpandedDetails {
                    WatchScoringBreakdownWidget(summary: summary)
                }

                if summary.isStopped {
                    WatchPenaltyStatsWidget(summary: summary)
                    if summary.substitutionRules.isEnabled {
                        WatchSubstitutionCountsWidget(homeTeamName: summary.homeTeamName, awayTeamName: summary.awayTeamName,
                                                      rules: summary.substitutionRules, events: summary.matchEvents)
                    }
                }

                if isFullTime {
                    if showsExpandedDetails {
                        WatchTimePastClockWidget(firstHalf: summary.timePastClock.firstHalf,
                                                 secondHalf: summary.timePastClock.secondHalf)
                    }
                    WatchDisciplineStatsWidget(
                        homeTeamName: summary.homeTeamName,
                        awayTeamName: summary.awayTeamName,
                        events: summary.matchEvents
                    )
                    if let onNewMatch {
                        WatchLeaveMatchWidget(kind: .newMatch, onLeave: onNewMatch)
                    }
                } else if !summary.carriedSinBins.isEmpty {
                    WatchSinBinListWidget(cards: summary.carriedSinBins)
                }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }
}

#Preview("Full-time result") {
    WatchResultPageView(summary: .preview)
}
