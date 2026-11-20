import SwiftUI

struct WatchActiveTimersWidget: View {
    let summary: WatchMatchSummary
    let actions: OffFieldActions?

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchPageTitleWidget(eyebrow: "MATCH CLOCK", title: "ACTIVE TIMERS", tint: .sinBinAmber)
                if let endsAt = summary.breakEndsAt {
                    WatchBreakCountdownWidget(endsAt: endsAt, totalSeconds: summary.breakSeconds)
                }
                if summary.activeCards.isEmpty && summary.injuries.isEmpty {
                    Text("No players off the field")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.outline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    WatchSinBinListWidget(cards: summary.activeCards, injuries: summary.injuries,
                                          title: "OFF THE FIELD", actions: actions)
                }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }
}

#Preview {
    WatchActiveTimersWidget(summary: .preview, actions: .preview)
}
