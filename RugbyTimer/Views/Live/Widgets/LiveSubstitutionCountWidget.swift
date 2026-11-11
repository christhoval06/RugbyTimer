import SwiftUI

/// Substitutions made by each team, against the limit. Shown when the match tracks
/// substitutions, both in iPhone-only mode and while mirroring the Watch.
struct LiveSubstitutionCountWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let events: [MatchEvent]

    @Environment(\.substitutionRules) private var rules

    var body: some View {
        if rules.isEnabled {
            VStack(spacing: 12) {
                SetupSectionHeadingWidget(number: "06", title: "SUBSTITUTIONS",
                                          detail: rules.hasLimit ? "UP TO \(rules.limit) PER TEAM" : "NO LIMIT")
                VStack(spacing: 0) {
                    teamRow(homeTeamName, tint: Color.pitchEmerald)
                    Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 14)
                    teamRow(awayTeamName, tint: Color.sinBinAmber)
                }
                .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
            }
        }
    }

    private func teamRow(_ team: String, tint: Color) -> some View {
        let made = Substitution.count(in: events, team: team)
        let isFull = rules.hasLimit && made >= rules.limit
        return HStack(spacing: 10) {
            Circle().fill(tint).frame(width: 8, height: 8)
            Text(team)
                .font(.system(size: 15, weight: .bold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(verbatim: rules.hasLimit ? "\(made)/\(rules.limit)" : "\(made)")
                .font(.system(size: 20, weight: .heavy, design: .monospaced))
                .foregroundStyle(isFull ? Color.sinBinAmber : Color.iceTitanium)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(team): \(made) substitutions"))
    }
}

#Preview {
    LiveSubstitutionCountWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", events: [])
        .environment(\.substitutionRules, SubstitutionRules(isEnabled: true))
        .padding()
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
