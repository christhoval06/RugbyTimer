import SwiftUI

struct WatchTeamToggleWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    @Binding var selectedTeam: String

    var body: some View {
        HStack(spacing: 4) {
            option(homeTeamName, tint: .pitchEmerald)
            option(awayTeamName, tint: .sinBinAmber)
        }
    }

    private func option(_ team: String, tint: Color) -> some View {
        let isSelected = selectedTeam == team
        return Button { selectedTeam = team } label: {
            Text(team.uppercased())
                .font(.system(size: 10, weight: .heavy).width(.condensed))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Color.pitchVoid : Color.iceTitanium)
                .frame(maxWidth: .infinity, minHeight: 26)
                .background(isSelected ? tint : Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? tint : Color.armorBorder))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
