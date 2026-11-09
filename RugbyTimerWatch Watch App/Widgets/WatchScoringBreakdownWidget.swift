import SwiftUI

/// Tries, conversions, penalty goals and drop goals per team, with half-by-half points.
struct WatchScoringBreakdownWidget: View {
    let summary: WatchMatchSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                Text("SCORING")
                    .font(.system(size: 9, weight: .heavy).width(.condensed))
                    .tracking(1)
                    .foregroundStyle(Color.pitchEmerald)
                Spacer(minLength: 2)
                ForEach(["T", "C", "P", "D"], id: \.self) { column in
                    Text(verbatim: column)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.outline)
                        .frame(width: WatchScoringBreakdownRowWidget.columnWidth)
                }
            }
            .accessibilityHidden(true)

            WatchScoringBreakdownRowWidget(name: summary.homeTeamName, tint: .pitchEmerald,
                                           breakdown: summary.homeBreakdown)
            Rectangle().fill(Color.armorBorder).frame(height: 1)
                .accessibilityHidden(true)
            WatchScoringBreakdownRowWidget(name: summary.awayTeamName, tint: .sinBinAmber,
                                           breakdown: summary.awayBreakdown)

            if let halves = summary.scoreByHalf {
                Rectangle().fill(Color.armorBorder).frame(height: 1)
                    .accessibilityHidden(true)
                WatchScoreByHalfWidget(
                    firstHalf: halves.firstHalf,
                    secondHalf: summary.matchPeriod == .fullTime ? halves.secondHalf : nil
                )
            }
        }
        .padding(8)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.armorBorder))
    }
}

#Preview("Scoring breakdown") {
    WatchScoringBreakdownWidget(summary: .preview)
        .padding()
}
