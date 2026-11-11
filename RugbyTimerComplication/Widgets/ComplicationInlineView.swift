import SwiftUI
import WidgetKit

/// Inline, above the time on the watch face: "H1 12–7 · 30:34".
struct ComplicationInlineView: View {
    let entry: MatchClockEntry

    var body: some View {
        if entry.glance.isIdle {
            Text("\(Image(systemName: "figure.rugby")) RUGBY TIMER") // l10n-ignore: app name
        } else if entry.glance.showsClock {
            Text("\(entry.glance.periodLabel) \(entry.glance.score) · \(entry.clockText)") // l10n-ignore: translated label and score
        } else {
            Text(verbatim: "\(entry.glance.periodLabel) \(entry.glance.homeCode) \(entry.glance.score) \(entry.glance.awayCode)") // l10n-ignore: translated label and score
        }
    }
}

#Preview(as: .accessoryInline) {
    RugbyTimerComplication()
} timeline: {
    MatchClockEntry.samples[0]
    MatchClockEntry.samples[1]
    MatchClockEntry.samples[2]
    MatchClockEntry.samples[3]
}
