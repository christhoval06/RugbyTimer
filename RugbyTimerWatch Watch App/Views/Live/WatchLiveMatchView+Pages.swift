import SwiftUI

extension WatchLiveMatchView {
    var showsSubstitutions: Bool {
        substitutionRules.isEnabled && (isPlaying || matchPeriod.isBreak)
    }

    var compactPages: some View {
        TabView(selection: $page) {
            if showsSubstitutions {
                substitutionsPage().tag(Page.substitutions)
            }
            if isPlaying && showsDiscipline {
                sanctionsPage().tag(Page.sanctions)
                penaltiesPage().tag(Page.penalties)
            }
            clockPage(
                showsOffFieldPlayers: !showsDiscipline,
                tools: !showsDiscipline && isPlaying ? matchTools(includeSubstitutions: false) : nil
            )
            .tag(Page.clock)
            if isPlaying {
                scorePage().tag(Page.score)
            }
            WatchResultPageView(summary: summary).tag(Page.result)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }

    func clockPage(
        showsOffFieldPlayers: Bool, tools: WatchMatchToolsWidget?, includesDetails: Bool = true
    ) -> WatchClockPageView {
        WatchClockPageView(
            timerService: timerService, summary: summary, totalDuration: totalDuration,
            onStartSecondHalf: onStartSecondHalf, onEndPeriod: onEndPeriod, onEndMatch: onEndMatch,
            onNewMatch: onNewMatch, lastEntry: matchEvents.last, offFieldActions: offFieldActions,
            onUndo: onUndo, nextExtraPeriod: nextExtraPeriod, onStartExtraPeriod: onStartExtraPeriod,
            showsOffFieldPlayers: showsOffFieldPlayers, tools: tools, includesDetails: includesDetails
        )
    }

    func scorePage(for team: String? = nil) -> WatchScorePageView {
        WatchScorePageView(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                           homeScore: homeScore, awayScore: awayScore, fixedTeam: team) { team, player, points, description in
            onScore(team, player, points, description)
            returnToMatch()
        }
    }

    func penaltiesPage(for team: String? = nil) -> WatchPenaltiesPageView {
        WatchPenaltiesPageView(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                               events: matchEvents, fixedTeam: team) { kind, team in
            onConcede(kind, team)
            returnToMatch()
        }
    }

    func sanctionsPage(for team: String? = nil, showsCards: Bool = true) -> WatchSanctionsPageView {
        let showsInjuries = team == nil || !showsCards
        return WatchSanctionsPageView(
            homeTeamName: homeTeamName, awayTeamName: awayTeamName,
            activeCards: showsCards ? activeCards.filter { team == nil || $0.teamName == team } : [],
            injuries: showsInjuries ? injuryTimers.filter { team == nil || $0.teamName == team } : [],
            matchEvents: matchEvents,
            twentyMinuteRedEnabled: twentyMinuteRedEnabled, actions: offFieldActions, fixedTeam: team,
            showsCards: showsCards, dismissesAfterInjury: !showsCards && team == nil,
            onStartInjury: { kind, team, number in
                onStartInjury(kind, team, number)
                returnToMatch()
            },
            onAddCard: { team, number, sanction in
                onAddCard(team, number, sanction)
                returnToMatch()
            }
        )
    }

    func substitutionsPage(
        for team: String? = nil, dismissesAfterSubstitution: Bool = false
    ) -> WatchSubstitutionsPageView {
        WatchSubstitutionsPageView(
            homeTeamName: homeTeamName, awayTeamName: awayTeamName, rules: substitutionRules,
            matchEvents: matchEvents, activeCards: activeCards, fixedTeam: team,
            dismissesAfterSubstitution: dismissesAfterSubstitution
        ) { team, off, on in
            onSubstitute(team, off, on)
            returnToMatch()
        }
    }

    func matchTools(includeSubstitutions: Bool) -> WatchMatchToolsWidget? {
        let substitutions = includeSubstitutions && showsSubstitutions ? substitutionsPage(dismissesAfterSubstitution: true) : nil
        let injuries = isPlaying ? sanctionsPage(showsCards: false) : nil
        guard substitutions != nil || injuries != nil else { return nil }
        return WatchMatchToolsWidget(substitutions: substitutions, injuries: injuries)
    }
}
