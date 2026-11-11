import ActivityKit
import SwiftUI
import WidgetKit

/// Expanded Dynamic Island, bottom row: the big clock, the period's progress and sin-bins.
struct MatchActivityIslandBottomView: View {
    let context: ActivityViewContext<MatchActivityAttributes>

    var body: some View {
        VStack(spacing: 6) {
            if context.glance.showsClock {
                context.clockText
                    .font(.system(size: 34, weight: .black).width(.condensed))
                    .monospacedDigit()
                    .foregroundStyle(context.tint)
                    .multilineTextAlignment(.center)
            }
            MatchActivityProgressBar(context: context)
            MatchActivitySinBinRow(glance: context.glance, date: context.displayDate)
        }
    }
}

#Preview("Dynamic Island expanded", as: .dynamicIsland(.expanded), using: MatchActivityAttributes(matchID: UUID())) {
    MatchActivityWidget()
} contentStates: {
    MatchGlance.samples()[2]
}
