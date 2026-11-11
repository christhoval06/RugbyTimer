import SwiftUI

struct WatchScoreboardWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let homeScore: Int
    let awayScore: Int

    var body: some View {
        VStack(spacing: 4) {
            WatchScoreRowWidget(name: homeTeamName, role: "Home", score: homeScore, tint: .pitchEmerald)
            Rectangle().fill(Color.armorBorder).frame(height: 1)
                .accessibilityHidden(true)
            WatchScoreRowWidget(name: awayTeamName, role: "Away", score: awayScore, tint: .sinBinAmber)
        }
        .padding(8)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.armorBorder))
    }
}
