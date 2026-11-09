import SwiftUI

struct WatchLiveMatchWidget: View {
    /// Swipe order while playing: Sanctions ← Clock → Score → Result (last).
    enum Page: Hashable { case sanctions, clock, score, result }

    let timerService: MatchTimerService
    let activeCards: [MatchCard]
    let homeTeamName: String
    let awayTeamName: String
    let matchPeriod: MatchPeriod
    let totalDuration: Int
    let homeScore: Int
    let awayScore: Int
    var matchEvents: [MatchEvent] = []
    let onAddCard: (String, Int, CardType) -> Void
    let onScore: (String, Int?, Int, String) -> Void
    let onStartSecondHalf: () -> Void
    let onEndPeriod: () -> Void

    @State private var page: Page = .clock

    private var isPlaying: Bool { matchPeriod == .firstHalf || matchPeriod == .secondHalf }

    var body: some View {
        TabView(selection: $page) {
            if isPlaying {
                WatchSanctionsPageWidget(
                    homeTeamName: homeTeamName,
                    awayTeamName: awayTeamName,
                    activeCards: activeCards,
                    onAddCard: { team, number, type in
                        onAddCard(team, number, type)
                        returnToMatch()
                    }
                )
                .tag(Page.sanctions)
            }

            WatchClockPageWidget(
                timerService: timerService,
                matchPeriod: matchPeriod,
                totalDuration: totalDuration,
                onStartSecondHalf: onStartSecondHalf,
                onEndPeriod: onEndPeriod
            )
            .tag(Page.clock)

            if isPlaying {
                WatchScorePageWidget(
                    homeTeamName: homeTeamName,
                    awayTeamName: awayTeamName,
                    homeScore: homeScore,
                    awayScore: awayScore,
                    onScore: { team, player, points, description in
                        onScore(team, player, points, description)
                        returnToMatch()
                    }
                )
                .tag(Page.score)
            }

            WatchResultPageWidget(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                homeScore: homeScore,
                awayScore: awayScore,
                matchPeriod: matchPeriod,
                activeCards: activeCards,
                matchEvents: matchEvents
            )
            .tag(Page.result)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color.pitchVoid.ignoresSafeArea())
        .onChange(of: isPlaying) { _, playing in
            if !playing && (page == .sanctions || page == .score) { page = .clock }
        }
    }

    private func returnToMatch() {
        withAnimation { page = .clock }
    }
}

#Preview("First half") {
    WatchLiveMatchWidget(
        timerService: MatchTimerService(initialSeconds: 2345),
        activeCards: [
            MatchCard(teamName: "Rangers RFC", playerNumber: 8, type: .yellow, durationSeconds: 412),
            MatchCard(teamName: "City Lions", playerNumber: 13, type: .red)
        ],
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        matchPeriod: .firstHalf, totalDuration: 2400,
        homeScore: 12, awayScore: 7,
        onAddCard: { _, _, _ in }, onScore: { _, _, _, _ in }, onStartSecondHalf: {}, onEndPeriod: {}
    )
}

#Preview("Time up") {
    let timer = MatchTimerService(initialSeconds: -37)
    WatchLiveMatchWidget(
        timerService: timer,
        activeCards: [],
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        matchPeriod: .firstHalf, totalDuration: 2400,
        homeScore: 12, awayScore: 7,
        onAddCard: { _, _, _ in }, onScore: { _, _, _, _ in }, onStartSecondHalf: {}, onEndPeriod: {}
    )
}

#Preview("Half-time") {
    WatchLiveMatchWidget(
        timerService: MatchTimerService(initialSeconds: 0),
        activeCards: [],
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        matchPeriod: .halfTime, totalDuration: 2400,
        homeScore: 12, awayScore: 7,
        onAddCard: { _, _, _ in }, onScore: { _, _, _, _ in }, onStartSecondHalf: {}, onEndPeriod: {}
    )
}

#Preview("Full time") {
    WatchLiveMatchWidget(
        timerService: MatchTimerService(initialSeconds: 0),
        activeCards: [],
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        matchPeriod: .fullTime, totalDuration: 2400,
        homeScore: 12, awayScore: 7,
        matchEvents: [
            MatchEvent(minute: 28, teamName: "City Lions", playerNumber: 8, type: .yellowCard, description: "Yellow Card (Sin-Bin) - #8"),
            MatchEvent(minute: 55, teamName: "Rangers RFC", playerNumber: 4, type: .yellowCard, description: "Yellow Card (Sin-Bin) - #4"),
            MatchEvent(minute: 71, teamName: "City Lions", playerNumber: 13, type: .redCard, description: "Red Card (Expulsion) - #13")
        ],
        onAddCard: { _, _, _ in }, onScore: { _, _, _, _ in }, onStartSecondHalf: {}, onEndPeriod: {}
    )
}
