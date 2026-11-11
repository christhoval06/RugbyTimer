import SwiftUI
import WidgetKit

/// Between matches: "LAST MATCH", when it was played, and the final score.
struct MatchWidgetResultView: View {
    let result: MatchWidgetResult
    let label: String
    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(verbatim: label)
                    .foregroundStyle(Color.pitchEmerald)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
                Image(systemName: "figure.rugby")
                    .foregroundStyle(Color.pitchEmerald)
            }
            .font(.system(size: 12, weight: .heavy))
            Text(result.playedAt, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.outline)
            Spacer(minLength: 4)
            teamRow(result.homeTeamName, result.homeScore, wins: result.homeScore > result.awayScore)
            teamRow(result.awayTeamName, result.awayScore, wins: result.awayScore > result.homeScore)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var isSmall: Bool { family == .systemSmall }

    private func teamRow(_ name: String, _ score: Int, wins: Bool) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(verbatim: name)
                .font(.system(size: isSmall ? 14 : 17, weight: .bold))
                .foregroundStyle(wins ? Color.iceTitanium : Color.outline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 4)
            Text(verbatim: "\(score)")
                .font(.system(size: isSmall ? 26 : 32, weight: .black).width(.condensed))
                .monospacedDigit()
                .foregroundStyle(wins ? Color.iceTitanium : Color.outline)
        }
    }
}

#Preview(as: .systemSmall) {
    MatchWidget()
} timeline: {
    MatchWidgetEntry.samples[2]
}
