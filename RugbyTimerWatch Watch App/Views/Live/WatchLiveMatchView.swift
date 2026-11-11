import SwiftUI

struct WatchLiveMatchView: View {
    /// Swipe order while playing: Substitutions ← Sanctions ← Penalties ← Clock → Score → Result (last).
    /// Substitutions also show at the breaks, and only when the match tracks them.
    enum Page: Hashable { case substitutions, sanctions, penalties, clock, score, result }

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
    var nextExtraPeriod: MatchPeriod? = nil
    var onStartExtraPeriod: () -> Void = {}
    var onConcede: (Infringement, String) -> Void = { _, _ in }
    var substitutionRules = SubstitutionRules()
    var onSubstitute: (String, Int, Int) -> Void = { _, _, _ in }

    @State var page: Page = .clock

    var isPlaying: Bool { matchPeriod.isPlaying }

    var body: some View {
        TabView(selection: $page) {
            offFieldPages

            WatchClockPageView(
                timerService: timerService,
                summary: summary,
                totalDuration: totalDuration,
                onStartSecondHalf: onStartSecondHalf,
                onEndPeriod: onEndPeriod,
                onEndMatch: onEndMatch,
                onNewMatch: onNewMatch,
                lastEntry: matchEvents.last,
                offFieldActions: offFieldActions,
                onUndo: onUndo,
                nextExtraPeriod: nextExtraPeriod,
                onStartExtraPeriod: onStartExtraPeriod
            )
            .tag(Page.clock)

            if isPlaying {
                WatchScorePageView(
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

            WatchResultPageView(summary: summary)
                .tag(Page.result)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color.pitchVoid.ignoresSafeArea())
        .onChange(of: matchPeriod) {
            if !isPlaying && (page == .sanctions || page == .penalties || page == .score) { page = .clock }
            if !showsSubstitutions && page == .substitutions { page = .clock }
        }
    }

    func returnToMatch() {
        withAnimation { page = .clock }
    }
}
