import SwiftUI

/// Result page: the scoreboard, players in the sin-bin while playing and, once play stops,
/// the scoring breakdown (with points per half) and, at full time, the discipline summary.
struct WatchResultPageWidget: View {
    let summary: WatchMatchSummary

    private var isFullTime: Bool { summary.matchPeriod == .fullTime }

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchPageTitleWidget(
                    eyebrow: isFullTime ? "FINAL" : "LIVE",
                    title: "RESULT",
                    tint: isFullTime ? .iceTitanium : .pitchEmerald
                )

                WatchScoreboardWidget(
                    homeTeamName: summary.homeTeamName,
                    awayTeamName: summary.awayTeamName,
                    homeScore: summary.homeScore,
                    awayScore: summary.awayScore
                )

                if summary.isStopped {
                    WatchScoringBreakdownWidget(summary: summary)
                }

                if isFullTime {
                    WatchDisciplineStatsWidget(
                        homeTeamName: summary.homeTeamName,
                        awayTeamName: summary.awayTeamName,
                        events: summary.matchEvents
                    )
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
    WatchResultPageWidget(summary: .preview)
}
