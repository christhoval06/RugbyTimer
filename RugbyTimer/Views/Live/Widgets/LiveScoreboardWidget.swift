import SwiftUI

struct LiveScoreboardWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let homeScore: Int
    let awayScore: Int

    var body: some View {
        VStack(spacing: 12) {
            SetupSectionHeadingWidget(number: "02", title: "SCOREBOARD", detail: "POINTS")
            VStack(spacing: 1) {
                LiveScoreRowWidget(title: "HOME", name: homeTeamName, score: homeScore,
                                   color: Color.pitchEmerald, isLeading: homeScore > awayScore)
                Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 16)
                LiveScoreRowWidget(title: "AWAY", name: awayTeamName, score: awayScore,
                                   color: Color.sinBinAmber, isLeading: awayScore > homeScore)
            }
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        }
    }
}
