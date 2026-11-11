import SwiftUI

/// Half-time and full-time summary: penalties and free kicks conceded by each team,
/// with the first-half / second-half split for penalties at full time.
struct WatchPenaltyStatsWidget: View {
    let summary: WatchMatchSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                Text("PENALTIES")
                    .font(.system(size: 9, weight: .heavy).width(.condensed))
                    .tracking(1)
                    .foregroundStyle(Color.sinBinAmber)
                Spacer(minLength: 2)
                ForEach(columns, id: \.self) { column in
                    Text(verbatim: column)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.outline)
                        .frame(width: 22)
                }
            }
            .accessibilityHidden(true)
            row(summary.homeTeamName, tint: .pitchEmerald)
            Rectangle().fill(Color.armorBorder).frame(height: 1).accessibilityHidden(true)
            row(summary.awayTeamName, tint: .sinBinAmber)
        }
        .padding(8)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.armorBorder))
    }

    private var isFullTime: Bool { summary.matchPeriod == .fullTime }
    /// Penalties and free kicks; at full time also the penalties in each half.
    private var columns: [String] { isFullTime ? ["P", "FK", "H1", "H2"] : ["P", "FK"] } // l10n-ignore: column codes

    private func row(_ team: String, tint: Color) -> some View {
        let total = InfringementCount.count(in: summary.matchEvents, team: team)
        let halves = InfringementCount.byHalf(in: summary.matchEvents, team: team)
        var values = [total.penalties, total.freeKicks]
        if isFullTime { values += [halves.firstHalf.penalties, halves.secondHalf.penalties] }
        return HStack(spacing: 0) {
            Circle().fill(tint).frame(width: 5, height: 5).padding(.trailing, 5)
            Text(team)
                .font(.system(size: 12, weight: .bold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(1)
            Spacer(minLength: 2)
            ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                Text("\(value)")
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .foregroundStyle(value > 0 ? Color.iceTitanium : Color.outline.opacity(0.6))
                    .frame(width: 22)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(team): penalties \(total.penalties), free kicks \(total.freeKicks)"))
    }
}

#Preview {
    WatchPenaltyStatsWidget(summary: .preview)
        .padding()
}
