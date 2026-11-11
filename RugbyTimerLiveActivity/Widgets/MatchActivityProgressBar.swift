import ActivityKit
import SwiftUI
import WidgetKit

/// How much of the period is left: a bar that empties on its own while the clock runs.
struct MatchActivityProgressBar: View {
    let context: ActivityViewContext<MatchActivityAttributes>

    var body: some View {
        let glance = context.glance
        Group {
            if let start = glance.clockStartedAt, let end = glance.clockEndsAt, context.displayDate < end {
                ProgressView(timerInterval: start...end, countsDown: true,
                             label: { EmptyView() }, currentValueLabel: { EmptyView() })
            } else if glance.isPlaying {
                ProgressView(value: glance.progress(at: context.displayDate))
            }
        }
        .progressViewStyle(.linear)
        .tint(context.tint)
    }
}

#Preview(as: .content, using: MatchActivityAttributes(matchID: UUID())) {
    MatchActivityWidget()
} contentStates: {
    MatchGlance.samples()[1]
}
