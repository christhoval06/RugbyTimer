import SwiftUI

struct WatchMatchupWidget: View {
    let homeTeamName: String
    let awayTeamName: String

    var body: some View {
        VStack(spacing: 4) {
            WatchMatchTeamWidget(name: homeTeamName, role: "Home", tint: .pitchEmerald)
            HStack(spacing: 6) {
                Rectangle().fill(Color.armorBorder).frame(height: 1)
                Text("VS")
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.outline)
                Rectangle().fill(Color.armorBorder).frame(height: 1)
            }
            .accessibilityHidden(true)
            WatchMatchTeamWidget(name: awayTeamName, role: "Away", tint: .sinBinAmber)
        }
        .padding(8)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.armorBorder))
    }
}
