import SwiftUI

struct WatchFullTimeWidget: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.pitchEmerald)
                .accessibilityHidden(true)
            Text("MATCH COMPLETE")
                .font(.system(size: 12, weight: .heavy).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 11))
        .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.armorBorder))
    }
}
