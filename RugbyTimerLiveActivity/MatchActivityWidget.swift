import ActivityKit
import SwiftUI
import WidgetKit

/// The match on the Lock Screen and in the Dynamic Island.
struct MatchActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MatchActivityAttributes.self) { context in
            MatchActivityLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    MatchActivityTeamScore(name: context.glance.homeCode, score: context.glance.homeScore, alignment: .leading)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    MatchActivityTeamScore(name: context.glance.awayCode, score: context.glance.awayScore, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.statusLabel)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(context.tint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    MatchActivityIslandBottomView(context: context)
                }
            } compactLeading: {
                Text(verbatim: context.glance.score)
                    .font(.system(size: 15, weight: .heavy).width(.condensed))
                    .monospacedDigit()
            } compactTrailing: {
                compactClock(context)
                    .frame(maxWidth: 52, alignment: .trailing)
            } minimal: {
                compactClock(context)
                    .font(.system(size: 12, weight: .heavy).width(.condensed))
            }
            .keylineTint(context.tint)
        }
    }

    private func compactClock(_ context: ActivityViewContext<MatchActivityAttributes>) -> some View {
        (context.glance.showsClock ? context.clockText : Text(verbatim: context.glance.periodLabel))
            .font(.system(size: 15, weight: .heavy).width(.condensed))
            .monospacedDigit()
            .multilineTextAlignment(.trailing)
            .foregroundStyle(context.tint)
    }
}

#Preview("Dynamic Island compact", as: .dynamicIsland(.compact), using: MatchActivityAttributes(matchID: UUID())) {
    MatchActivityWidget()
} contentStates: {
    MatchGlance.samples()[0]
    MatchGlance.samples()[2]
}

#Preview("Dynamic Island expanded", as: .dynamicIsland(.expanded), using: MatchActivityAttributes(matchID: UUID())) {
    MatchActivityWidget()
} contentStates: {
    MatchGlance.samples()[1]
    MatchGlance.samples()[3]
}

#Preview("Dynamic Island minimal", as: .dynamicIsland(.minimal), using: MatchActivityAttributes(matchID: UUID())) {
    MatchActivityWidget()
} contentStates: {
    MatchGlance.samples()[0]
}
