import SwiftUI

/// Result page: the scoreboard, players currently in the sin-bin and, at full time,
/// the discipline summary.
struct WatchResultPageWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let homeScore: Int
    let awayScore: Int
    let matchPeriod: MatchPeriod
    let activeCards: [MatchCard]
    let matchEvents: [MatchEvent]

    private var openSinBins: [MatchCard] {
        activeCards.filter { $0.type == .red || !$0.isExpired }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchPageTitleWidget(
                    eyebrow: matchPeriod == .fullTime ? "FINAL" : "LIVE",
                    title: "RESULT",
                    tint: matchPeriod == .fullTime ? .iceTitanium : .pitchEmerald
                )

                WatchScoreboardWidget(
                    homeTeamName: homeTeamName,
                    awayTeamName: awayTeamName,
                    homeScore: homeScore,
                    awayScore: awayScore
                )

                if matchPeriod == .fullTime {
                    WatchDisciplineStatsWidget(
                        homeTeamName: homeTeamName,
                        awayTeamName: awayTeamName,
                        events: matchEvents
                    )
                } else if !openSinBins.isEmpty {
                    WatchSinBinListWidget(cards: openSinBins)
                }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }
}
