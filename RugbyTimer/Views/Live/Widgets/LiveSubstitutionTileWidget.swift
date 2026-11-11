import SwiftUI

/// iPhone-only mode: SUB button that opens the substitution sheet. Hidden when the match
/// doesn't track substitutions (Setup › Substitutions off).
struct LiveSubstitutionTileWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let controls: LiveMatchControls

    @Environment(\.substitutionRules) private var rules
    @State private var isSubstituting = false

    var body: some View {
        if rules.isEnabled {
            LiveControlTileWidget(symbol: "arrow.left.arrow.right", title: "SUBSTITUTION",
                                  tint: Color.pitchEmerald) { isSubstituting = true }
                .accessibilityIdentifier("substitution")
                .sheet(isPresented: $isSubstituting) {
                    LiveSubstitutionSheetWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                                                rules: rules, events: controls.matchEvents,
                                                activeCards: controls.activeCards, onSubstitute: controls.onSubstitute)
                }
        }
    }
}

#Preview {
    LiveSubstitutionTileWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
                               controls: LiveMatchControls(onKickOff: {}, onToggleClock: {}, onEndPeriod: {},
                                                           onStartSecondHalf: {}, onScore: { _, _, _, _ in },
                                                           onCard: { _, _, _ in }))
        .environment(\.substitutionRules, SubstitutionRules(isEnabled: true))
        .padding()
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
