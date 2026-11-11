import SwiftUI
import WidgetKit

/// Circular: a ring that empties as the half runs, with the period and the clock inside.
struct ComplicationCircularView: View {
    let entry: MatchClockEntry

    var body: some View {
        ZStack {
            if entry.snapshot.isIdle {
                AccessoryWidgetBackground()
                Image(systemName: "figure.rugby")
                    .font(.system(size: 22, weight: .semibold))
                    .widgetAccentable()
            } else {
                ring.tint(entry.tint).widgetAccentable()
                VStack(spacing: 0) {
                    Text(entry.snapshot.periodLabel)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(entry.tint)
                    (entry.showsClock ? entry.clockText : Text(verbatim: entry.score))
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
        let snapshot = entry.snapshot
        if let end = snapshot.clockEndsAt, entry.date < end, snapshot.periodSeconds > 0 {
            ProgressView(timerInterval: end.addingTimeInterval(-TimeInterval(snapshot.periodSeconds))...end,
                         countsDown: true, label: { EmptyView() }, currentValueLabel: { EmptyView() })
                .progressViewStyle(.circular)
        } else if entry.showsClock && !entry.isAtBreak {
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
