import SwiftUI
import WidgetKit

/// The match on the Home Screen and Lock Screen: the live clock and score while a match is on,
/// otherwise the last result. Tapping it opens the app.
struct MatchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: MatchWidgetStore.kind, provider: MatchWidgetProvider()) { entry in
            MatchWidgetEntryView(entry: entry)
                .environment(\.locale, entry.locale)
                .containerBackground(Color.pitchVoid, for: .widget)
        }
        .configurationDisplayName("Match")
        .description("The live match clock and score, or your last result.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

/// Picks the layout for the widget's size and what there is to show.
struct MatchWidgetEntryView: View {
    let entry: MatchWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular: ComplicationCircularView(entry: entry.accessoryEntry)
        case .accessoryRectangular: ComplicationRectangularView(entry: entry.accessoryEntry)
        case .accessoryInline: ComplicationInlineView(entry: entry.accessoryEntry)
        default: homeScreenView
        }
    }

    @ViewBuilder private var homeScreenView: some View {
        if let live = entry.liveMatch {
            if family == .systemSmall {
                MatchWidgetLiveSmallView(entry: live)
            } else {
                MatchWidgetLiveMediumView(entry: live)
            }
        } else if let result = entry.snapshot.lastResult {
            MatchWidgetResultView(result: result, label: entry.snapshot.lastMatchLabel)
        } else {
            MatchWidgetEmptyView(label: entry.snapshot.noMatchesLabel)
        }
    }
}

#Preview("Small", as: .systemSmall) {
    MatchWidget()
} timeline: {
    MatchWidgetEntry.samples[0]
    MatchWidgetEntry.samples[1]
    MatchWidgetEntry.samples[2]
    MatchWidgetEntry.samples[3]
}

#Preview("Medium", as: .systemMedium) {
    MatchWidget()
} timeline: {
    MatchWidgetEntry.samples[0]
    MatchWidgetEntry.samples[1]
    MatchWidgetEntry.samples[2]
    MatchWidgetEntry.samples[3]
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    MatchWidget()
} timeline: {
    MatchWidgetEntry.samples[1]
    MatchWidgetEntry.samples[2]
}
