import SwiftUI
import WidgetKit

/// The match clock and score on the watch face and in the Smart Stack.
struct RugbyTimerComplication: Widget {
    static let kind = "RugbyTimerComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: MatchClockProvider()) { entry in
            MatchClockEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Match clock")
        .description("The match clock, score and sin-bins at a glance.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryCorner, .accessoryInline])
    }
}

/// Picks the layout for the complication's size.
struct MatchClockEntryView: View {
    let entry: MatchClockEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular: ComplicationCircularView(entry: entry)
        case .accessoryCorner: ComplicationCornerView(entry: entry)
        case .accessoryInline: ComplicationInlineView(entry: entry)
        default: ComplicationRectangularView(entry: entry)
        }
    }
}

#Preview(as: .accessoryRectangular) {
    RugbyTimerComplication()
} timeline: {
    MatchClockEntry.samples[0]
    MatchClockEntry.samples[1]
    MatchClockEntry.samples[2]
    MatchClockEntry.samples[3]
}
