import SwiftUI
import WidgetKit

/// Corner: the clock in the corner, with the period and score curved along the edge.
struct ComplicationCornerView: View {
    let entry: MatchClockEntry

    var body: some View {
        if entry.snapshot.isIdle {
            Image(systemName: "figure.rugby")
                .font(.system(size: 20, weight: .semibold))
                .widgetAccentable()
        } else {
            (entry.showsClock ? entry.clockText : Text(verbatim: entry.score))
                .font(.system(size: 15, weight: .heavy).width(.condensed))
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .foregroundStyle(entry.tint)
                .widgetAccentable()
                .widgetLabel {
                    Text(verbatim: entry.showsClock ? "\(entry.snapshot.periodLabel) \(entry.score)" : entry.snapshot.periodLabel) // l10n-ignore: translated label and score
                }
        }
    }
}

#Preview(as: .accessoryCorner) {
    RugbyTimerComplication()
} timeline: {
    MatchClockEntry.samples[0]
    MatchClockEntry.samples[1]
    MatchClockEntry.samples[2]
    MatchClockEntry.samples[3]
}
