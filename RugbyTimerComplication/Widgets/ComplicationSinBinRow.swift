import SwiftUI
import WidgetKit

/// "▮ 2 · 6:52": players in the sin-bin and the countdown for the first one back.
struct ComplicationSinBinRow: View {
    let entry: MatchClockEntry

    var body: some View {
        let count = entry.snapshot.sinBinCount
        if count > 0 {
            HStack(spacing: 3) {
                Image(systemName: "rectangle.portrait.fill")
                    .foregroundStyle(Color.cardYellow)
                    .widgetAccentable()
                Text(verbatim: "\(count)")
                if let end = entry.runningSinBinEndsAt {
                    Text(verbatim: "·")
                    Text(end, style: .timer)
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.secondary)
        }
    }
}

#Preview(as: .accessoryRectangular) {
    RugbyTimerComplication()
} timeline: {
    MatchClockEntry.samples[1]
}
