import SwiftUI

/// One finished match: date, where it ran, both teams and the final score.
struct MatchHistoryRowWidget: View {
    let entry: MatchHistoryEntry

    private var sourceSymbol: String {
        switch entry.source {
        case .watch: "applewatch"
        case .iPhone: "iphone"
        case .quickMatch: "bolt.fill"
        }
    }

    private var sourceLabel: LocalizedStringKey {
        switch entry.source {
        case .watch: "APPLE WATCH"
        case .iPhone: "IPHONE"
        case .quickMatch: "QUICK MATCH"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(entry.playedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.outline)
                Spacer(minLength: 4)
                Label(sourceLabel, systemImage: sourceSymbol)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(Color.outline)
            }
            teamLine(entry.homeTeam, score: entry.homeScore, isWinner: entry.homeScore > entry.awayScore,
                     tint: Color.pitchEmerald)
            teamLine(entry.awayTeam, score: entry.awayScore, isWinner: entry.awayScore > entry.homeScore,
                     tint: Color.sinBinAmber)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(entry.homeTeam) \(entry.homeScore), \(entry.awayTeam) \(entry.awayScore), \(entry.playedAt.formatted(date: .long, time: .shortened))"))
        .accessibilityHint("Opens the match record")
    }

    private func teamLine(_ team: String, score: Int, isWinner: Bool, tint: Color) -> some View {
        HStack(spacing: 8) {
            Circle().fill(tint).frame(width: 7, height: 7)
            Text(team)
                .font(.system(size: 17, weight: isWinner ? .heavy : .semibold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text("\(score)")
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(isWinner ? Color.iceTitanium : Color.outline)
        }
    }
}
