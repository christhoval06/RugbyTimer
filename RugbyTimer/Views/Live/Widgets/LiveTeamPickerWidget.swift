import SwiftUI

struct LiveTeamPickerWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    @Binding var selectedTeam: String

    var body: some View {
        HStack(spacing: 10) {
            option(homeTeamName, label: "HOME", tint: Color.pitchEmerald)
            option(awayTeamName, label: "AWAY", tint: Color.sinBinAmber)
        }
    }

    private func option(_ team: String, label: LocalizedStringKey, tint: Color) -> some View {
        let isSelected = selectedTeam == team
        return Button {
            HapticService.playStartStop()
            selectedTeam = team
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(isSelected ? Color.pitchVoid.opacity(0.7) : tint)
                Text(team)
                    .font(.system(size: 18, weight: .bold).width(.condensed))
                    .foregroundStyle(isSelected ? Color.pitchVoid : Color.iceTitanium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
            .background(isSelected ? tint : Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? tint : Color.armorBorder))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
