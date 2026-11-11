import SwiftUI
import WidgetKit

/// Medium: the Lock Screen banner's layout — period and clock, both teams' names and scores,
/// the period's progress and the sin-bins.
struct MatchWidgetLiveMediumView: View {
    let entry: MatchClockEntry

    var body: some View {
        let glance = entry.glance
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.statusLabel)
                    .font(.system(size: 13, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(entry.tint)
                    .lineLimit(1)
                if glance.showsClock {
                    entry.clockText
                        .font(.system(size: 30, weight: .black).width(.condensed))
                        .monospacedDigit()
                        .foregroundStyle(glance.zone(at: entry.date) == .timeUp ? Color.expulsionRed : Color.iceTitanium)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            HStack(alignment: .bottom) {
                MatchActivityTeamScore(name: glance.homeTeamName, score: glance.homeScore, alignment: .leading)
                Text(verbatim: "–")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(Color.outline)
                MatchActivityTeamScore(name: glance.awayTeamName, score: glance.awayScore, alignment: .trailing)
            }
            MatchActivityProgressBar(glance: glance, date: entry.date)
            MatchActivitySinBinRow(glance: glance, date: entry.date)
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview(as: .systemMedium) {
    MatchWidget()
} timeline: {
    MatchWidgetEntry.samples[0]
    MatchWidgetEntry.samples[1]
}
