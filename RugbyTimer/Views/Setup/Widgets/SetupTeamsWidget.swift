import SwiftUI

struct SetupTeamsWidget: View {
    @Binding var homeTeamName: String
    @Binding var awayTeamName: String

    var body: some View {
        VStack(spacing: 12) {
            SetupSectionHeadingWidget(number: "01", title: "TEAM LINEUP", detail: "THE MATCHUP")
            VStack(spacing: 1) {
                SetupTeamFieldWidget(title: "HOME TEAM", role: "HOST", placeholder: "Home team", color: Color.pitchEmerald, name: $homeTeamName)
                Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 16)
                SetupTeamFieldWidget(title: "AWAY TEAM", role: "VISITOR", placeholder: "Away team", color: Color.sinBinAmber, name: $awayTeamName)
            }
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        }
    }

}
