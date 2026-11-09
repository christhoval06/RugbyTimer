import SwiftUI

struct SettingsTeamNamesWidget: View {
    @Binding var homeTeam: String
    @Binding var awayTeam: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SetupSettingLabelWidget(symbol: "person.2.fill", title: "Default teams",
                                    subtitle: "Pre-filled in Team Lineup", tint: .iceTitanium)
            field(title: "HOME", placeholder: "Home team", accessibilityLabel: "Default home team",
                  color: .pitchEmerald, text: $homeTeam)
            field(title: "AWAY", placeholder: "Away team", accessibilityLabel: "Default away team",
                  color: .sinBinAmber, text: $awayTeam)
        }
        .padding(14)
    }

    private func field(title: LocalizedStringKey, placeholder: LocalizedStringKey, accessibilityLabel: LocalizedStringKey, color: Color, text: Binding<String>) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(color)
                .fixedSize()
                .frame(minWidth: 42, alignment: .leading)
            TextField(placeholder, text: text)
                .font(.system(size: 17, weight: .bold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .accessibilityLabel(accessibilityLabel)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .background(Color.pitchVoid.opacity(0.6), in: RoundedRectangle(cornerRadius: 9))
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.armorBorder))
    }
}
