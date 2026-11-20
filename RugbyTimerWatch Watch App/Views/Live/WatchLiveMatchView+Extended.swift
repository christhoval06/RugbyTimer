import SwiftUI

extension WatchLiveMatchView {
    var extendedMatchPages: [Page] {
        Page.extended(isPlaying: isPlaying, showsDiscipline: showsDiscipline, showsSubstitutions: showsSubstitutions)
    }

    var extendedPages: some View {
        TabView(selection: $page) {
            ForEach(extendedMatchPages, id: \.self) { matchPage in
                Group {
                    if case let .team(side, action) = matchPage {
                        teamPage(side: side, action: action)
                    } else {
                        centerPages
                    }
                }
                .tag(matchPage)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: extendedMatchPages.count > 1 ? .always : .never))
    }

    private var centerPages: some View {
        WatchCenterPagesWidget(
            selection: $centerPage,
            clock: clockPage(
                showsOffFieldPlayers: false,
                tools: matchPeriod.isBreak ? matchTools(includeSubstitutions: true) : nil,
                includesDetails: false
            ),
            details: matchPeriod == .extraTimeBreak ? nil : WatchClockDetailsWidget(
                timerService: timerService, totalDuration: totalDuration, matchPeriod: matchPeriod,
                onEndMatch: onEndMatch
            ),
            activeTimers: WatchActiveTimersWidget(summary: summary, actions: offFieldActions),
            result: WatchResultPageView(
                summary: summary, showsExpandedDetails: true, onNewMatch: onNewMatch,
                onReturnToClock: { returnToMatch() }
            ),
            isFullTime: matchPeriod == .fullTime
        )
    }

    private func teamPage(side: Page.Side, action: Page.Action) -> some View {
        let isHome = side == .home
        let name = isHome ? homeTeamName : awayTeamName
        let tint: Color = isHome ? .pitchEmerald : .sinBinAmber
        return WatchTeamMatchPageWidget(name: name, score: isHome ? homeScore : awayScore, tint: tint) {
            switch action {
            case .score:
                WatchPageTitleWidget(eyebrow: "POINTS", title: "SCORE", tint: tint)
                scorePage(for: name)
            case .penalties:
                WatchPageTitleWidget(eyebrow: "CONCEDED BY", title: "PENALTIES", tint: .sinBinAmber)
                penaltiesPage(for: name)
            case .sanctions:
                WatchPageTitleWidget(eyebrow: "DISCIPLINE", title: "SANCTIONS", tint: .cardYellow)
                sanctionsPage(for: name)
            case .substitutions:
                substitutionsPage(for: name)
            case .injuries:
                WatchPageTitleWidget(eyebrow: "OFF THE FIELD", title: "INJURY", tint: .sinBinAmber)
                sanctionsPage(for: name, showsCards: false)
            }
        }
    }
}

#Preview("Extended") {
    let defaults = UserDefaults(suiteName: "watchLayoutPreview")!
    defaults.set(true, forKey: WatchDisplayPreferences.extendedLayoutKey)
    return WatchLiveMatchView(
        timerService: MatchTimerService(initialSeconds: 2180),
        activeCards: [MatchCard(teamName: "City Lions", playerNumber: 8, type: .yellow, durationSeconds: 412)],
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        matchPeriod: .firstHalf, totalDuration: 2400, homeScore: 12, awayScore: 7,
        injuryTimers: [InjuryTimer(teamName: "Rangers RFC", playerNumber: 7, kind: .hia)],
        onAddCard: { _, _, _ in }, onScore: { _, _, _, _ in }, onStartSecondHalf: {}, onEndPeriod: {},
        substitutionRules: SubstitutionRules(isEnabled: true)
    )
    .defaultAppStorage(defaults)
}
