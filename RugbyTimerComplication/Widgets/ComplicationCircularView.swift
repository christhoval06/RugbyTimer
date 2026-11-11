import SwiftUI
import WidgetKit

/// Circular: a ring that empties as the half runs, with the period and the clock inside.
struct ComplicationCircularView: View {
    let entry: MatchClockEntry

    var body: some View {
        ZStack {
            if entry.glance.isIdle {
                AccessoryWidgetBackground()
                Image(systemName: "figure.rugby")
                    .font(.system(size: 22, weight: .semibold))
                    .widgetAccentable()
            } else {
                ring.tint(entry.tint).widgetAccentable()
                VStack(spacing: 0) {
                    Text(entry.glance.periodLabel)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(entry.tint)
                    (entry.glance.showsClock ? entry.clockText : Text(verbatim: entry.glance.score))
                        .font(.system(size: 13, weight: .heavy).width(.condensed))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                }
                .padding(6)
            }
        }
    }

    @ViewBuilder private var ring: some View {
        let glance = entry.glance
        if let end = glance.clockEndsAt, entry.date < end, glance.periodSeconds > 0 {
            ProgressView(timerInterval: end.addingTimeInterval(-TimeInterval(glance.periodSeconds))...end,
                         countsDown: true, label: { EmptyView() }, currentValueLabel: { EmptyView() })
                .progressViewStyle(.circular)
        } else if entry.glance.showsClock && !entry.glance.isAtBreak {
            ProgressView(value: entry.progress).progressViewStyle(.circular)
        } else {
            AccessoryWidgetBackground()
        }
    }
}

#Preview(as: .accessoryCircular) {
    RugbyTimerComplication()
} timeline: {
    MatchClockEntry.samples[0]
    MatchClockEntry.samples[1]
    MatchClockEntry.samples[2]
    MatchClockEntry.samples[3]
}
