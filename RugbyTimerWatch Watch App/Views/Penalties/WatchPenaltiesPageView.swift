import SwiftUI

/// Penalties page, one swipe left of the clock: a big PEN and FK button per team.
/// A tap counts one against that team (tap lock applies) and returns to the clock, where
/// Undo can take it back.
struct WatchPenaltiesPageView: View {
    let homeTeamName: String
    let awayTeamName: String
    let events: [MatchEvent]
    let onConcede: (Infringement, String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchPageTitleWidget(eyebrow: "CONCEDED BY", title: "PENALTIES", tint: .sinBinAmber)
                teamSection(homeTeamName, tint: .pitchEmerald)
                teamSection(awayTeamName, tint: .sinBinAmber)
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }

    private func teamSection(_ team: String, tint: Color) -> some View {
        let count = InfringementCount.count(in: events, team: team)
        return VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Circle().fill(tint).frame(width: 5, height: 5)
                Text(team.uppercased())
                    .font(.system(size: 10, weight: .heavy).width(.condensed))
                    .foregroundStyle(Color.iceTitanium)
                    .lineLimit(1)
            }
            HStack(spacing: 6) {
                countButton("PEN", count.penalties, kind: .penalty, team: team, tint: tint)
                countButton("FK", count.freeKicks, kind: .freeKick, team: team, tint: tint)
            }
        }
    }

    private func countButton(_ title: LocalizedStringKey, _ value: Int, kind: Infringement, team: String,
                             tint: Color) -> some View {
        Button { onConcede(kind, team) } label: {
            VStack(spacing: 0) {
                Text("\(value)")
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                Text(title)
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.6)
            }
            .foregroundStyle(kind == .penalty ? Color.pitchVoid : Color.iceTitanium)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(kind == .penalty ? tint : tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 11))
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(tint.opacity(0.5)))
        }
        .buttonStyle(WatchTapLockButtonStyle())
        .accessibilityLabel(kind == .penalty
            ? Text("Penalty against \(team), \(value) so far")
            : Text("Free kick against \(team), \(value) so far"))
    }
}

#Preview {
    WatchPenaltiesPageView(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", events: []) { _, _ in }
}
