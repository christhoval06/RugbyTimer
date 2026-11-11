import ActivityKit
import SwiftUI
import WidgetKit

/// Lock Screen banner: period and clock, both teams' scores, the period's progress and sin-bins.
struct MatchActivityLockScreenView: View {
    let context: ActivityViewContext<MatchActivityAttributes>

    var body: some View {
        let glance = context.glance
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(context.statusLabel)
                    .font(.system(size: 13, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(context.tint)
                    .lineLimit(1)
                if glance.showsClock {
                    context.clockText
                        .font(.system(size: 30, weight: .black).width(.condensed))
                        .monospacedDigit()
                        .foregroundStyle(glance.zone(at: context.displayDate) == .timeUp ? Color.expulsionRed : Color.iceTitanium)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            HStack(alignment: .bottom) {
                MatchActivityTeamScore(name: glance.homeTeamName, score: glance.homeScore, alignment: .leading)
                Text(verbatim: "–")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(Color.outline)
                MatchActivityTeamScore(name: glance.awayTeamName, score: glance.awayScore, alignment: .trailing)
            }
            MatchActivityProgressBar(context: context)
            MatchActivitySinBinRow(glance: glance, date: context.displayDate)
        }
        .padding(16)
        .activityBackgroundTint(Color.pitchVoid)
        .activitySystemActionForegroundColor(Color.iceTitanium)
    }
}

#Preview("Lock Screen", as: .content, using: MatchActivityAttributes(matchID: UUID())) {
    MatchActivityWidget()
} contentStates: {
    MatchGlance.samples()[0]
    MatchGlance.samples()[1]
    MatchGlance.samples()[2]
    MatchGlance.samples()[3]
}
