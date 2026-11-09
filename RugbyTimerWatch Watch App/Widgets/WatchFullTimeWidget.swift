import SwiftUI

/// Full-time headline: who won and by how much, or a draw.
struct WatchFullTimeWidget: View {
    let summary: WatchMatchSummary

    private var headline: Text {
        switch summary.result {
        case .draw: Text("DRAW")
        case .win(let team, _): Text("\(team.uppercased()) WIN")
        }
    }

    private var detail: Text {
        switch summary.result {
        case .draw: Text(verbatim: "\(summary.homeScore)–\(summary.awayScore)")
        case .win(_, let margin): Text("\(summary.homeScore)–\(summary.awayScore) · BY \(margin)")
        }
    }

    private var tint: Color {
        switch summary.result {
        case .draw: .iceTitanium
        case .win(let team, _): team == summary.homeTeamName ? .pitchEmerald : .sinBinAmber
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Label("MATCH COMPLETE", systemImage: "flag.checkered")
                .font(.system(size: 8, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(Color.outline)
            headline
                .font(.system(size: 18, weight: .black).width(.condensed))
                .foregroundStyle(tint)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            detail
                .font(.system(size: 13, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.iceTitanium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 11))
        .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.armorBorder))
        .accessibilityElement(children: .combine)
    }
}

#Preview("Full time") {
    WatchFullTimeWidget(summary: .preview)
        .padding()
}
