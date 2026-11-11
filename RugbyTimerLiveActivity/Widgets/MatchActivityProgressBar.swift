import ActivityKit
import SwiftUI
import WidgetKit

/// How much of the period is left: a bar that empties on its own while the clock runs.
/// Shared by the Live Activity and the Home Screen widget.
struct MatchActivityProgressBar: View {
    let glance: MatchGlance
    let date: Date

    var body: some View {
        Group {
            if let start = glance.clockStartedAt, let end = glance.clockEndsAt, date < end {
                ProgressView(timerInterval: start...end, countsDown: true,
                             label: { EmptyView() }, currentValueLabel: { EmptyView() })
            } else if glance.isPlaying {
                ProgressView(value: glance.progress(at: date))
            }
        }
        .progressViewStyle(.linear)
        .tint(glance.tint(at: date))
    }
}

#Preview(as: .content, using: MatchActivityAttributes(matchID: UUID())) {
    MatchActivityWidget()
} contentStates: {
    MatchGlance.samples()[1]
}
