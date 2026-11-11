import SwiftUI
import WidgetKit

/// Small: period, the big clock, both teams' scores and the period's progress.
struct MatchWidgetLiveSmallView: View {
    let entry: MatchClockEntry

    var body: some View {
        let glance = entry.glance
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.statusLabel)
                .font(.system(size: 12, weight: .heavy))
                .tracking(0.5)
                .foregroundStyle(entry.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if glance.showsClock {
                entry.clockText
                    .font(.system(size: 40, weight: .black).width(.condensed))
                    .monospacedDigit()
                    .foregroundStyle(glance.zone(at: entry.date) == .timeUp ? Color.expulsionRed : Color.iceTitanium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Spacer(minLength: 2)
            teamRow(glance.homeCode, glance.homeScore)
            teamRow(glance.awayCode, glance.awayScore)
            MatchActivityProgressBar(glance: glance, date: entry.date)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func teamRow(_ code: String, _ score: Int) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(verbatim: code)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.outline)
            Spacer(minLength: 4)
            Text(verbatim: "\(score)")
                .font(.system(size: 22, weight: .black).width(.condensed))
                .monospacedDigit()
                .foregroundStyle(Color.iceTitanium)
                .contentTransition(.numericText())
        }
    }
}

#Preview(as: .systemSmall) {
    MatchWidget()
} timeline: {
    MatchWidgetEntry.samples[0]
    MatchWidgetEntry.samples[1]
}
