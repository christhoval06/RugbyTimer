import SwiftUI

/// The pages left of the clock: Substitutions, Sanctions and Penalties.
extension WatchLiveMatchView {
    /// The match tracks substitutions, and they can be made now (in play or at a break).
    var showsSubstitutions: Bool {
        substitutionRules.isEnabled && (isPlaying || matchPeriod.isBreak)
    }

    @ViewBuilder var offFieldPages: some View {
        if showsSubstitutions {
            WatchSubstitutionsPageView(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                rules: substitutionRules,
                matchEvents: matchEvents,
                activeCards: activeCards,
                onSubstitute: { team, off, on in
                    onSubstitute(team, off, on)
                    returnToMatch()
                }
            )
            .tag(Page.substitutions)
        }

        if isPlaying {
            WatchSanctionsPageView(
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

            WatchPenaltiesPageView(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                events: matchEvents,
                onConcede: { kind, team in
                    onConcede(kind, team)
                    returnToMatch()
                }
            )
            .tag(Page.penalties)
        }
    }
}
