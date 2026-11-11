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
    var halfTimeBreakEndsAt: Date? = nil
    var halfTimeBreakSeconds = 120
    var twentyMinuteRedEnabled = false
    var injuryTimers: [InjuryTimer] = []
    /// End a sin-bin, fix a number, end an injury timer; nil keeps the lists read-only.
    var offFieldActions: OffFieldActions? = nil
    var onStartInjury: (InjuryKind, String, Int) -> Void = { _, _, _ in }
    let onAddCard: (String, Int, Sanction) -> Void
    let onScore: (String, Int?, Int, String) -> Void
    let onStartSecondHalf: () -> Void
    let onEndPeriod: () -> Void
    var onEndMatch: () -> Void = {}
    var onNewMatch: (() -> Void)? = nil
    var onUndo: () -> Void = {}

    @State private var page: Page = .clock

    private var isPlaying: Bool { matchPeriod == .firstHalf || matchPeriod == .secondHalf }

    private var summary: WatchMatchSummary {
        WatchMatchSummary(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                          homeScore: homeScore, awayScore: awayScore, matchPeriod: matchPeriod,
                          activeCards: activeCards, matchEvents: matchEvents,
                          breakEndsAt: halfTimeBreakEndsAt, breakSeconds: halfTimeBreakSeconds, injuries: injuryTimers)
    }

    var body: some View {
        TabView(selection: $page) {
            if isPlaying {
                WatchSanctionsPageWidget(
                    homeTeamName: homeTeamName,
                    awayTeamName: awayTeamName,
                    activeCards: activeCards,
                    injuries: injuryTimers,
                    matchEvents: matchEvents,
                    twentyMinuteRedEnabled: twentyMinuteRedEnabled,
                    actions: offFieldActions,
                    onStartInjury: { kind, team, number in
                        onStartInjury(kind, team, number)
                        returnToMatch()
                    },
                    onAddCard: { team, number, sanction in
                        onAddCard(team, number, sanction)
                        returnToMatch()
                    }
                )
                .tag(Page.sanctions)
            }

            WatchClockPageWidget(
                timerService: timerService,
                summary: summary,
                totalDuration: totalDuration,
                onStartSecondHalf: onStartSecondHalf,
                onEndPeriod: onEndPeriod,
                onEndMatch: onEndMatch,
                onNewMatch: onNewMatch,
                lastEntry: matchEvents.last,
                offFieldActions: offFieldActions,
                onUndo: onUndo
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

            WatchResultPageWidget(summary: summary)
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
