import SwiftUI
import WidgetKit

/// Rectangular (and Smart Stack): period and clock, the score, and the next sin-bin back.
struct ComplicationRectangularView: View {
    let entry: MatchClockEntry

    var body: some View {
        if entry.glance.isIdle {
            Label {
                Text(verbatim: "RUGBY TIMER") // l10n-ignore: app name
                    .font(.system(size: 15, weight: .heavy).width(.condensed))
            } icon: {
                Image(systemName: "figure.rugby")
            }
            .widgetAccentable()
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(entry.statusLabel)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(entry.tint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .widgetAccentable()
                    if entry.glance.showsClock {
                        entry.clockText
                            .font(.system(size: 17, weight: .heavy).width(.condensed))
                            .monospacedDigit()
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                Text(verbatim: "\(entry.glance.homeCode) \(entry.glance.score) \(entry.glance.awayCode)") // l10n-ignore: team codes and score
                    .font(.system(size: 20, weight: .black).width(.condensed))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                ComplicationSinBinRow(entry: entry)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
