import SwiftUI
import WidgetKit

/// "▮ 2 · 6:52": players in the sin-bin and the countdown for the first one back.
struct ComplicationSinBinRow: View {
    let entry: MatchClockEntry

    var body: some View {
        let count = entry.glance.sinBinCount
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

#if os(watchOS) // the iPhone Lock Screen widget shares this view; its previews are in MatchWidget
#Preview(as: .accessoryRectangular) {
    RugbyTimerComplication()
} timeline: {
    MatchClockEntry.samples[1]
}
#endif
