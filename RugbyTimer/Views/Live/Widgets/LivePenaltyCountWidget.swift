import SwiftUI

/// Penalties and free kicks conceded by each team. In iPhone-only mode the counts are
/// buttons (one tap adds one, Undo takes it back); while mirroring the Watch they're read-only.
struct LivePenaltyCountWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let events: [MatchEvent]
    /// Nil when the counts can't be changed here (mirroring the Watch, or play has stopped).
    var onConcede: ((Infringement, String) -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            SetupSectionHeadingWidget(number: "05", title: "PENALTIES", detail: onConcede == nil ? "CONCEDED" : "TAP TO COUNT")
            VStack(spacing: 0) {
                teamRow(homeTeamName, tint: Color.pitchEmerald)
                Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 14)
                teamRow(awayTeamName, tint: Color.sinBinAmber)
            }
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
            LivePenaltyLogWidget(events: events, homeTeamName: homeTeamName)
        }
    }

    private func teamRow(_ team: String, tint: Color) -> some View {
        let count = InfringementCount.count(in: events, team: team)
        return HStack(spacing: 10) {
            Circle().fill(tint).frame(width: 8, height: 8)
            Text(team)
                .font(.system(size: 15, weight: .bold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(1)
            Spacer(minLength: 4)
            countButton("PEN", count.penalties, kind: .penalty, team: team, tint: tint)
            countButton("FK", count.freeKicks, kind: .freeKick, team: team, tint: tint)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func countButton(_ title: LocalizedStringKey, _ value: Int, kind: Infringement, team: String,
                             tint: Color) -> some View {
        Button { onConcede?(kind, team) } label: {
            HStack(spacing: 6) {
                Text(title).font(.system(size: 11, weight: .heavy)).tracking(0.5)
                Text("\(value)").font(.system(size: 20, weight: .heavy, design: .monospaced))
            }
            .foregroundStyle(Color.iceTitanium)
            .frame(width: 84, height: 44)
            .background(tint.opacity(onConcede == nil ? 0.06 : 0.16), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint.opacity(onConcede == nil ? 0.2 : 0.5)))
        }
        .buttonStyle(.plain)
        .disabled(onConcede == nil)
        .accessibilityIdentifier("\(kind.rawValue).\(team == homeTeamName ? "home" : "away")") // l10n-ignore: test ID
        .accessibilityLabel(kind == .penalty
            ? Text("Penalties against \(team): \(value)")
            : Text("Free kicks against \(team): \(value)"))
    }
}

#Preview {
    LivePenaltyCountWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", events: []) { _, _ in }
        .padding()
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
