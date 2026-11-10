import SwiftUI

/// Full-time result line: "Home NN – NN Away", with the winner's score in its team colour.
struct LiveFinalResultWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let homeScore: Int
    let awayScore: Int

    private var outcome: LocalizedStringKey {
        if homeScore == awayScore { return "MATCH DRAWN" }
        return homeScore > awayScore ? "\(homeTeamName) WIN" : "\(awayTeamName) WIN"
    }

    var body: some View {
        VStack(spacing: 14) {
            Label("FULL TIME", systemImage: "flag.checkered")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundStyle(Color.outline)

            HStack(alignment: .center, spacing: 12) {
                teamName(homeTeamName, alignment: .trailing)
                HStack(spacing: 8) {
                    score(homeScore, color: Color.pitchEmerald, isWinner: homeScore > awayScore)
                    Text("–")
                        .font(.system(size: 34, weight: .black).width(.condensed))
                        .foregroundStyle(Color.outline)
                    score(awayScore, color: Color.sinBinAmber, isWinner: awayScore > homeScore)
                }
                .fixedSize()
                teamName(awayTeamName, alignment: .leading)
            }

            Text(outcome)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Color.iceTitanium.opacity(0.7))
                .lineLimit(1)
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Full time: \(homeTeamName) \(homeScore), \(awayTeamName) \(awayScore)")
    }

    private func teamName(_ name: String, alignment: TextAlignment) -> some View {
        Text(name)
            .font(.system(size: 17, weight: .bold).width(.condensed))
            .foregroundStyle(Color.iceTitanium)
            .multilineTextAlignment(alignment)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, alignment: alignment == .trailing ? .trailing : .leading)
    }

    private func score(_ value: Int, color: Color, isWinner: Bool) -> some View {
        Text("\(value)")
            .font(.system(size: 48, weight: .black).width(.condensed))
            .monospacedDigit()
            .foregroundStyle(isWinner ? color : Color.iceTitanium)
    }
}

#Preview("Final result") {
    VStack(spacing: 16) {
        LiveFinalResultWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", homeScore: 24, awayScore: 17)
        LiveFinalResultWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", homeScore: 10, awayScore: 10)
    }
    .padding(20)
    .background(Color.pitchVoid)
    .preferredColorScheme(.dark)
}
