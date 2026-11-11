import SwiftUI

/// Substitutions made by each team, against the limit ("3/8"); amber once a team has used them all.
/// Shown on the Substitutions page and in the half-time and full-time stats.
struct WatchSubstitutionCountsWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let rules: SubstitutionRules
    let events: [MatchEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("SUBS")
                .font(.system(size: 9, weight: .heavy).width(.condensed))
                .tracking(1)
                .foregroundStyle(Color.pitchEmerald)
                .accessibilityHidden(true)
            row(homeTeamName, tint: .pitchEmerald)
            Rectangle().fill(Color.armorBorder).frame(height: 1).accessibilityHidden(true)
            row(awayTeamName, tint: .sinBinAmber)
        }
        .padding(8)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.armorBorder))
    }

    private func row(_ team: String, tint: Color) -> some View {
        let made = Substitution.count(in: events, team: team)
        let isFull = rules.hasLimit && made >= rules.limit
        return HStack(spacing: 0) {
            Circle().fill(tint).frame(width: 5, height: 5).padding(.trailing, 5)
            Text(team)
                .font(.system(size: 12, weight: .bold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(1)
            Spacer(minLength: 2)
            Text(verbatim: rules.hasLimit ? "\(made)/\(rules.limit)" : "\(made)")
                .font(.system(size: 12, weight: .heavy, design: .monospaced))
                .foregroundStyle(isFull ? Color.sinBinAmber : Color.iceTitanium)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(team): \(made) substitutions"))
    }
}

#Preview {
    WatchSubstitutionCountsWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
                                  rules: SubstitutionRules(isEnabled: true), events: [])
        .padding()
}
